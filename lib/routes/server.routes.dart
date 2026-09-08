// lib/routes/server_routes.dart

class ServerRoutes {
  static const String apiVersion = '/v1';

  /// Helper to prefix versioned API routes with [apiVersion].
  /// Change [apiVersion] or override to easily replace versions.
  static String api(String path) => '$apiVersion$path';

  /// Helper to prefix versioned Admin API routes.
  static String adminApi(String path) => '$apiVersion/admin$path';

  // ============================================================
  // PUBLIC SERVER ROUTES (Authentication - Unversioned)
  // ============================================================
  static const String peekUser = '/peek';
  static const String signIn = '/signin';
  static const String signInWithToken = '/signin/token';
  static const String signInWithGoogle = '/signin/google';
  static const String signInGoogleComplete = '/signin/google/complete';
  static const String signUp = '/signup';
  static const String sendConfirmationCode = '/confirmation/send_code';
  static const String confirmCode = '/confirmation/confirm_code';
  static const String forgotPassword = '/password/forgot';
  static const String resetPassword = '/password/reset';

  // ============================================================
  // PROTECTED SERVER ROUTES (Authentication - Unversioned)
  // ============================================================
  static const String signOut = '/signout';

  // ============================================================
  // PROTECTED VERSIONED ROUTES (/v1/...)
  // ============================================================

  // Telemetry & Logs
  static String get clientLogs => api('/client/logs');

  // App versions
  static String get currentVersion => api('/client/versions/current');
  static String get userVersion => api('/client/versions/user-version');

  // Users
  static String get currentUser => api('/users/current');
  static String get currentUserIam => api('/users/current/iam');

  // Media
  static String get uploadAsset => api('/media/upload');

  // Accesses
  static String get accesses => api('/accesses');
  static String get activeAccesses => api('/accesses/active');
  static String get checkAccesses => api('/accesses/check');

  // Payments
  static String get paymentSession => api('/payment/session');
  static String paymentSessionStatus(String sessionId) =>
      api('/payment/session/$sessionId');
  static String get paymentProducts => api('/payment/products');
  static String get paymentSubscriptions => api('/payment/subscriptions');
  static String paymentSubscriptionCancel(String id) =>
      api('/payment/subscriptions/$id/cancel');
  static String paymentSubscriptionResume(String id) =>
      api('/payment/subscriptions/$id/resume');
  static String get paymentTransactions => api('/payment/transactions');

  // AI
  static String get aiChat => api('/ai/chat');
  static String get aiHistory => api('/ai/history');
  static String get aiClear => api('/ai/clear');
  static String get aiRename => api('/ai/rename');
  static String get aiRooms => api('/ai/rooms');
  static String aiDeleteRoom(String id) => api('/ai/rooms/$id');
  static String get aiSummarize => api('/ai/summarize');
  static String get aiTranslate => api('/ai/translate');
  static String get aiAnalyze => api('/ai/analyze');

  // Speech service api
  static String get textToSpeech => api('/speech/tts');
  static String get speechToText => api('/speech/stt');
  // Feedback
  static String get feedbacks => api('/feedbacks');

  // Notifications
  static String get notifications => api('/notifications');
  static String get unreadNotificationsCount => api('/notifications/unread_count');
  static String readNotification(String id) => api('/notifications/$id/read');
  static String get readAllNotifications => api('/notifications/read_all');
  static String deleteNotification(String id) => api('/notifications/$id');

  // Admin API
  static String get adminUsers => adminApi('/users');
  static String get adminFeedbacks => adminApi('/feedbacks');
  static String get adminNotifications => adminApi('/notifications');
  static String get adminNotificationsDispatch =>
      adminApi('/notifications/dispatch');
}
