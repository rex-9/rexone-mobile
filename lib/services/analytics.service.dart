// lib/services/analytics.service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';

class AnalyticsService extends GetxService {
  FirebaseAnalytics? _analytics;
  late final NavigatorObserver _observer = AnalyticsNavigationObserver(this);

  FirebaseAnalytics get analytics => _analytics ??= FirebaseAnalytics.instance;
  NavigatorObserver get observer => _observer;

  String get _platform => defaultTargetPlatform == TargetPlatform.iOS
      ? AnalyticsConstants.platformIos
      : AnalyticsConstants.platformAndroid;

  void logScreenView(String screenName, {String? screenClass}) {
    logViewPage(screenName, pageTitle: screenClass ?? screenName);
  }

  // ===== USER PROPERTIES =====
  void setUserId(String userId) {
    try {
      analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('❌ Analytics setUserId failed: $e');
    }
  }

  void setUserProperty(String name, String value) {
    try {
      analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('❌ Analytics setUserProperty failed: $e');
    }
  }

  void clearUserId() {
    try {
      analytics.setUserId(id: null);
    } catch (e) {
      debugPrint('❌ Analytics clearUserId failed: $e');
    }
  }

  // ===== EVENTS =====
  void logEvent(String name, {Map<String, Object>? parameters}) {
    try {
      analytics.logEvent(
        name: name,
        parameters: {
          AnalyticsConstants.paramPlatform: _platform,
          ...?parameters,
        },
      );
    } catch (e) {
      debugPrint('❌ Analytics logEvent failed: $e');
    }
  }

  // ===== AUTH EVENTS =====
  void logSignUp({String? method}) {
    logEvent(
      AnalyticsConstants.eventSignUp,
      parameters: {
        AnalyticsConstants.paramMethod:
            method ?? AnalyticsConstants.methodEmail,
      },
    );
  }

  void logSignIn({String? method}) {
    logEvent(
      AnalyticsConstants.eventSignIn,
      parameters: {
        AnalyticsConstants.paramMethod:
            method ?? AnalyticsConstants.methodEmail,
      },
    );
  }

  void logSignOut() {
    logEvent(AnalyticsConstants.eventSignOut);
  }

  void logBeginOnboarding() {
    logEvent(AnalyticsConstants.eventBeginOnboarding);
  }

  void logCompleteOnboarding() {
    logEvent(AnalyticsConstants.eventCompleteOnboarding);
  }

  void logViewPage(String pagePath, {String? pageTitle}) {
    logEvent(
      AnalyticsConstants.eventViewPage,
      parameters: {
        AnalyticsConstants.paramPagePath: pagePath,
        AnalyticsConstants.paramPageTitle: pageTitle ?? pagePath,
      },
    );
  }

  void logViewProduct({
    required String productId,
    required String productName,
  }) {
    logEvent(
      AnalyticsConstants.eventViewProduct,
      parameters: {
        AnalyticsConstants.paramProductId: productId,
        AnalyticsConstants.paramProductName: productName,
      },
    );
  }

  void logPurchaseProduct({
    required String productId,
    required String productName,
    required String currency,
    required int unitAmount,
    required String purchaseId,
  }) {
    logEvent(
      AnalyticsConstants.eventPurchaseProduct,
      parameters: {
        AnalyticsConstants.paramProductId: productId,
        AnalyticsConstants.paramProductName: productName,
        AnalyticsConstants.paramCurrency: currency,
        AnalyticsConstants.paramUnitAmount: unitAmount,
        AnalyticsConstants.paramPurchaseId: purchaseId,
      },
    );
  }

  void logOpenNotification(String notificationId) {
    logEvent(
      AnalyticsConstants.eventOpenNotification,
      parameters: {AnalyticsConstants.paramNotificationId: notificationId},
    );
  }
}

class AnalyticsNavigationObserver extends NavigatorObserver {
  AnalyticsNavigationObserver(this._analytics);

  final AnalyticsService _analytics;

  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    _analytics.logViewPage(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _track(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute);
  }
}
