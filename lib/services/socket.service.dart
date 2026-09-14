// lib/services/socket.service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';

class SocketMessage {
  final String? id;
  final String type;
  final String? title;
  final String? message;
  final String? link;
  final List<String>? clients;
  final Map<String, dynamic>? data;
  final String? createdAt;
  final String? channel;

  SocketMessage({
    this.id,
    required this.type,
    this.title,
    this.message,
    this.link,
    this.clients,
    this.data,
    this.createdAt,
    this.channel,
  });

  factory SocketMessage.fromJson(Map<String, dynamic> json, {String? channel}) {
    return SocketMessage(
      id: json[ApiKeys.id]?.toString(),
      type: json[SocketKeys.type]?.toString() ?? '',
      title: json[NotificationKeys.title]?.toString(),
      message: json[SocketKeys.message]?.toString(),
      link: json[NotificationKeys.link]?.toString(),
      clients: json[NotificationKeys.clients] is List
          ? List<String>.from(json[NotificationKeys.clients] as List)
          : null,
      data: json[SocketKeys.data] is Map
          ? Map<String, dynamic>.from(json[SocketKeys.data] as Map)
          : null,
      createdAt: json[SocketKeys.createdAt]?.toString(),
      channel: channel,
    );
  }
}

class SocketService extends GetxService with WidgetsBindingObserver {
  WebSocket? _ws;
  String? _token;
  bool _isConnecting = false;
  final RxBool isConnected = false.obs;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;
  bool _isInBackground = false;

  final StreamController<SocketMessage> _streamController =
      StreamController<SocketMessage>.broadcast();

  final Set<String> _subscribed = <String>{};
  final Map<String, Completer<bool>> _pendingSubs = {};

