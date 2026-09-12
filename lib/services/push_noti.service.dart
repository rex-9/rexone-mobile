// lib/services/push_noti.service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/analytics.service.dart';

class PushNotiService extends GetxService {
  final AnalyticsService _analytics = Get.find<AnalyticsService>();

  @override
  void onInit() {
    super.onInit();
    _initOneSignal();
    _setupListeners();
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
