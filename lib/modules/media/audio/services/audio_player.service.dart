import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/speech.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

import '../../video/services/video_player.service.dart';
import 'now_playing.bridge.dart';

class AudioPlayerService extends GetxService with WidgetsBindingObserver {
  AudioPlayer? _player;

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxList<AssetModel> queue = <AssetModel>[].obs;
  final RxInt queueIndex = (-1).obs;
  final RxInt currentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSession = false.obs;
  final RxBool isFullPlayerOpen = false.obs;
  final RxString navRoute = ''.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxBool lyricsVisible = false.obs;
  final RxInt selectedSubtitleIndex = (-1).obs;
  final RxList<SubtitleCue> lyrics = <SubtitleCue>[].obs;
  final RxBool lyricsLoading = false.obs;
  final RxString lyricsError = ''.obs;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  Timer? _persistTimer;
  String? _loadedAssetId;
  int _nowPlayingEpoch = 0;
  int _lyricsLoadEpoch = 0;
  final Map<String, List<SubtitleCue>> _lyricsCache = {};
  final Map<String, AssetPlaybackResponse> _playbackByAssetId = {};
  final Map<String, List<ChildAssetModel>> _offlineSubtitlesByAssetId = {};

  MediaService get _media => Get.find<MediaService>();
  MediaDownloadService? get _downloads =>
      Get.isRegistered<MediaDownloadService>()
          ? Get.find<MediaDownloadService>()
          : null;

  AssetModel? get currentAsset {
    final index = currentIndex.value;
    if (index < 0 || index >= assets.length) return null;
    return assets[index];
  }

  List<ChildAssetModel> get effectiveSubtitles {
    final asset = currentAsset;
    if (asset == null) return const [];
    return _effectiveSubtitles(asset);
  }

  bool get hasEffectiveSubtitles => effectiveSubtitles.isNotEmpty;

  int get activeLyricsIndex =>
      SrtHelper.activeIndexAt(lyrics, position.value);

  /// Full mixed audio/video order for next/previous navigation.
  void setQueue(List<AssetModel> next) {
    queue.assignAll(next);
    if (queueIndex.value >= queue.length) {
      queueIndex.value = -1;
    }
  }

  void syncQueueIndexForAsset(AssetModel asset) {
    final index = queue.indexWhere((item) => item.id == asset.id);
    if (index >= 0) queueIndex.value = index;
  }

  /// Plays an item from the mixed [queue], handing off between audio and video.
  Future<bool> playQueueAt(int index) async {
    if (index < 0 || index >= queue.length) return false;
    queueIndex.value = index;
    final asset = queue[index];

    if (asset.isAudioMedia) {
      return _playQueueAudio(asset);
    }
    if (asset.isVideoMedia) {
      return _playQueueVideo(asset);
    }
    return false;
  }

  /// Replaces the playlist and reloads the current track when already playing.
  Future<void> setAssets(List<AssetModel> next) async {
    final activeIds = next.map((item) => item.id).toSet();
    _prunePlaybackCache(activeIds);
    assets.assignAll(next);
    _loadedAssetId = null;

    if (assets.isEmpty) {
      if (hasSession.value) await dismiss();
      return;
    }

    if (_player == null || !hasSession.value) return;

    final index = currentIndex.value;
    if (index < 0 || index >= assets.length) {
      await dismiss();
      return;
    }

    try {
      await _loadSourceForIndex(index);
    } catch (error) {
      debugPrint('❌ [AudioPlayerService] Set assets error: $error');
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<SpeechService>()) {
      Get.find<SpeechService>().beforeTtsPlayback = yieldToSpeech;
    }
    _restoreSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _persistSession();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _persistTimer?.cancel();
    _persistSession();
    unawaited(_releaseNativePlayer());
    super.onClose();
  }

  /// Returns `false` when playback fails to start.
  Future<bool> play([int? index]) async {
    if (assets.isEmpty) return true;
    final nextIndex =
        (index ?? currentIndex.value).clamp(0, assets.length - 1);
    syncQueueIndexForAsset(assets[nextIndex]);
    hasSession.value = true;
    currentIndex.value = nextIndex;
    _syncSubtitleSelectionForCurrentAsset();
    _syncLyricsOnTrackChange();
    isLoading.value = true;
    try {
      await _stopSpeech();
      await _configurePlaybackSession();
      _ensureNativePlayer();
      if (!await _loadSourceForIndex(nextIndex)) {
        isLoading.value = false;
        return false;
      }
      await _player!.play();
      unawaited(_syncIosNowPlaying(playing: true));
      _persistSession(wasPlaying: true);
      return true;
    } catch (error) {
      isLoading.value = false;
      debugPrint('❌ [AudioPlayerService] Play error: $error');
      return false;
    }
  }

