import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/config/app.config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/services/push_noti.service.dart';

/// Media-download-specific notification UX (progress Live Activity + complete/fail).
/// Platform plugins live in [PushNotiService].
class MediaDownloadNotificationService extends GetxService {
  late final PushNotiService _pushNoti;
  final Set<String> _liveActivityAssetIds = {};

  @override
  void onInit() {
    super.onInit();
    _pushNoti = Get.find<PushNotiService>();
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
      const AndroidNotificationChannel(
        MediaDownloadConstants.notificationChannelId,
        'Media downloads',
        description: 'Offline media download status',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> onDownloadStarted({
    required String assetId,
    required String title,
  }) async {
    await _pushNoti.createLiveActivity(assetId, {
      MediaDownloadConstants.metaAssetId: assetId,
      MediaDownloadConstants.metaTitle: title,
      'progress': 0,
    });
    _liveActivityAssetIds.add(assetId);
  }

  Future<void> onDownloadProgress({
    required String assetId,
    required String title,
    required double progress,
  }) async {
    if (!_liveActivityAssetIds.contains(assetId)) return;
    await _pushNoti.updateLiveActivity(assetId, {
      MediaDownloadConstants.metaAssetId: assetId,
      MediaDownloadConstants.metaTitle: title,
      'progress': (progress * 100).round(),
    });
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
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        MediaDownloadConstants.notificationChannelId,
        'Media downloads',
        channelDescription: 'Offline media download status',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (success) {
      await _pushNoti.showLocalNotification(
        id: id,
        title: AppConfig.appName,
        body: title.isEmpty ? 'Download complete' : '$title downloaded',
        details: details,
        payload: assetId,
      );
      return;
    }

    await _pushNoti.showLocalNotification(
      id: id,
      title: AppConfig.appName,
      body: errorMessage ?? 'Download failed',
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
}
