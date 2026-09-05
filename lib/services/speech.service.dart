// lib/services/speech.service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';
import 'package:rexone_mobile/services/permission.service.dart';
import 'package:rexone_mobile/services/socket.service.dart';

/// Shared live STT + TTS client. Any controller can `Get.find<SpeechService>()`.
///
/// Owns the microphone, SpeechLiveChannel PCM stream, TTS HTTP queue, and
/// URL playback. Feature controllers keep their own text fields and message UI.
class SpeechService extends GetxService with WidgetsBindingObserver {
  late final ApiService _api;
  late final SocketService _socket;
  late final PermissionService _permissions;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  final RxBool isListening = false.obs;
  final RxDouble voiceLevel = 0.0.obs;
  final RxBool isPlaying = false.obs;
  final RxString liveText = ''.obs;

  bool _isStartingListen = false;
  bool _isTearingDown = false;
  bool _speechSubscribed = false;
  int _listenEpoch = 0;
  String _committedText = '';
  String _partialText = '';
  StreamSubscription<Amplitude>? _amplitudeSub;
  StreamSubscription<Uint8List>? _pcmSub;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  final BytesBuilder _pcmBuffer = BytesBuilder(copy: false);

  bool get isListenSessionActive =>
      isListening.value || _speechSubscribed || _isStartingListen;

  bool get isBusy => isListenSessionActive || isPlaying.value;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _socket = Get.find<SocketService>();
    _permissions = Get.find<PermissionService>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (isListening.value || _speechSubscribed) {
        unawaited(stopListening());
      }
      if (isPlaying.value) {
        unawaited(stopPlayback());
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(stopListening());
    unawaited(stopPlayback());
    unawaited(_recorder.dispose());
    unawaited(_player.dispose());
    super.onClose();
  }

  // ============================================================
  // TTS (TEXT-TO-SPEECH) HTTP
  // ============================================================

  /// Queues background TTS synthesis for an existing chat message.
  Future<ApiResponse<Map<String, dynamic>>> textToSpeech(
    String messageId, {
    bool showLoading = false,
  }) async {
    final response = await _api.post(ServerRoutes.textToSpeech, {
      SpeechKeys.messageId: messageId,
    }, showLoading: showLoading);
    return _api.parseResponse<Map<String, dynamic>>(
      response,
      (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  // ============================================================
  // STT (SPEECH-TO-TEXT) HTTP
  // ============================================================

  /// Transcribes recorded audio bytes synchronously using `/v1/speech/stt`.
  Future<ApiResponse<String>> speechToTextFromFile(
    Uint8List audioBytes, {
    String filename = 'audio.wav',
    bool showLoading = true,
  }) async {
    final form = FormData({
      SpeechKeys.audio: MultipartFile(
        audioBytes,
        filename: filename,
        contentType: 'audio/wav',
      ),
    });
    final response = await _api.postMultipart(
      ServerRoutes.speechToText,
      form,
      showLoading: showLoading,
    );
    return _api.parseResponse<String>(
      response,
      (data) => data is Map
          ? data[SpeechKeys.text]?.toString() ?? ''
          : data?.toString() ?? '',
    );
  }

  /// Transcribes remote audio from a URL synchronously using `/v1/speech/stt`.
  Future<ApiResponse<String>> speechToTextFromUrl(
    String audioUrl, {
    bool showLoading = true,
  }) async {
    final response = await _api.post(ServerRoutes.speechToText, {
      SpeechKeys.audioUrl: audioUrl,
    }, showLoading: showLoading);
    return _api.parseResponse<String>(
      response,
      (data) => data is Map
          ? data[SpeechKeys.text]?.toString() ?? ''
          : data?.toString() ?? '',
    );
  }

  // ============================================================
  // TTS PLAYBACK
  // ============================================================
  Future<void> playUrl(String url) async {
    await stopPlayback();
    isPlaying.value = true;
    try {
      await _player.setUrl(url);
      _playerStateSub?.cancel();
      _playerStateSub = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          unawaited(stopPlayback());
        }
      });
      await _player.play();
    } catch (_) {
      isPlaying.value = false;
      rethrow;
    }
  }

  Future<void> stopPlayback() async {
    _playerStateSub?.cancel();
    _playerStateSub = null;
    await _player.stop();
    isPlaying.value = false;
  }