  Future<void> pause() async {
    await _player?.pause();
    unawaited(_syncIosNowPlaying(playing: false));
    _persistSession(wasPlaying: false);
  }

  /// Stops playback, hides the mini player, and drops the saved session.
  Future<void> dismiss() async {
    _persistTimer?.cancel();
    _nowPlayingEpoch++;
    hasSession.value = false;
    isPlaying.value = false;
    isLoading.value = false;
    currentIndex.value = -1;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _loadedAssetId = null;
    if (Get.isRegistered<StorageService>()) {
      Get.find<StorageService>().clearAudioSession();
    }
    isFullPlayerOpen.value = false;
    _resetLyrics();
    unawaited(NowPlayingBridge.clear());
    await _releaseNativePlayer();
  }

  void toggleLyrics() {
    lyricsVisible.value = !lyricsVisible.value;
    if (lyricsVisible.value) {
      if (selectedSubtitleIndex.value < 0 && hasEffectiveSubtitles) {
        selectedSubtitleIndex.value = 0;
      }
      unawaited(_loadLyricsForCurrentAsset());
    }
  }

  Future<void> selectLyricsTrack(int index) async {
    final tracks = effectiveSubtitles;
    if (index < 0 || index >= tracks.length) return;
    selectedSubtitleIndex.value = index;
    _lyricsLoadEpoch++;
    lyrics.assignAll([]);
    lyricsError.value = '';
    if (lyricsVisible.value) {
      await _loadLyricsForCurrentAsset();
    }
  }

  /// Returns `false` when resuming playback fails.
  Future<bool> toggle() async {
    if (!hasSession.value) {
      return play(0);
    }
    if (isPlaying.value) {
      await pause();
      return true;
    }
    isLoading.value = true;
    try {
      await _stopSpeech();
      await _configurePlaybackSession();
      _ensureNativePlayer();
      if (!await _ensureCurrentSource()) {
        isLoading.value = false;
        return false;
      }
      await _player!.play();
      unawaited(_syncIosNowPlaying(playing: true));
      _persistSession(wasPlaying: true);
      return true;
    } catch (error) {
      isLoading.value = false;
      debugPrint('❌ [AudioPlayerService] Toggle error: $error');
      return false;
    }
  }

  Future<bool> next() async {
    if (queue.isNotEmpty) {
      final current = _resolvedQueueIndex();
      final nextIdx = _adjacentPlayableIndex(current, forward: true);
      if (nextIdx == null) return false;
      return playQueueAt(nextIdx);
    }
    if (assets.isEmpty) return true;
    final nextIndex = hasSession.value
        ? (currentIndex.value + 1) % assets.length
        : 0;
    return play(nextIndex);
  }

  Future<bool> previous() async {
    if (queue.isNotEmpty) {
      final current = _resolvedQueueIndex();
      final prevIdx = _adjacentPlayableIndex(current, forward: false);
      if (prevIdx == null) return false;
      return playQueueAt(prevIdx);
    }
    if (assets.isEmpty) return true;
    final prevIndex = hasSession.value
        ? (currentIndex.value - 1 + assets.length) % assets.length
        : 0;
    return play(prevIndex);
  }

  Future<void> seek(Duration position) async {
    await _player?.seek(position);
    this.position.value = position;
    _persistSession();
  }

  /// Releases the native player so TTS can use just_audio.
  /// `just_audio_background` allows only one native instance.
  Future<void> yieldToSpeech() => dismiss();

  void _restoreSession() {
    if (!Get.isRegistered<StorageService>()) return;
    final session = Get.find<StorageService>().getAudioSession();
    if (session == null) return;
    final index = _asInt(session[AudioSessionKeys.currentIndex]);
    if (index == null || index < 0 || index >= assets.length) return;
    final savedPosition = Duration(
      milliseconds: _asInt(session[AudioSessionKeys.positionMs]) ?? 0,
    );
    hasSession.value = true;
    currentIndex.value = index;
    position.value = savedPosition;
    unawaited(
      _resumeSavedSession(index: index, resumeAt: savedPosition),
    );
  }

