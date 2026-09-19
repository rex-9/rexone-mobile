import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/config/app.config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/push_noti.service.dart';

/// Media-download-specific notification UX (progress Live Activity + complete/fail).
/// Platform plugins live in [PushNotiService].
class MediaDownloadNotificationService extends GetxService {
  static const _liveActivityChannel = MethodChannel(
    MediaDownloadConstants.liveActivityMethodChannel,
  );

  late final PushNotiService _pushNoti;
  final Set<String> _liveActivityAssetIds = {};

  @override
  void onInit() {
    super.onInit();
    _pushNoti = Get.find<PushNotiService>();
  }

  @override
  void onClose() {
    if (Platform.isIOS) {
      _liveActivityChannel.setMethodCallHandler(null);
    }
    super.onClose();
  }

  Future<void> initialize() async {
    FileDownloader().configureNotificationForGroup(
      MediaDownloadConstants.downloadTaskGroup,
      running: TaskNotification(
        AppConfig.appName,
        '{displayName} · {progress}',
      ),
      complete: TaskNotification(
        AppConfig.appName,
        '{displayName}',
      ),
      error: TaskNotification(
        AppConfig.appName,
        '{displayName}',
      ),
      progressBar: true,
    );

    await _pushNoti.createAndroidChannel(
      AndroidNotificationChannel(
        MediaDownloadConstants.notificationChannelId,
        AppLocales.media.notificationChannelName.tr,
        description: AppLocales.media.notificationChannelDescription.tr,
        importance: Importance.defaultImportance,
      ),
    );

    if (Platform.isIOS) {
      _liveActivityChannel.setMethodCallHandler(_onLiveActivityMethodCall);
      await _drainPendingLiveActivityAction();
    }
  }

  Future<void> onDownloadStarted({
    required String assetId,
    required String title,
  }) async {
    await _pushNoti.createLiveActivity(assetId, {
      MediaDownloadConstants.metaAssetId: assetId,
      MediaDownloadConstants.metaTitle: title,
      MediaDownloadConstants.metaProgress: 0,
      MediaDownloadConstants.metaPaused: false,
    });
    _liveActivityAssetIds.add(assetId);
  }

  Future<void> onDownloadProgress({
    required String assetId,
    required String title,
    required double progress,
    bool paused = false,
  }) async {
    if (!_liveActivityAssetIds.contains(assetId)) return;
    await _pushNoti.updateLiveActivity(assetId, {
      MediaDownloadConstants.metaAssetId: assetId,
      MediaDownloadConstants.metaTitle: title,
      MediaDownloadConstants.metaProgress: (progress * 100).round(),
      MediaDownloadConstants.metaPaused: paused,
    });
  }

  Future<void> onDownloadPaused({
    required String assetId,
    required String title,
    required double progress,
  }) async {
    await onDownloadProgress(
      assetId: assetId,
      title: title,
      progress: progress,
      paused: true,
    );
  }

  Future<void> onDownloadFinished({
    required String assetId,
    required String title,
    required bool success,
    String? errorMessage,
  }) async {
    await _endLiveActivity(assetId);
    if (!_pushNoti.isLocalNotificationsReady) return;

    final id = assetId.hashCode & 0x7fffffff;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        MediaDownloadConstants.notificationChannelId,
        AppLocales.media.notificationChannelName.tr,
        channelDescription: AppLocales.media.notificationChannelDescription.tr,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    if (success) {
      await _pushNoti.showLocalNotification(
        id: id,
        title: AppConfig.appName,
        body: title.isEmpty
            ? AppLocales.media.downloadComplete.tr
            : AppLocales.media.downloadCompleteNamed.trParams({
                'title': title,
              }),
        details: details,
        payload: assetId,
      );
      return;
    }

    await _pushNoti.showLocalNotification(
      id: id,
      title: AppConfig.appName,
      body: errorMessage ?? AppLocales.media.downloadFailed.tr,
      details: details,
      payload: assetId,
    );
  }

  Future<void> endLiveActivityFor(String assetId) => _endLiveActivity(assetId);

  Future<void> endAllLiveActivities() async {
    final ids = List<String>.from(_liveActivityAssetIds);
    for (final assetId in ids) {
      await _endLiveActivity(assetId);
    }
  }

  Future<void> _endLiveActivity(String assetId) async {
    if (!_liveActivityAssetIds.remove(assetId)) return;
    await _pushNoti.endLiveActivity(assetId);
  }

  Future<dynamic> _onLiveActivityMethodCall(MethodCall call) async {
    if (call.method != MediaDownloadConstants.liveActivityMethodAction) {
      return null;
    }
    final args = call.arguments;
    if (args is! Map) return null;
    await _handleLiveActivityAction(
      action: args[MediaDownloadConstants.iosQueryAction]?.toString(),
      assetId: args[MediaDownloadConstants.iosQueryAssetId]?.toString(),
    );
    return null;
  }

  Future<void> _drainPendingLiveActivityAction() async {
    try {
      final pending = await _liveActivityChannel.invokeMethod<dynamic>(
        MediaDownloadConstants.liveActivityMethodTakePending,
      );
      if (pending is! Map) return;
      await _handleLiveActivityAction(
        action: pending[MediaDownloadConstants.iosQueryAction]?.toString(),
        assetId: pending[MediaDownloadConstants.iosQueryAssetId]?.toString(),
      );
    } catch (error) {
      debugPrint('⚠️ Live Activity pending action skipped: $error');
    }
  }

  Future<void> _handleLiveActivityAction({
    required String? action,
    required String? assetId,
  }) async {
    if (assetId == null || assetId.isEmpty || action == null) return;
    if (!Get.isRegistered<MediaDownloadService>()) return;

    final downloads = Get.find<MediaDownloadService>();
    try {
      if (action == MediaDownloadConstants.iosActionPause) {
        await downloads.pauseDownload(assetId);
      } else if (action == MediaDownloadConstants.iosActionResume) {
        await downloads.resumeDownload(assetId);
      }
    } catch (error) {
      debugPrint('⚠️ Live Activity download action failed: $error');
    }
  }
}
