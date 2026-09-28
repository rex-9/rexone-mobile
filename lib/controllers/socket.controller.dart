// lib/controllers/socket.controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/components/components.dart';
import 'package:rexone_mobile/services/services.dart';
import '../modules/ai/ai.dart';
import '../modules/auth/auth.dart';
import '../modules/payment/payment.dart';
import '../modules/notification/notification.dart';

/// Single, permanent socket event router.
///
/// Subscribes to [SocketService.stream] once for the lifetime of the app.
/// All snackbar display and per-controller data refresh go here.
/// No other controller should call `socket.stream.listen`.
///
/// To add a new notification type: edit [_showSnackbar] and/or [_dispatch].
/// SpeechLiveChannel events are forwarded to [SpeechService].
class SocketController extends GetxController {
  late final SocketService _socket;
  StreamSubscription<SocketMessage>? _sub;

  @override
  void onInit() {
    super.onInit();
    _socket = Get.find<SocketService>();
    _sub = _socket.stream.listen(_handleEvent);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ============================================================
  // ENTRY POINT
  // ============================================================

  Future<void> _handleEvent(SocketMessage event) async {
    if (event.channel == SpeechKeys.channel ||
        ((event.channel == null || event.channel!.isEmpty) &&
            _isSpeechPayload(event))) {
      _handleSpeechEvent(event);
      return;
    }

    if (event.type != SocketKeys.notification) return;

    final eventType = EWsEventType.fromString(
      event.data?[SocketKeys.type]?.toString() ?? '',
    );
    final message = event.message ?? '';

    debugPrint('🔔 [SocketController] type=$eventType | message="$message"');

    // When IAM roles or access entitlements are revoked or changed, invalidate session so user re-authenticates fresh
    if (eventType == EWsEventType.iamUpdated ||
        eventType == EWsEventType.accessRevoked ||
        eventType == EWsEventType.accessUpdated ||
        eventType == EWsEventType.sessionExpired ||
        eventType == EWsEventType.sessionInvalidated) {
      _showSnackbar(
        eventType,
        message.isNotEmpty
            ? message
            : 'Your access has changed. Please sign in again.',
      );
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().handleSessionExpired();
      }
      return;
    }

    await _dispatch(event, eventType);
    _showSnackbar(eventType, message);
  }

  void _handleSpeechEvent(SocketMessage event) {
    final eventType = ESpeechEventType.fromString(
      event.data?[SocketKeys.type]?.toString() ?? '',
    );
    debugPrint(
      '🎤 [SocketController] speech=$eventType | message="${event.message}"',
    );

    if (Get.isRegistered<SpeechService>()) {
      Get.find<SpeechService>().onSpeechEvent(event, eventType);
    }

    if (eventType == ESpeechEventType.error) {
      final message = event.message ?? '';
      if (message.isNotEmpty) {
        AppSnackbar.error(message);
      }
    }
  }

  bool _isSpeechPayload(SocketMessage event) {
    final dataType = event.data?[SocketKeys.type]?.toString() ?? '';
    return dataType == SpeechKeys.partial ||
        dataType == SpeechKeys.finalPhrase ||
        dataType == SpeechKeys.error;
  }

  // ============================================================
  // SNACKBAR — single source of truth for all socket toasts
  // ============================================================

  void _showSnackbar(EWsEventType eventType, String message) {
    if (message.isEmpty) return;

    switch (eventType) {
      case EWsEventType.paymentSuccess:
      case EWsEventType.subscriptionCreated:
      case EWsEventType.subscriptionResumed:
      case EWsEventType.welcome:
      case EWsEventType.aiResponseReady:
      case EWsEventType.assetCompressed:
      case EWsEventType.ttsReady:
        AppSnackbar.success(message);
        break;

      case EWsEventType.paymentFailed:
      case EWsEventType.subscriptionCanceled:
      case EWsEventType.aiResponseFailed:
      case EWsEventType.assetCompressionFailed:
      case EWsEventType.ttsFailed:
        AppSnackbar.error(message);
        break;

      case EWsEventType.assetCompressing:
      case EWsEventType.signInAlert:
        AppSnackbar.info(message);
        break;

      case EWsEventType.iamUpdated:
      case EWsEventType.accessRevoked:
      case EWsEventType.sessionExpired:
        AppSnackbar.warning(message);
        break;

      default:
        AppSnackbar.info(message);
        break;
    }
  }

  // ============================================================
  // DISPATCH — per-controller data refresh / navigation
  // ============================================================

  Future<void> _dispatch(SocketMessage event, EWsEventType eventType) async {
    // --- Payment ---
    if (Get.isRegistered<PaymentController>()) {
      await Get.find<PaymentController>().onSocketEvent(
        eventType,
        event.message,
      );
    }

    // --- AI ---
    if (Get.isRegistered<AiController>()) {
      final roomId = event.data?[AiKeys.roomId]?.toString();
      final messageId = event.data?[AiKeys.messageId]?.toString();
      await Get.find<AiController>().onSocketEvent(
        eventType,
        roomId,
        messageId: messageId,
      );
    }

    // --- Notification ---
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().onSocketNotification(event);
    }
  }
}
