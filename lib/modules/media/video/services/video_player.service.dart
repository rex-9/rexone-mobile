import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/speech.service.dart';

import '../../audio/services/audio_player.service.dart';

class VideoPlayerService extends GetxService {
  static bool get isAndroid => GetPlatform.isAndroid;
  static bool get isIOS => GetPlatform.isIOS;

  /// Reactive so [Obx] mounts [BetterPlayer] as soon as the controller exists.
  final Rxn<BetterPlayerController> controller = Rxn<BetterPlayerController>();
  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxInt currentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSession = false.obs;
  final RxBool subtitlesEnabled = false.obs;
  final RxInt selectedSubtitleIndex = (-1).obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  double _volume = 100.0;
  double _rate = 1.0;
  Timer? _positionHeartbeatTimer;

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

  Future<void> setAssets(List<AssetModel> next) async {
    final activeIds = next.map((item) => item.id).toSet();
    _prunePlaybackCache(activeIds);
    assets.assignAll(next);
    if (assets.isEmpty && hasSession.value) {
      await dismiss();
    }
  }

  /// Returns `false` when playback fails to start.
  Future<bool> play(int index) async {
    if (assets.isEmpty) return true;
    final nextIndex = index.clamp(0, assets.length - 1);

    hasSession.value = true;
    currentIndex.value = nextIndex;
    _syncQueueIndex(nextIndex);
    _syncSubtitleSelectionForCurrentAsset();
    isLoading.value = true;
    position.value = Duration.zero;
    duration.value = Duration.zero;

    try {
      await _pauseAudioAndSpeech();
      _ensureController();

      final targetAsset = assets[nextIndex];
      final url = await _playbackUrl(targetAsset);
      if (url == null || url.isEmpty) {
        isLoading.value = false;
        return false;
      }

      debugPrint('🔍 [VideoPlayerService] Opening media: $url');
      // Prefetch our SRT URLs into memory sources so better_player's built-in
      // Subtitles menu lists them and can render without its own HTTP fetch.
      final subtitleSources = await _preloadSubtitleSources();
      final dataSource = buildDataSource(
        url,
        cacheKey: targetAsset.id,
        subtitles: subtitleSources,
      );
      await controller.value!.setupDataSource(dataSource);
      try {
        controller.value?.setMixWithOthers(false);
      } catch (e) {
        debugPrint('⚠️ [VideoPlayerService] setMixWithOthers warning: $e');
      }
      try {
        await controller.value?.setVolume(_volume / 100.0);
      } catch (_) {}
      try {
        await controller.value?.setSpeed(_rate);
      } catch (_) {}
      await controller.value!.play();
      _startPositionHeartbeat();
      isLoading.value = false;
      return true;
    } catch (error) {
      isLoading.value = false;
      debugPrint('❌ [VideoPlayerService] Play error: $error');
      return false;
    }
  }

  Future<void> pause() async {
    _stopPositionHeartbeat();
    await controller.value?.pause();
  }

  Future<void> toggle() async {
    if (!hasSession.value) return;
    final player = controller.value;
    if (player == null) return;
    try {
      if (player.isPlaying() == true) {
        _stopPositionHeartbeat();
        await player.pause();
      } else {
        await player.play();
        _startPositionHeartbeat();
      }
    } catch (error) {
      debugPrint('❌ [VideoPlayerService] Toggle error: $error');
    }
  }

  Future<void> next() async {
    if (await _advanceMixedQueue(forward: true)) return;
    if (assets.isEmpty) return;
    final nextIndex = hasSession.value
        ? (currentIndex.value + 1) % assets.length
        : 0;
    await play(nextIndex);
  }

  Future<void> previous() async {
    if (await _advanceMixedQueue(forward: false)) return;
    if (assets.isEmpty) return;
    final prevIndex = hasSession.value
        ? (currentIndex.value - 1 + assets.length) % assets.length
        : 0;
    await play(prevIndex);
  }

