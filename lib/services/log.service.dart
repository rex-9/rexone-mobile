// lib/services/log.service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

class LogService extends GetxService {
  late final ApiService _api;
  final Set<String> _recentLogKeys = {};

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  // ============================================================
  // ERROR HOOKS (Main / Flutter)
  // ============================================================

  /// Captures Flutter widget build and rendering errors.
  static void reportFlutterError(FlutterErrorDetails details) {
    if (_isIgnoredError(details.exceptionAsString(), details.stack)) {
      return;
    }

    try {
      final service = Get.isRegistered<LogService>()
          ? Get.find<LogService>()
          : null;

      if (service == null) return;

      service.logError(
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
        context: {
          LogConstants.library: details.library ?? LogConstants.flutterFramework,
          LogConstants.context: details.context?.toDescription(),
          LogConstants.summary: details.summary.toString(),
        },
        severity: 'error',
      );
    } catch (e) {
      debugPrint('[LogService] Error while reporting flutter error: $e');
    }
  }

  /// Captures unhandled asynchronous framework/platform errors.
  static void reportPlatformError(Object error, StackTrace stackTrace) {
    if (_isIgnoredError(error.toString(), stackTrace)) {
      return;
    }

    try {
      final service = Get.isRegistered<LogService>()
          ? Get.find<LogService>()
          : null;

      if (service == null) return;

      service.logError(
        error.toString(),
        error: error,
        stackTrace: stackTrace,
        context: {LogConstants.source: LogConstants.platformDispatcherError},
        severity: 'error',
      );
    } catch (e) {
      debugPrint('[LogService] Error while reporting platform error: $e');
    }
  }

  // ============================================================
  // EXPLICIT LOGGERS
  // ============================================================

  /// Log local storage corruption or cache mismatch issues.
  Future<void> logStorageIssue(
    String key,
    dynamic expected,
    dynamic actual, [
    Map<String, dynamic>? extraContext,
  ]) async {
    await logError(
      'Storage mismatch / corruption for key: $key',
      context: {
        SocketKeys.type: LogConstants.storageIssue,
        'storageKey': key,
        'expectedValue': expected?.toString(),
        'actualValue': actual?.toString(),
        ...?extraContext,
      },
      severity: 'error',
    );
  }

  /// Central logging dispatcher with deduplication and device metadata.
  Future<void> logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String severity = 'error',
  }) async {
    // Deduplication check (avoid flooding the server for repetitive render loops)
    final dedupeKey = '${message.trim()}:${Get.currentRoute}';
    if (_recentLogKeys.contains(dedupeKey)) {
      return;
    }
    _recentLogKeys.add(dedupeKey);
    // Clear dedupe entry after 30 seconds
    Timer(const Duration(seconds: 30), () {
      _recentLogKeys.remove(dedupeKey);
    });

    try {
      final List<String> stackList = [];
      if (stackTrace != null) {
        stackList.addAll(
          stackTrace
              .toString()
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .take(20),
        );
      }

      final storageKeys = _getStorageKeys();

      final logContext = <String, dynamic>{
        ...?context,
        LogKeys.buildNumber: AppInfo.versionCode,
        LogKeys.fullVersion: AppInfo.fullVersion,
      };

      final log = LogModel(
        message: message,
        severity: severity,
        platform: GetPlatform.isIOS
            ? LogConstants.ios
            : (GetPlatform.isAndroid ? LogConstants.android : LogConstants.mobile),
        environment: AppConfig.environment,
        appVersion: AppInfo.version,
        os: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        device: GetPlatform.isIOS ? LogConstants.appleDevice : LogConstants.androidDevice,
        url: Get.currentRoute.isNotEmpty ? Get.currentRoute : '/',
        method: LogConstants.appEvent,
        stackTrace: stackList,
        localStorageKeys: storageKeys,
        context: logContext,
      );

      await _api.post(
        ServerRoutes.clientLogs,
        {LogKeys.log: log.toJson()},
        showLoading: false,
      );
    } catch (e) {
      // Fail silently to never impact user experience
      debugPrint('[LogService] Failed to send client log: $e');
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Returns whether this error is a normal API / network failure that should NOT be logged.
  static bool _isIgnoredError(String errorString, StackTrace? stack) {
    final lower = errorString.toLowerCase();
    final stackString = stack?.toString().toLowerCase() ?? '';

    // Ignore benign framework warnings
    if (lower.contains('listtile background color or ink splashes may be invisible')) {
      return true;
    }

    // Ignore HTTP/API network request failures
    if (lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('handshakeexception') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('network is unreachable') ||
        lower.contains('getconnect') ||
        stackString.contains('api.service.dart') ||
        stackString.contains('package:http') ||
        stackString.contains('dart:io/_http')) {
      return true;
    }

    return false;
  }

  /// Extracts the active keys present in local storage.
  List<String> _getStorageKeys() {
    try {
      final box = GetStorage();
      final keys = box.getKeys();
      return keys.map((k) => k.toString()).toList();
    } catch (_) {
      return [];
    }
  }
}
