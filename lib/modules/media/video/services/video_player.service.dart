import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/speech.service.dart';

import '../../audio/services/audio_player.service.dart';

class VideoPlayerService extends GetxService {
  static bool get isAndroid => GetPlatform.isAndroid;

  Player? _player;
  VideoController? _videoController;

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxInt currentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSession = false.obs;
  final RxBool subtitlesEnabled = false.obs;
  final RxInt selectedSubtitleIndex = (-1).obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<bool>? _bufferingSub;

  final Map<String, AssetPlaybackResponse> _playbackByAssetId = {};
  final Map<String, List<ChildAssetModel>> _offlineSubtitlesByAssetId = {};

  static bool get isIOS => GetPlatform.isIOS;

  MediaService get _media => Get.find<MediaService>();
  MediaDownloadService? get _downloads =>
      Get.isRegistered<MediaDownloadService>()
          ? Get.find<MediaDownloadService>()
          : null;

  VideoController? get videoController => _videoController;

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

    try {
      await _pauseAudioAndSpeech();
      _ensurePlayer();

      final url = await _playbackUrl(assets[nextIndex]);
      if (url == null || url.isEmpty) {
        isLoading.value = false;
        return false;
      }

      debugPrint('🔍 [VideoPlayerService] Opening media: $url');
      final headers = UrlHelper.headersFor(url);
      await _player!.open(
        Media(
          url,
          httpHeaders: headers.isEmpty ? null : headers,
        ),
        play: true,
      );
      await _applySubtitleForCurrentAsset();
      return true;
    } catch (error) {
      isLoading.value = false;
      debugPrint('❌ [VideoPlayerService] Play error: $error');
      return false;
    }
  }

  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> toggle() async {
    if (!hasSession.value) return;
    await _player?.playOrPause();
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
    await _player?.seek(target);
    position.value = target;
  }

  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume.clamp(0.0, 100.0));
  }

  Future<void> setRate(double rate) async {
    await _player?.setRate(rate);
  }

  Future<void> setSubtitlesEnabled(bool enabled) async {
    if (enabled) {
      subtitlesEnabled.value = true;
      if (selectedSubtitleIndex.value < 0) {
        selectedSubtitleIndex.value = hasEffectiveSubtitles ? 0 : -1;
      }
    } else {
      subtitlesEnabled.value = false;
      selectedSubtitleIndex.value = -1;
    }
    await _applySubtitleForCurrentAsset();
  }

  Future<void> selectSubtitleTrack(int index) async {
    final tracks = effectiveSubtitles;
    if (index < 0 || index >= tracks.length) return;
    selectedSubtitleIndex.value = index;
    subtitlesEnabled.value = true;
    await _applySubtitleForCurrentAsset();
  }

  double get volume => _player?.state.volume ?? 100.0;

  double get rate => _player?.state.rate ?? 1.0;

  Future<void> dismiss() async {
    hasSession.value = false;
    isPlaying.value = false;
    isLoading.value = false;
    subtitlesEnabled.value = false;
    selectedSubtitleIndex.value = -1;
    currentIndex.value = -1;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    await _disposePlayer();
  }

  @override
  void onClose() {
    unawaited(dismiss());
    super.onClose();
  }

  void _ensurePlayer() {
    if (_player != null) return;
    _player = Player();

    _videoController = VideoController(
      _player!,
    );
    _bindStreams();
  }

  void _bindStreams() {
    final player = _player!;
    _playingSub = player.stream.playing.listen((playing) {
      isPlaying.value = playing;
    });
    _positionSub = player.stream.position.listen((value) {
      position.value = value;
    });
    _durationSub = player.stream.duration.listen((value) {
      duration.value = value;
    });
    _bufferingSub = player.stream.buffering.listen((buffering) {
      isLoading.value = buffering;
    });
  }

  void _syncSubtitleSelectionForCurrentAsset() {
    final tracks = effectiveSubtitles;
    if (tracks.isEmpty) {
      selectedSubtitleIndex.value = -1;
      subtitlesEnabled.value = false;
      return;
    }
    if (subtitlesEnabled.value) {
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

  Future<void> _applySubtitleForCurrentAsset() async {
    if (_player == null) return;

    if (subtitlesEnabled.value) {
      final track = _selectedSubtitleTrack();
      if (track != null) {
        try {
          await _player!.setSubtitleTrack(
            SubtitleTrack.uri(
              UrlHelper.normalize(track.url),
              title: track.displayLabel,
            ),
          );
        } catch (error) {
          debugPrint('❌ [VideoPlayerService] Subtitle error: $error');
        }
        return;
      }
    }

    try {
      await _player!.setSubtitleTrack(SubtitleTrack.no());
    } catch (error) {
      debugPrint('❌ [VideoPlayerService] Clear subtitle error: $error');
    }
  }

  Future<void> _disposePlayer() async {
    await _playingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _bufferingSub?.cancel();
    _playingSub = null;
    _positionSub = null;
    _durationSub = null;
    _bufferingSub = null;
    await _player?.dispose();
    _player = null;
    _videoController = null;
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
        _offlineSubtitlesByAssetId[asset.id] =
            await downloads.resolveOfflineSubtitleTracks(asset);
      debugPrint('🔍 [VideoPlayerService] Offline subtitles: ${_offlineSubtitlesByAssetId[asset.id]}');
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
        : audio.queue.indexWhere(
            (item) => item.id == currentAsset?.id,
          );
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
  }
}