  Future<void> _resumeSavedSession({
    required int index,
    required Duration resumeAt,
  }) async {
    isLoading.value = true;
    try {
      await _configurePlaybackSession();
      _ensureNativePlayer();
      if (!await _loadSourceForIndex(index, seekTo: resumeAt)) {
        isLoading.value = false;
        return;
      }
      isLoading.value = false;
      _persistSession(wasPlaying: false);
    } catch (error) {
      isLoading.value = false;
      debugPrint('❌ [AudioPlayerService] Restore session error: $error');
    }
  }

  /// iOS 13+ hides Lock Screen Now Playing unless playbackState is set after
  /// `audio_service` writes nowPlayingInfo. Retry once after a short delay.
  Future<void> _syncIosNowPlaying({required bool playing}) async {
    final epoch = ++_nowPlayingEpoch;
    await NowPlayingBridge.setPlaybackState(playing: playing);
    await Future<void>.delayed(Design.timers.medium);
    if (epoch != _nowPlayingEpoch || !hasSession.value) return;
    if (isPlaying.value != playing) return;
    await NowPlayingBridge.setPlaybackState(playing: playing);
  }

  void _ensureNativePlayer() {
    if (_player != null) return;
    _player = AudioPlayer();
    _bindPlayerStreams();
  }

