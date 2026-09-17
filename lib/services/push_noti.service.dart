// lib/services/push_noti.service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/url_scheme_data.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/analytics.service.dart';

/// App-level notification stack: OneSignal (remote), local notifications, Live Activities.
class PushNotiService extends GetxService {
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  LiveActivities? _liveActivities;
  bool _localNotificationsReady = false;

  bool get isLocalNotificationsReady => _localNotificationsReady;

  /// Live Activity deep-link stream (Pause/Resume). Null when unavailable.
  Stream<UrlSchemeData>? liveActivityUrlSchemeStream() {
    final plugin = _liveActivities;
    if (plugin == null) return null;
    return plugin.urlSchemeStream();
  }

  @override
  void onInit() {
    super.onInit();
    _initOneSignal();
    _setupListeners();
  }

  /// Local notifications + Live Activities — call once from app startup.
  Future<void> initializePlatform() async {
    await _initializeLocalNotifications();
    await _initializeLiveActivities();
  }

  void _initOneSignal() {
    try {
      final appId = AppConfig.oneSignalAppId;
      if (appId.isNotEmpty && appId != 'one signal app id not found') {
        OneSignal.Debug.setLogLevel(
          kDebugMode ? OSLogLevel.verbose : OSLogLevel.none,
        );
        OneSignal.initialize(appId);
        debugPrint('✅ OneSignal initialized');
      } else {
        debugPrint('⚠️ OneSignal skipped: no app ID configured');
      }
    } catch (e) {
      debugPrint('❌ OneSignal init failed: $e');
    }
  }

  void _setupListeners() {
    try {
      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        final notificationId = data?[AnalyticsConstants.paramNotificationId]
            ?.toString();
        if (notificationId != null && notificationId.isNotEmpty) {
          _analytics.logOpenNotification(notificationId);
        }

        final link = data?[NotificationKeys.link]?.toString();

        if (link != null && link.isNotEmpty) {
          AppRoutes.handleNotificationLink(link);
        }
      });
    } catch (e) {
      debugPrint('❌ OneSignal listener setup failed: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings: settings);
    _localNotificationsReady = true;
    debugPrint('✅ Local notifications initialized');
  }

  Future<void> _initializeLiveActivities() async {
    if (!Platform.isIOS) return;
    try {
      _liveActivities = LiveActivities();
      await _liveActivities!.init(
        appGroupId: NotificationConstants.iosAppGroupId,
        urlScheme: NotificationConstants.iosLiveActivityUrlScheme,
      );
      debugPrint('✅ Live Activities initialized');
    } catch (error) {
      debugPrint('⚠️ Live Activities init skipped: $error');
      _liveActivities = null;
    }
  }

  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    if (!Platform.isAndroid || !_localNotificationsReady) return;
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    if (!_localNotificationsReady) return;
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> createLiveActivity(
    String activityId,
    Map<String, dynamic> data,
  ) async {
    if (!Platform.isIOS || _liveActivities == null) return;
    try {
      // createOrUpdate keeps a stable custom id (assetId) via uuid5 attributes.
      await _liveActivities!.createOrUpdateActivity(
        activityId,
        data,
        iOSEnableRemoteUpdates: false,
      );
    } catch (error) {
      debugPrint('⚠️ Live Activity create skipped: $error');
    }
  }

  Future<void> updateLiveActivity(
    String activityId,
    Map<String, dynamic> data,
  ) async {
    if (!Platform.isIOS || _liveActivities == null) return;
    try {
      await _liveActivities!.createOrUpdateActivity(
        activityId,
        data,
        iOSEnableRemoteUpdates: false,
      );
    } catch (error) {
      debugPrint('⚠️ Live Activity update skipped: $error');
    }
  }

  Future<void> endLiveActivity(String activityId) async {
    if (!Platform.isIOS || _liveActivities == null) return;
    try {
      await _liveActivities!.endActivity(activityId);
    } catch (error) {
      debugPrint('⚠️ Live Activity end skipped: $error');
    }
  }

  // Request notification permission (call after onboarding/signin)
  Future<void> requestPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
      debugPrint('✅ Push permission requested');
    } catch (e) {
      debugPrint('❌ Failed to request push permission: $e');
    }
  }

  // Sync user data with OneSignal (call after auth)
  Future<void> syncUser(UserModel user) async {
    try {
      OneSignal.login(user.id);
      await OneSignal.User.addEmail(user.email);
      // 2 ok, 4 not ok probably max 3 tags for free plan
      OneSignal.User.addTags({'username': user.username ?? ''});
      debugPrint('✅ OneSignal synced for user: ${user.email}');
    } catch (e) {
      debugPrint('❌ Failed to sync OneSignal: $e');
    }
  }

  // Clear user data (call on logout)
  Future<void> clearUser() async {
    try {
      OneSignal.logout();
      debugPrint('✅ OneSignal user cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear OneSignal: $e');
    }
  }
}