  Future<void> seek(Duration target) async {
    position.value = target;
    await controller.value?.seekTo(target);
    _onSeekCompleted();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 100.0);
    await controller.value?.setVolume(_volume / 100.0);
  }

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.25, 2.0);
    await controller.value?.setSpeed(_rate);
  }

  double get volume => _volume;

  double get rate => _rate;

  Future<void> dismiss() async {
    _stopPositionHeartbeat();
    hasSession.value = false;
    isPlaying.value = false;
    isLoading.value = false;
    subtitlesEnabled.value = false;
    selectedSubtitleIndex.value = -1;
    currentIndex.value = -1;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _disposeController();
  }

  @override
  void onClose() {
    _stopPositionHeartbeat();
    unawaited(dismiss());
    super.onClose();
  }

  void _ensureController() {
    if (controller.value != null) return;

    final betterPlayerController = BetterPlayerController(
      const PlayerConfiguration(
        autoPlay: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoDispose: false,
        handleLifecycle: true,
        allowedScreenSleep: false,
        controlsConfiguration: PlayerControlsConfiguration(
          enableSkips: false,
          enableQualities: false,
          enableAudioTracks: false,
        ),
      ),
    );

    betterPlayerController.addEventsListener(_onPlayerEvent);
    controller.value = betterPlayerController;
  }

  void _onPlayerEvent(PlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case PlayerEventType.play:
        isPlaying.value = true;
        isLoading.value = false;
        _startPositionHeartbeat();
      case PlayerEventType.pause:
        isPlaying.value = false;
        _stopPositionHeartbeat();
      case PlayerEventType.finished:
        isPlaying.value = false;
        _stopPositionHeartbeat();
      case PlayerEventType.seekTo:
        final seekTarget =
            event.parameters?[PlayerEventConstants.durationParameter];
        if (seekTarget is Duration) {
          position.value = seekTarget;
        }
        _onSeekCompleted();
      case PlayerEventType.progress:
        final progress = event.parameters?['progress'];
        final total = event.parameters?['duration'];
        if (progress is Duration) position.value = progress;
        if (total is Duration) duration.value = total;
      case PlayerEventType.bufferingEnd:
      case PlayerEventType.initialized:
        isLoading.value = false;
      case PlayerEventType.changedSubtitles:
        _syncSubtitlesFromPlayer();
      case PlayerEventType.exception:
        isLoading.value = false;
        debugPrint(
          '❌ [VideoPlayerService] Player exception: ${event.parameters}',
        );
      default:
        break;
    }
  }

  void _onSeekCompleted() {
    final player = controller.value;
    if (player == null) return;

    // Kicks BetterPlayer's internal PlayerEngineController to restart the
    // position polling timer canceled by seekTo().
    try {
      if (isPlaying.value || player.isPlaying() == true) {
        unawaited(player.play());
        _startPositionHeartbeat();
      }
    } catch (_) {}

    // Re-assert audio volume to prevent ExoPlayer AudioTrack buffer starvation silence.
    try {
      unawaited(player.setVolume(_volume / 100.0));
    } catch (_) {}
  }

  void _startPositionHeartbeat() {
    _positionHeartbeatTimer?.cancel();
    _positionHeartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) async {
        final player = controller.value;
        if (player == null || !isPlaying.value) {
          _stopPositionHeartbeat();
          return;
        }
        final current = await player.position;
        if (current != null && isPlaying.value) {
          position.value = current;
        }
      },
    );
  }

  void _stopPositionHeartbeat() {
    _positionHeartbeatTimer?.cancel();
    _positionHeartbeatTimer = null;
  }

  @visibleForTesting
  PlayerDataSource buildDataSource(
    String url, {
    String? cacheKey,
    List<PlayerSubtitlesSource> subtitles = const [],
  }) {
    final isFile = url.startsWith('file:') || !url.contains('://');
    final resolvedUrl = isFile
        ? _filePathFromUrl(url)
        : UrlHelper.normalize(url);

    // Dynamic playback URLs from GET /playback are presigned specifically for the client host
    // (e.g. 10.0.2.2:3100 on Android). Overriding the Host header causes AWS SigV4 / Garage
    // signature verification to fail with 403 Forbidden.
    return PlayerDataSource(
      isFile ? DataSourceType.file : DataSourceType.network,
      resolvedUrl,
      headers: null,
      subtitles: subtitles.isEmpty ? null : subtitles,
      // Offline decrypted files may keep a non-media extension (.enc).
      videoExtension: isFile ? 'mp4' : null,
      cacheConfiguration: isFile
          ? null
          : CacheConfiguration(
              useCache: true,
              maxCacheSize: MediaPlaybackConstants.videoMaxCacheSizeBytes,
              maxCacheFileSize:
                  MediaPlaybackConstants.videoMaxCacheFileSizeBytes,
              key: cacheKey,
            ),
      bufferingConfiguration: isFile
          ? const BufferingConfiguration()
          : const BufferingConfiguration(
              minBufferMs: MediaPlaybackConstants.videoMinBufferMs,
              maxBufferMs: MediaPlaybackConstants.videoMaxBufferMs,
              bufferForPlaybackMs:
                  MediaPlaybackConstants.videoBufferForPlaybackMs,
              bufferForPlaybackAfterRebufferMs:
                  MediaPlaybackConstants.videoBufferForPlaybackAfterRebufferMs,
            ),
    );
  }

  String _filePathFromUrl(String url) {
    if (url.startsWith('file:')) {
      return Uri.parse(url).toFilePath();
    }
    return url;
  }

  void _syncSubtitleSelectionForCurrentAsset() {
    selectedSubtitleIndex.value = -1;
    subtitlesEnabled.value = false;
  }

  void _syncSubtitlesFromPlayer() {
    final source = controller.value?.betterPlayerSubtitlesSource;
    if (source == null || source.type == PlayerSubtitlesSourceType.none) {
      subtitlesEnabled.value = false;
      selectedSubtitleIndex.value = -1;
      return;
    }

    final tracks = effectiveSubtitles;
    final index = tracks.indexWhere(
      (track) => track.displayLabel == source.name,
    );
    subtitlesEnabled.value = true;
    selectedSubtitleIndex.value = index;
  }

  Future<List<PlayerSubtitlesSource>> _preloadSubtitleSources() async {
    final tracks = effectiveSubtitles;
    if (tracks.isEmpty) return const [];

    final loaded = await Future.wait(
      tracks.map((track) async {
        final body = await _media.fetchSubtitleBody(track.url);
        if (body == null || body.trim().isEmpty) {
          debugPrint(
            '❌ [VideoPlayerService] Empty subtitle body for ${track.url}',
          );
          return null;
        }
        final optimizedBody = SrtHelper.bridgeSmallGaps(body);
        return PlayerSubtitlesSource(
          type: PlayerSubtitlesSourceType.memory,
          name: track.displayLabel,
          content: optimizedBody,
        );
      }),
    );

    return loaded.whereType<PlayerSubtitlesSource>().toList();
  }

  void _disposeController() {
    final player = controller.value;
    if (player != null) {
      player.dispose(forceDispose: true);
    }
    controller.value = null;
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
      debugPrint('🔍 [VideoPlayerService] Local path: $localPath');
      if (localPath != null && localPath.isNotEmpty) {
        _offlineSubtitlesByAssetId[asset.id] = await downloads
            .resolveOfflineSubtitleTracks(asset);
        debugPrint(
          '🔍 [VideoPlayerService] Offline subtitles: '
          '${_offlineSubtitlesByAssetId[asset.id]}',
        );
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

  void _prunePlaybackCache(Set<String> activeIds) {
    _playbackByAssetId.removeWhere((id, _) => !activeIds.contains(id));
    _offlineSubtitlesByAssetId.removeWhere((id, _) => !activeIds.contains(id));
    for (final id in List<String>.from(_playbackByAssetId.keys)) {
      if (!activeIds.contains(id)) {
        _media.clearPlaybackCache(assetId: id);
      }
    }
  }

  void _syncQueueIndex(int index) {
    if (!Get.isRegistered<AudioPlayerService>()) return;
    Get.find<AudioPlayerService>().syncQueueIndexForAsset(assets[index]);
  }

  Future<bool> _advanceMixedQueue({required bool forward}) async {
    if (!Get.isRegistered<AudioPlayerService>()) return false;
    final audio = Get.find<AudioPlayerService>();
    if (audio.queue.isEmpty) return false;

    final current = audio.queueIndex.value >= 0
        ? audio.queueIndex.value
        : audio.queue.indexWhere((item) => item.id == currentAsset?.id);
    if (current < 0) return false;

    final target = forward
        ? (current + 1) % audio.queue.length
        : (current - 1 + audio.queue.length) % audio.queue.length;
    await audio.playQueueAt(target);
    return true;
  }

  Future<void> _pauseAudioAndSpeech() async {
    if (Get.isRegistered<SpeechService>()) {
      await Get.find<SpeechService>().stopPlayback();
    }
    if (Get.isRegistered<AudioPlayerService>()) {
      final audio = Get.find<AudioPlayerService>();
      if (audio.hasSession.value && audio.isPlaying.value) {
        await audio.pause();
      }
    }
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}
  }
}