  // ============================================================
  // LIVE STT
  // ============================================================
  Future<ESpeechListenResult> startListening({String seed = ''}) async {
    if (isListening.value || _isStartingListen) {
      return ESpeechListenResult.alreadyListening;
    }

    if (!_socket.isConnected.value) {
      return ESpeechListenResult.disconnected;
    }

    if (!await _permissions.requestMicrophone() ||
        !await _recorder.hasPermission()) {
      return ESpeechListenResult.permissionDenied;
    }

    await stopPlayback();

    _isStartingListen = true;
    final epoch = ++_listenEpoch;
    try {
      _committedText = seed;
      _partialText = '';
      liveText.value = seed;

      final subscribed = await _socket.subscribe(SpeechKeys.channel);
      if (epoch != _listenEpoch) {
        if (subscribed) {
          _socket.perform(SpeechKeys.channel, SpeechKeys.stop);
          _socket.unsubscribe(SpeechKeys.channel);
        }
        return ESpeechListenResult.failed;
      }
      if (!subscribed) {
        return ESpeechListenResult.disconnected;
      }
      _speechSubscribed = true;

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: AppConstants.speechSampleRate,
          numChannels: AppConstants.speechNumChannels,
          streamBufferSize: AppConstants.speechChunkBytes,
        ),
      );
      if (epoch != _listenEpoch) {
        try {
          if (await _recorder.isRecording()) {
            await _recorder.stop();
          }
        } catch (_) {}
        return ESpeechListenResult.failed;
      }

      isListening.value = true;
      voiceLevel.value = 0;

      _pcmSub = stream.listen(
        _onPcmChunk,
        onError: (Object e) {
          debugPrint('🎤 [SpeechService] PCM stream error: $e');
          unawaited(stopListening());
        },
      );

      await _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amplitude) {
            voiceLevel.value = _normalizeAmplitude(amplitude.current);
          });

      await _connSub?.cancel();
      _connSub = _socket.isConnected.listen((connected) {
        if (!connected && (isListening.value || _speechSubscribed)) {
          unawaited(stopListening());
        }
      });

      return ESpeechListenResult.started;
    } catch (e) {
      debugPrint('🎤 [SpeechService] Error starting live listen: $e');
      await stopListening();
      return ESpeechListenResult.failed;
    } finally {
      _isStartingListen = false;
    }
  }

  Future<void> stopListening() async {
    if (!isListening.value && !_speechSubscribed && !_isStartingListen) {
      return;
    }
    if (_isTearingDown) return;
    _isTearingDown = true;
    _listenEpoch++;
    try {
      await _pcmSub?.cancel();
      _pcmSub = null;
      await _amplitudeSub?.cancel();
      _amplitudeSub = null;
      await _connSub?.cancel();
      _connSub = null;

      if (_pcmBuffer.isNotEmpty) {
        _flushPcm();
      }
      _pcmBuffer.clear();

      try {
        if (await _recorder.isRecording()) {
          await _recorder.stop();
        }
      } catch (_) {}

      if (_speechSubscribed) {
        _socket.perform(SpeechKeys.channel, SpeechKeys.stop);
        _socket.unsubscribe(SpeechKeys.channel);
        _speechSubscribed = false;
      }

      isListening.value = false;
      voiceLevel.value = 0;
      _committedText = liveText.value;
      _partialText = '';
    } finally {
      _isTearingDown = false;
    }
  }

  /// Called by [SocketController] for SpeechLiveChannel partial/final/error.
  void onSpeechEvent(SocketMessage event, ESpeechEventType eventType) {
    if (!_speechSubscribed && !isListening.value) return;

    switch (eventType) {
      case ESpeechEventType.partial:
        _partialText = _mergePartial(_partialText, event.message ?? '');
        liveText.value = _joinSpeech(_committedText, _partialText);
      case ESpeechEventType.finalPhrase:
        _committedText = _joinSpeech(_committedText, event.message ?? '');
        _partialText = '';
        liveText.value = _committedText;
      case ESpeechEventType.error:
        unawaited(stopListening());
      case ESpeechEventType.unknown:
        break;
    }
  }

  void _onPcmChunk(Uint8List chunk) {
    _pcmBuffer.add(chunk);
    if (_pcmBuffer.length >= AppConstants.speechChunkBytes) {
      _flushPcm();
    }
  }

  void _flushPcm() {
    if (_pcmBuffer.isEmpty || !_speechSubscribed) return;
    final bytes = _pcmBuffer.takeBytes();
    if (bytes.isEmpty) return;
    _socket.perform(SpeechKeys.channel, SpeechKeys.audio, {
      SpeechKeys.chunk: base64Encode(bytes),
    });
  }

  String _joinSpeech(String committed, String incoming) {
    final next = incoming.trim();
    if (next.isEmpty) return committed;
    if (committed.isEmpty) return next;
    if (committed.endsWith(' ') || committed.endsWith('\n')) {
      return '$committed$next';
    }
    return '$committed $next';
  }

  String _mergePartial(String current, String incoming) {
    final next = incoming.trim();
    if (next.isEmpty) return current;
    if (current.isEmpty) return next;
    final currentLower = current.toLowerCase();
    final nextLower = next.toLowerCase();
    if (nextLower.startsWith(currentLower) ||
        currentLower.startsWith(nextLower)) {
      return next;
    }
    return _joinSpeech(current, next);
  }

  double _normalizeAmplitude(double db) {
    return ((db + 50) / 50).clamp(0.0, 1.0);
  }
}
