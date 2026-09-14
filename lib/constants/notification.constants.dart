// lib/constants/notification.constants.dart

/// Cross-platform notification filters and socket message types.
class NotificationConstants {
  const NotificationConstants._();

  // Filters
  static const String filterAll = 'all';
  static const String filterUnread = 'unread';
  static const String filterRead = 'read';

  static const List<String> allFilters = [filterAll, filterUnread, filterRead];

  // Real-time socket message types
  static const String paymentSuccess = 'payment_success';
  static const String subscriptionCreated = 'subscription_created';
  static const String subscriptionResumed = 'subscription_resumed';
  static const String welcome = 'welcome';
  static const String aiResponseReady = 'ai_response_ready';
  static const String assetCompressed = 'asset_compressed';
  static const String paymentFailed = 'payment_failed';
  static const String subscriptionCanceled = 'subscription_canceled';
  static const String aiResponseFailed = 'ai_response_failed';
  static const String assetCompressionFailed = 'asset_compression_failed';
  static const String assetCompressing = 'asset_compressing';
  static const String signInAlert = 'sign_in_alert';
  static const String iamUpdated = 'iam_updated';

  static const String externalLinkScheme = 'https';
}
