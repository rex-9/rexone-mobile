// lib/modules/ai/controllers/ai.controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/services/services.dart';

import '../ai.dart';

class AiController extends GetxController {
  final AiService _ai = Get.find<AiService>();
  final SpeechService _speech = Get.find<SpeechService>();
  final PermissionService _permissions = Get.find<PermissionService>();

  final RxList<AiMessageModel> messages = <AiMessageModel>[].obs;
  final RxList<AiRoomModel> rooms = <AiRoomModel>[].obs;

  final RxnString currentRoomId = RxnString();
  final RxString currentRoomTitle = AppLocales.ai.title.tr.obs;

  final RxBool isProcessing = false.obs;
  final RxnString activeTtsMessageId = RxnString();
  final RxBool isTtsLoading = false.obs;

  bool _isSubmitting = false;
  String _textBeforeListen = '';
  Worker? _liveTextWorker;
  Worker? _playbackWorker;

  RxBool get isRecording => _speech.isListening;
  RxDouble get voiceLevel => _speech.voiceLevel;

  // UI controllers — owned here so no StatefulWidget is needed in AiPage.
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _playbackWorker = ever(_speech.isPlaying, (playing) {
      if (!playing && !isTtsLoading.value) {
        activeTtsMessageId.value = null;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadRooms();
    loadHistory();
  }

  @override
  void onClose() {
    _liveTextWorker?.dispose();
    _playbackWorker?.dispose();
    unawaited(_speech.stopListening());
    unawaited(_speech.stopPlayback());
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ============================================================
  // SOCKET EVENT HANDLER (called by SocketController)
  // ============================================================

  /// Called by [SocketController] when an AI-related notification arrives.
  /// Reloads history only if the event belongs to the current room.
  Future<void> onSocketEvent(
    EWsEventType eventType,
    String? roomId, {
    String? messageId,
  }) async {
    switch (eventType) {
      case EWsEventType.ttsReady:
        if (roomId == null || roomId.isEmpty || roomId == currentRoomId.value) {
          await loadHistory(currentRoomId.value ?? roomId);
        }
        _clearTtsQueue(messageId);
      case EWsEventType.ttsFailed:
        _clearTtsQueue(messageId);
      case EWsEventType.aiResponseReady:
      case EWsEventType.aiResponseFailed:
        if (roomId == null || roomId.isEmpty || roomId == currentRoomId.value) {
          await loadHistory(currentRoomId.value);
        }
      default:
        return;
    }
  }

  void _clearTtsQueue(String? messageId) {
    if (messageId != null && activeTtsMessageId.value != messageId) return;
    isTtsLoading.value = false;
    if (!_speech.isPlaying.value) {
      activeTtsMessageId.value = null;
    }
  }

  // ============================================================
  // HISTORY & MESSAGES
  // ============================================================
  Future<void> loadHistory([String? roomId]) async {
    try {
      final result = await _ai.getHistory(roomId: roomId);
      if (result.success) {
        if (result.records.isEmpty) {
          messages.assignAll([
            AiMessageModel(
              id: 'welcome',
              role: EChatRole.assistant.name,
              content: AppLocales.ai.defaultGreeting.tr,
              createdAt: DateTime.now().toIso8601String(),
            ),
          ]);
        } else {
          // Derive room context from the message data itself
          final rId = result.records.first.roomId;
          if (rId != null && rId.isNotEmpty) {
            currentRoomId.value = rId;
          }
          messages.assignAll(result.records);
        }

        isProcessing.value = result.records.any((m) => m.isProcessing);
      }
    } catch (e) {
      debugPrint('🤖 [AiController] Error loading history: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isSubmitting || isProcessing.value) return;

    _isSubmitting = true;

    // Optimistic user message
    final optimisticMessage = AiMessageModel(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      role: EChatRole.user.name,
      content: clean,
      createdAt: DateTime.now().toIso8601String(),
    );

    messages.removeWhere((m) => m.id == 'welcome');
    messages.add(optimisticMessage);
    isProcessing.value = true;

    try {
      final response = await _ai.chat(
        AiChatRequest(message: clean, roomId: currentRoomId.value),
      );
      if (response.success && response.data != null) {
        final rId = response.data![AiKeys.roomId]?.toString();
        if (rId != null && rId.isNotEmpty) {
          currentRoomId.value = rId;
        }
      } else {
        AppSnackbar.error(
          response.error ?? AppLocales.ai.aiSendMessageFailed.tr,
        );
        isProcessing.value = false;
      }
    } catch (e) {
      AppSnackbar.error(AppLocales.ai.aiResponseFailed.tr);
      isProcessing.value = false;
    } finally {
      _isSubmitting = false;
    }
  }

  // ============================================================
  // ROOM MANAGEMENT
  // ============================================================
  Future<void> loadRooms() async {
    try {
      final response = await _ai.getRooms();
      if (response.success) {
        rooms.assignAll(response.records);
      }
    } catch (e) {
      debugPrint('🤖 [AiController] Error loading rooms: $e');
    }
  }

  void selectRoom(AiRoomModel room) {
    currentRoomId.value = room.id;
    currentRoomTitle.value = room.title;
    loadHistory(room.id);
  }

  Future<void> createNewRoom([String? title]) async {
    try {
      final roomTitle = title ?? AppLocales.ai.newChat.tr;
      final response = await _ai.createRoom(
        CreateRoomRequest(title: roomTitle),
      );
      if (response.success && response.data != null) {
        final newRoom = response.data!;
        rooms.insert(0, newRoom);
        selectRoom(newRoom);
      }
    } catch (e) {
      debugPrint('🤖 [AiController] Error creating room: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      final response = await _ai.deleteRoom(roomId);
      if (response.success) {
        rooms.removeWhere((r) => r.id == roomId);
        if (currentRoomId.value == roomId) {
          currentRoomId.value = null;
          currentRoomTitle.value = AppLocales.ai.title.tr;
          loadHistory();
        }
      }
    } catch (e) {
      debugPrint('🤖 [AiController] Error deleting room: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final response = await _ai.clearHistory(roomId: currentRoomId.value);
      if (response.success) {
        loadHistory(currentRoomId.value);
        AppSnackbar.success(AppLocales.ai.aiHistoryCleared.tr);
      }
    } catch (e) {
      AppSnackbar.error(AppLocales.ai.aiClearHistoryFailed.tr);
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Design.timers.short,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void handleSend() {
    if (isRecording.value || activeTtsMessageId.value != null) return;
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    sendMessage(text);
    scrollToBottom();
  }

  // ============================================================
  // LIVE SPEECH
  // ============================================================
  Future<void> toggleListening() async {
    if (_speech.isListenSessionActive) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (isProcessing.value || activeTtsMessageId.value != null) return;

    _textBeforeListen = textController.text;
    _liveTextWorker?.dispose();
    _liveTextWorker = ever(_speech.liveText, _setInputText);

    final result = await _speech.startListening(seed: textController.text);
    if (result == ESpeechListenResult.started) return;

    _liveTextWorker?.dispose();
    _liveTextWorker = null;

    switch (result) {
      case ESpeechListenResult.disconnected:
        AppSnackbar.error(AppLocales.ai.aiTranscriptionFailed.tr);
      case ESpeechListenResult.permissionDenied:
        await _permissions.promptMicrophoneSettings();
      case ESpeechListenResult.failed:
        AppSnackbar.error(AppLocales.ai.aiStartRecordingFailed.tr);
      case ESpeechListenResult.alreadyListening:
      case ESpeechListenResult.started:
        break;
    }
  }

  Future<void> stopListening() async {
    _liveTextWorker?.dispose();
    _liveTextWorker = null;
    await _speech.stopListening();
  }

  Future<void> cancelListening() async {
    await stopListening();
    _setInputText(_textBeforeListen);
  }

  void _setInputText(String text) {
    textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  // ============================================================
  // TEXT-TO-SPEECH
  // ============================================================
  Future<void> speakMessage(AiMessageModel msg) async {
    if (activeTtsMessageId.value == msg.id && _speech.isPlaying.value) {
      await stopSpeaking();
      return;
    }

    await stopSpeaking();

    final audioUrl = msg.audioUrl;
    if (audioUrl != null) {
      activeTtsMessageId.value = msg.id;
      try {
        await _speech.playUrl(audioUrl);
      } catch (e) {
        debugPrint('🤖 [AiController] Error playing TTS: $e');
        AppSnackbar.error(AppLocales.ai.aiTtsFailed.tr);
        activeTtsMessageId.value = null;
      }
      return;
    }

    if (msg.content.trim().isEmpty) {
      AppSnackbar.error(AppLocales.ai.aiTtsEmpty.tr);
      return;
    }

    activeTtsMessageId.value = msg.id;
    isTtsLoading.value = true;

    try {
      final response = await _speech.textToSpeech(msg.id);
      if (!response.success) {
        AppSnackbar.error(response.error ?? response.message);
        activeTtsMessageId.value = null;
        isTtsLoading.value = false;
        return;
      }

      if (activeTtsMessageId.value != msg.id) {
        isTtsLoading.value = false;
        return;
      }

      if (response.message.isNotEmpty) {
        AppSnackbar.info(response.message);
      }
    } catch (e) {
      debugPrint('🤖 [AiController] Error queueing TTS: $e');
      AppSnackbar.error(AppLocales.ai.aiTtsFailed.tr);
      activeTtsMessageId.value = null;
      isTtsLoading.value = false;
    }
  }

  Future<void> stopSpeaking() async {
    await _speech.stopPlayback();
    isTtsLoading.value = false;
    activeTtsMessageId.value = null;
  }
}
