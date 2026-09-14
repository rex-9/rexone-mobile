// lib/constants/analytics.constants.dart

class AnalyticsConstants {
  const AnalyticsConstants._();

  // Shared Rexone analytics contract. Every event uses action_noun format.
  static const String eventSignUp = 'sign_up';
  static const String eventSignIn = 'sign_in';
  static const String eventSignOut = 'sign_out';
  static const String eventBeginOnboarding = 'begin_onboarding';
  static const String eventCompleteOnboarding = 'complete_onboarding';
  static const String eventViewPage = 'view_page';
  static const String eventViewProduct = 'view_product';
  static const String eventPurchaseProduct = 'purchase_product';
  static const String eventOpenNotification = 'open_notification';

  // ===== PARAMETER NAMES =====
  static const String paramMethod = 'method';
  static const String paramPlatform = 'platform';
  static const String paramPagePath = 'page_path';
  static const String paramPageTitle = 'page_title';
  static const String paramProductId = 'product_id';
  static const String paramProductName = 'product_name';
  static const String paramCurrency = 'currency';
  static const String paramUnitAmount = 'unit_amount';
  static const String paramPurchaseId = 'purchase_id';
  static const String paramNotificationId = 'notification_id';

  // ===== PARAMETER VALUES =====
  static const String methodEmail = 'email';
  static const String methodGoogle = 'google';
  static const String methodApple = 'apple';
  static const String platformAndroid = 'android';
  static const String platformIos = 'ios';
}
