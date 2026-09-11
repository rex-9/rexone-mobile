import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/speech.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

import 'now_playing.bridge.dart';

class AudioPlayerService extends GetxService with WidgetsBindingObserver {
  AudioPlayer? _player;

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxInt currentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSession = false.obs;
  final RxBool isFullPlayerOpen = false.obs;
  final RxString navRoute = ''.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _indexSub;
  Timer? _persistTimer;
  bool _sourcesLoaded = false;
  int _nowPlayingEpoch = 0;

  AssetModel? get currentAsset {
    final index = currentIndex.value;
    if (index < 0 || index >= assets.length) return null;
    return assets[index];
  }

  /// Replaces the playlist and rebuilds audio sources when already playing.
  Future<void> setAssets(List<AssetModel> next) async {
    assets.assignAll(next);
    _sourcesLoaded = false;

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
      await _player!.setAudioSources(
        assets.map(_audioSourceFor).toList(),
        initialIndex: index,
      );
      _sourcesLoaded = true;
    } catch (error) {
      debugPrint('Error: $error');
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

  Future<void> play([int? index]) async {
    if (assets.isEmpty) return;
    final nextIndex =
        (index ?? currentIndex.value).clamp(0, assets.length - 1);
    hasSession.value = true;
    currentIndex.value = nextIndex;
    isLoading.value = true;
    try {
      await _stopSpeech();
      await _configurePlaybackSession();
      _ensureNativePlayer();
      await _ensureSources(initialIndex: nextIndex);
      await _player!.seek(Duration.zero, index: nextIndex);
      await _player!.play();
      unawaited(_syncIosNowPlaying(playing: true));
      _persistSession(wasPlaying: true);
    } catch (error) {
      isLoading.value = false;
      debugPrint('Error: $error');
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
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
    if (Get.isRegistered<StorageService>()) {
      Get.find<StorageService>().clearAudioSession();
    }
    isFullPlayerOpen.value = false;
    unawaited(NowPlayingBridge.clear());
    await _releaseNativePlayer();
  }

  Future<void> toggle() async {
    if (!hasSession.value) {
      await play(0);
      return;
    }
    if (isPlaying.value) {
      await pause();
    } else {
      isLoading.value = true;
      try {
        await _stopSpeech();
        await _configurePlaybackSession();
        _ensureNativePlayer();
        await _ensureSources();
        await _player!.play();
        unawaited(_syncIosNowPlaying(playing: true));
        _persistSession(wasPlaying: true);
      } catch (error) {
        isLoading.value = false;
        debugPrint('Error: $error');
        AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
      }
    }
  }

  Future<void> next() async {
    if (assets.isEmpty) return;
    final nextIndex = hasSession.value
        ? (currentIndex.value + 1) % assets.length
        : 0;
    await play(nextIndex);
  }

  Future<void> previous() async {
    if (assets.isEmpty) return;
    final prevIndex = hasSession.value
        ? (currentIndex.value - 1 + assets.length) % assets.length
        : 0;
    await play(prevIndex);
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
      await _ensureSources(initialIndex: index);
      await _player!.seek(resumeAt, index: index);
      isLoading.value = false;
      _persistSession(wasPlaying: false);
    } catch (error) {
      isLoading.value = false;
      debugPrint('Error: $error');
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
    _indexSub = player.currentIndexStream.listen((index) {
      if (index != null) {
        currentIndex.value = index;
        if (hasSession.value) _persistSession();
      }
    });
  }

  Future<void> _releaseNativePlayer() async {
    _persistTimer?.cancel();
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _indexSub?.cancel();
    _playerStateSub = null;
    _positionSub = null;
    _durationSub = null;
    _indexSub = null;
    await _player?.dispose();
    _player = null;
    _sourcesLoaded = false;
  }

  Future<void> _configurePlaybackSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (error) {
      debugPrint('Error: $error');
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

  Future<void> _ensureSources({int initialIndex = 0}) async {
    if (_sourcesLoaded || _player == null) return;
    await _player!.setAudioSources(
      assets.map(_audioSourceFor).toList(),
      initialIndex: initialIndex,
    );
    _sourcesLoaded = true;
  }

  AudioSource _audioSourceFor(AssetModel asset) {
    return AudioSource.uri(
      Uri.parse(asset.url),
      tag: MediaItem(
        id: asset.id,
        title: asset.displayTitle,
        artist: asset.displaySubtitle,
        album: AppLocales.audio.playlistSubtitle.tr,
        artUri: Uri.tryParse(asset.displayThumbnailUrl),
      ),
    );
  }

  Future<void> _stopSpeech() async {
    if (!Get.isRegistered<SpeechService>()) return;
    await Get.find<SpeechService>().stopPlayback();
  }
}