  void _bindPlayerStreams() {
    final player = _player!;
    _playerStateSub = player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      final buffering = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (buffering) {
        isLoading.value = true;
      } else if (state.playing ||
          state.processingState == ProcessingState.ready ||
          state.processingState == ProcessingState.completed) {
        isLoading.value = false;
      }
      if (hasSession.value) {
        unawaited(NowPlayingBridge.setPlaybackState(playing: state.playing));
        _persistSession();
      }
    });
    _positionSub = player.positionStream.listen((value) {
      position.value = value;
      if (hasSession.value) _schedulePersist();
    });
    _durationSub = player.durationStream.listen((value) {
      duration.value = value ?? Duration.zero;
    });
  }

  void _resetLyrics() {
    _lyricsLoadEpoch++;
    lyricsVisible.value = false;
    selectedSubtitleIndex.value = -1;
    lyricsLoading.value = false;
    lyricsError.value = '';
    lyrics.clear();
  }

  void _syncSubtitleSelectionForCurrentAsset() {
    final tracks = effectiveSubtitles;
    if (tracks.isEmpty) {
      selectedSubtitleIndex.value = -1;
      return;
    }
    if (lyricsVisible.value) {
      selectedSubtitleIndex.value = 0;
    } else {
      selectedSubtitleIndex.value = -1;
    }
  }

  ChildAssetModel? _selectedSubtitleTrack() {
    final tracks = effectiveSubtitles;
    if (tracks.isEmpty) return null;
    final index = selectedSubtitleIndex.value;
    if (index < 0 || index >= tracks.length) return tracks.first;
    return tracks[index];
  }

  String? _lyricsCacheKey() {
    final asset = currentAsset;
    final track = _selectedSubtitleTrack();
    if (asset == null || track == null) return null;
    return '${asset.id}:${track.id}';
  }

  void _syncLyricsOnTrackChange() {
    if (!lyricsVisible.value) return;

    if (currentAsset == null || !hasEffectiveSubtitles) {
      lyrics.assignAll([]);
      lyricsError.value = '';
      lyricsLoading.value = false;
      return;
    }

    final cacheKey = _lyricsCacheKey();
    final cached = cacheKey == null ? null : _lyricsCache[cacheKey];
    if (cached != null) {
      lyrics.assignAll(cached);
      lyricsError.value = '';
      lyricsLoading.value = false;
      return;
    }

    unawaited(_loadLyricsForCurrentAsset());
  }

  Future<void> _loadLyricsForCurrentAsset() async {
    final asset = currentAsset;
    final track = _selectedSubtitleTrack();
    if (asset == null || track == null) {
      lyrics.assignAll([]);
      lyricsError.value = '';
      lyricsLoading.value = false;
      return;
    }

    final cacheKey = _lyricsCacheKey();
    final cached = cacheKey == null ? null : _lyricsCache[cacheKey];
    if (cached != null) {
      lyrics.assignAll(cached);
      lyricsError.value = '';
      lyricsLoading.value = false;
      return;
    }

    final epoch = ++_lyricsLoadEpoch;
    lyricsLoading.value = true;
    lyricsError.value = '';
    lyrics.assignAll([]);

    try {
      final body = await _media.fetchSubtitleBody(track.url);
      if (epoch != _lyricsLoadEpoch) return;

      if (body == null || body.trim().isEmpty) {
        lyricsError.value = MediaPlaybackConstants.lyricsErrorFetchFailed;
        return;
      }

      final parsed = SrtHelper.parse(body);
      if (cacheKey != null) {
        _lyricsCache[cacheKey] = parsed;
      }
      if (currentAsset?.id != asset.id || epoch != _lyricsLoadEpoch) return;

      lyrics.assignAll(parsed);
      if (parsed.isEmpty) {
        lyricsError.value = MediaPlaybackConstants.lyricsErrorEmpty;
      }
    } catch (error) {
      if (epoch != _lyricsLoadEpoch) return;
      debugPrint('❌ [AudioPlayerService] Load lyrics error: $error');
      lyricsError.value = MediaPlaybackConstants.lyricsErrorFetchFailed;
    } finally {
      if (epoch == _lyricsLoadEpoch) {
        lyricsLoading.value = false;
      }
    }
  }

  Future<void> _releaseNativePlayer() async {
    _persistTimer?.cancel();
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    _playerStateSub = null;
    _positionSub = null;
    _durationSub = null;
    await _player?.dispose();
    _player = null;
    _loadedAssetId = null;
  }

  Future<void> _configurePlaybackSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (error) {
      debugPrint('❌ [AudioPlayerService] AudioSession configure error: $error');
    }
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(Design.timers.debounce, _persistSession);
  }

  void _persistSession({bool? wasPlaying}) {
    if (!hasSession.value || !Get.isRegistered<StorageService>()) return;
    Get.find<StorageService>().saveAudioSession({
      AudioSessionKeys.currentIndex: currentIndex.value,
      AudioSessionKeys.positionMs: position.value.inMilliseconds,
      AudioSessionKeys.wasPlaying: wasPlaying ?? isPlaying.value,
    });
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  Future<bool> _ensureCurrentSource() async {
    final index = currentIndex.value;
    if (index < 0 || index >= assets.length) return false;
    final asset = assets[index];
    if (_loadedAssetId == asset.id) return true;
    return _loadSourceForIndex(index);
  }

  Future<bool> _loadSourceForIndex(
    int index, {
    Duration seekTo = Duration.zero,
  }) async {
    if (_player == null || index < 0 || index >= assets.length) return false;

    final asset = assets[index];
    final url = await _playbackUrl(asset);
    if (url == null || url.isEmpty) return false;

    await _player!.setAudioSource(_audioSourceFor(asset, url: url));
    _loadedAssetId = asset.id;

    if (seekTo > Duration.zero) {
      await _player!.seek(seekTo);
    }

    return true;
  }

  Future<AssetPlaybackResponse?> _resolvePlayback(AssetModel asset) async {
    if (asset.id.isEmpty) return null;

    final cached = _playbackByAssetId[asset.id];
    if (cached != null && !cached.isNearExpiry) {
      return cached;
    }

    final response = await _media.getAssetPlayback(asset.id);
    if (!response.success || response.data == null) return null;

    _playbackByAssetId[asset.id] = response.data!;
    return response.data;
  }

  Future<String?> _playbackUrl(AssetModel asset) async {
    final downloads = _downloads;
    if (downloads != null && downloads.isDownloaded(asset.id)) {
      final localPath = await downloads.resolveDecryptedMediaPath(asset.id);
      if (localPath != null && localPath.isNotEmpty) {
        _offlineSubtitlesByAssetId[asset.id] =
            await downloads.resolveOfflineSubtitleTracks(asset);
        return Uri.file(localPath).toString();
      }
    }

    final playback = await _resolvePlayback(asset);
    final url = playback?.delivery.url ?? '';
    return url.isEmpty ? null : UrlHelper.normalize(url);
  }

  List<ChildAssetModel> _effectiveSubtitles(AssetModel asset) {
    final offline = _offlineSubtitlesByAssetId[asset.id];
    if (offline != null && offline.isNotEmpty) {
      return offline;
    }
    final fromPlayback = _playbackByAssetId[asset.id]?.media.playableSubtitles;
    if (fromPlayback != null && fromPlayback.isNotEmpty) {
      return fromPlayback;
    }
    return asset.playableSubtitles;
  }

  ChildAssetModel? _effectiveThumbnail(AssetModel asset) {
    final fromPlayback = _playbackByAssetId[asset.id]?.media.thumbnail;
    if (fromPlayback != null && fromPlayback.url.isNotEmpty) {
      return fromPlayback;
    }
    return asset.thumbnail;
  }

  void _prunePlaybackCache(Set<String> activeIds) {
    _playbackByAssetId.removeWhere((id, _) => !activeIds.contains(id));
    _offlineSubtitlesByAssetId.removeWhere((id, _) => !activeIds.contains(id));
    for (final id in List<String>.from(_playbackByAssetId.keys)) {
      if (!activeIds.contains(id)) {
        _media.clearPlaybackCache(assetId: id);
      }
    }
  }

  AudioSource _audioSourceFor(AssetModel asset, {required String url}) {
    final thumb = _effectiveThumbnail(asset);
    final tag = MediaItem(
      id: asset.id,
      title: asset.displayTitle,
      artist: asset.displayDuration,
      album: AppLocales.audio.playlistSubtitle.tr,
      artUri: Uri.tryParse(thumb?.url ?? asset.displayThumbnailUrl),
    );
    final uri = Uri.parse(url);
    if (uri.scheme == 'file') {
      return AudioSource.file(uri.toFilePath(), tag: tag);
    }
    // Dynamic playback URLs from GET /playback are presigned specifically for the client host
    // (e.g. 10.0.2.2:3100 on Android). Overriding the Host header causes AWS SigV4 / Garage
    // signature verification to fail with 403 Forbidden.
    return AudioSource.uri(
      uri,
      headers: null,
      tag: tag,
    );
  }

  Future<void> _stopSpeech() async {
    if (!Get.isRegistered<SpeechService>()) return;
    await Get.find<SpeechService>().stopPlayback();
  }

  int _resolvedQueueIndex() {
    if (queueIndex.value >= 0 && queueIndex.value < queue.length) {
      return queueIndex.value;
    }
    final asset = currentAsset;
    if (asset == null) return -1;
    return queue.indexWhere((item) => item.id == asset.id);
  }

  /// Next/previous playable index in the mixed queue (skips images/attachments).
  int? _adjacentPlayableIndex(int from, {required bool forward}) {
    if (queue.isEmpty) return null;
    final start = from >= 0 ? from : (forward ? -1 : 0);
    for (var step = 1; step <= queue.length; step++) {
      final index = forward
          ? (start + step) % queue.length
          : (start - step + queue.length) % queue.length;
      if (queue[index].isPlayableMedia) return index;
    }
    return null;
  }

  Future<bool> _playQueueAudio(AssetModel asset) async {
    if (Get.isRegistered<VideoPlayerService>()) {
      final video = Get.find<VideoPlayerService>();
      if (video.hasSession.value) {
        await video.dismiss();
        if (Get.currentRoute == AppRoutes.videoPlayer) {
          Get.back();
        }
      }
    }

    final audioIndex = assets.indexWhere((item) => item.id == asset.id);
    if (audioIndex < 0) return false;

    if (hasSession.value && currentIndex.value == audioIndex) {
      return true;
    }
    return play(audioIndex);
  }

  Future<bool> _playQueueVideo(AssetModel asset) async {
    final wasOnAudioPlayer = Get.currentRoute == AppRoutes.audioPlayer;
    if (hasSession.value) {
      await dismiss();
    }
    if (!Get.isRegistered<VideoPlayerService>()) return false;

    final video = Get.find<VideoPlayerService>();
    final videoIndex = video.assets.indexWhere((item) => item.id == asset.id);
    if (videoIndex < 0) return false;

    void navigateToVideo() {
      if (wasOnAudioPlayer) {
        Get.offNamed(AppRoutes.videoPlayer);
      } else {
        AppRoutes.toVideoPlayer();
      }
    }

    if (video.hasSession.value && video.currentIndex.value == videoIndex) {
      navigateToVideo();
      return true;
    }

    // Mount the player page before open so ExoPlayer/AVPlayer has a surface.
    navigateToVideo();
    await Future<void>.delayed(Duration.zero);
    return video.play(videoIndex);
  }
}