  Stream<SocketMessage> get stream => _streamController.stream;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    _streamController.close();
    super.onClose();
  }

  // ============================================================
  // APP LIFECYCLE — pause/resume reconnects around background events
  // (e.g. Stripe checkout, Google auth, in-app browser)
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App went to background — set flag so any _handleDone that fires
        // after this point (OS kills TCP asynchronously) won't schedule a
        // reconnect that times out while the browser is in the foreground.
        _isInBackground = true;
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        debugPrint('🔌 [SocketService] App backgrounded — reconnects paused');

      case AppLifecycleState.resumed:
        _isInBackground = false;
        if (_token != null && !isConnected.value && !_isConnecting) {
          debugPrint('🔌 [SocketService] App resumed — reconnecting...');
          _reconnectAttempts = 0;
          connect(_token);
        }

      default:
        break;
    }
  }

  // ============================================================
  // CONNECTION MANAGEMENT
  // ============================================================

  void connect(String? token) async {
    if (_isConnecting) {
      debugPrint('🔌 [SocketService] Connection already in progress');
      return;
    }

    if (token == null || token.trim().isEmpty) {
      debugPrint('🔌 [SocketService] No token provided, skipping WebSocket');
      disconnect();
      return;
    }

    final cleanToken = token.replaceAll('"', '').trim();
    if (_ws != null && isConnected.value && _token == cleanToken) {
      return;
    }

    _cleanup();
    _token = cleanToken;
    _isConnecting = true;

    final wsUrl = '${AppConfig.wsBaseUrl}/cable?token=$_token';

    debugPrint('🔌 [SocketService] Connecting to WebSocket: $wsUrl');

    try {
      _ws = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));

      _isConnecting = false;
      isConnected.value = true;
      _reconnectAttempts = 0;
      debugPrint('🔌 [SocketService] WebSocket connected successfully');

      _ws!.listen(
        _handleMessage,
        onDone: _handleDone,
        onError: _handleError,
        cancelOnError: false,
      );

      // Subscribe to NotificationChannel immediately upon opening.
      // SpeechLiveChannel is subscribed only while the mic is live.
      unawaited(subscribe(SocketKeys.notificationChannel));
    } catch (e) {
      debugPrint('🔌 [SocketService] WebSocket connection error: $e');
      _isConnecting = false;
      isConnected.value = false;
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _token = null;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _cleanup();
  }

  void _cleanup() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _failPendingSubs();

    if (_ws != null) {
      try {
        _ws!.close();
      } catch (_) {}
      _ws = null;
    }

    isConnected.value = false;
  }

  void _failPendingSubs() {
    for (final completer in _pendingSubs.values) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    _pendingSubs.clear();
    _subscribed.clear();
  }

  String _identifierFor(String channel) =>
      jsonEncode({SocketKeys.channel: channel});

  String? _channelFromIdentifier(dynamic identifier) {
    if (identifier == null) return null;
    try {
      final decoded = identifier is String
          ? jsonDecode(identifier)
          : identifier;
      if (decoded is Map) {
        return decoded[SocketKeys.channel]?.toString();
      }
    } catch (_) {}
    return null;
  }

  /// `confirm_subscription`, `false` on reject or timeout.
  Future<bool> subscribe(String channel) async {
    if (!isConnected.value) {
      debugPrint(
        '🔌 [SocketService] Cannot subscribe, socket is not connected',
      );
      return false;
    }
    if (_subscribed.contains(channel)) return true;

    final existing = _pendingSubs[channel];
    if (existing != null) return existing.future;

    final completer = Completer<bool>();
    _pendingSubs[channel] = completer;

    send({
      SocketKeys.command: SocketKeys.subscribe,
      SocketKeys.identifier: _identifierFor(channel),
    });

    try {
      return await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('🔌 [SocketService] Subscribe timeout: $channel');
      return false;
    } finally {
      if (_pendingSubs[channel] == completer) {
        _pendingSubs.remove(channel);
      }
    }
  }

  void unsubscribe(String channel) {
    send({
      SocketKeys.command: SocketKeys.unsubscribe,
      SocketKeys.identifier: _identifierFor(channel),
    });
    _subscribed.remove(channel);
    final completer = _pendingSubs.remove(channel);
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
  }

  /// Sends an Action Cable `perform` (`command: message`) on [channel].
  void perform(String channel, String action, [Map<String, dynamic>? data]) {
    send({
      SocketKeys.command: SocketKeys.message,
      SocketKeys.identifier: _identifierFor(channel),
      SocketKeys.data: jsonEncode({SpeechKeys.action: action, ...?data}),
    });
  }

  void send(Map<String, dynamic> data) {
    if (_ws != null && isConnected.value) {
      try {
        _ws!.add(jsonEncode(data));
      } catch (e) {
        debugPrint('📨 [SocketService] Failed to send message: $e');
      }
    } else {
      debugPrint('📨 [SocketService] Cannot send, socket is not connected');
    }
  }

  void _completeSubscribe(String? channel, bool success) {
    if (channel == null || channel.isEmpty) return;
    if (success) {
      _subscribed.add(channel);
    } else {
      _subscribed.remove(channel);
    }
    final completer = _pendingSubs.remove(channel);
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
  }

  // ============================================================
  // PROTOCOL & MESSAGE HANDLING
  // ============================================================

  void _handleMessage(dynamic raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw.toString());
      final frameType = data[SocketKeys.type]?.toString();
      final channel = _channelFromIdentifier(data[SocketKeys.identifier]);

      // Welcome message
      if (frameType == 'welcome') {
        debugPrint('👋 [SocketService] Action Cable welcome');
        return;
      }

      // Ping keepalive — silent
      if (frameType == 'ping') {
        return;
      }

      // Subscription confirmation
      if (frameType == 'confirm_subscription') {
        debugPrint(
          '✅ [SocketService] Subscription confirmed: ${data[SocketKeys.identifier]}',
        );
        _completeSubscribe(channel, true);
        return;
      }

      // Reject (bad token / auth failure)
      if (frameType == 'reject_subscription') {
        debugPrint(
          '🚫 [SocketService] Subscription REJECTED: ${data[SocketKeys.identifier]}',
        );
        _completeSubscribe(channel, false);
        return;
      }

      // Action Cable channel broadcast wrapper: { type: null, message: { type, message, data, created_at } }
      if (data[SocketKeys.message] != null && data[SocketKeys.message] is Map) {
        final payload = Map<String, dynamic>.from(
          data[SocketKeys.message] as Map,
        );
        final msgType = payload[SocketKeys.type]?.toString() ?? '?';
        final msgText = payload[SocketKeys.message]?.toString() ?? '';
        final msgData = payload[SocketKeys.data];
        debugPrint(
          '📨 [SocketService] Broadcast received'
          ' | channel=$channel'
          ' | type=$msgType'
          ' | message="$msgText"'
          ' | data=$msgData',
        );
        final socketMsg = SocketMessage.fromJson(payload, channel: channel);
        _notifyListeners(socketMsg);
        return;
      }

      // Unknown frame — log it so we can debug
      debugPrint(
        '⚠️ [SocketService] Unhandled frame type=$frameType | raw=$raw',
      );
    } catch (e) {
      debugPrint('⚠️ [SocketService] JSON parse error: $e | raw=$raw');
    }
  }

  void _handleDone() {
    debugPrint('🔌 [SocketService] WebSocket connection closed');
    isConnected.value = false;
    _isConnecting = false;
    _failPendingSubs();
    if (_token != null) {
      _scheduleReconnect();
    }
  }

  void _handleError(dynamic error) {
    debugPrint('❌ [SocketService] WebSocket runtime error: $error');
  }

  void _scheduleReconnect() {
    if (_isInBackground) {
      // WebSocket closed while app is backgrounded (e.g. Stripe checkout open).
      // Don't try to reconnect — didChangeAppLifecycleState(resumed) will do it.
      debugPrint(
        '🔄 [SocketService] Skipping reconnect — app is in background',
      );
      return;
    }
    if (_reconnectAttempts < _maxReconnectAttempts && _token != null) {
      _reconnectAttempts++;
      final delay = Duration(seconds: 2 * _reconnectAttempts);
      debugPrint(
        '🔄 [SocketService] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)...',
      );

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        if (_token != null && !_isInBackground) {
          connect(_token);
        }
      });
    } else {
      debugPrint('❌ [SocketService] Max reconnect attempts reached');
      _isConnecting = false;
    }
  }

  // ============================================================
  // BROADCAST
  // ============================================================

  /// Broadcasts [msg] to all [stream] subscribers.
  /// [SocketController] is the single subscriber for the app lifetime.
  void _notifyListeners(SocketMessage msg) {
    _streamController.add(msg);
  }
}
