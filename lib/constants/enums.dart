enum EPeekedUserStatus {
  error, // API call failed
  exists, // User exists and is confirmed
  existsUnconfirmed, // User exists but not confirmed (incomplete onboarding)
  notExists, // User does not exist
}

enum EButtonType { primary, neon, secondary, tertiary, text, icon, google }

enum EAuthProvider { email, google }

enum EChatRole { system, user, assistant }

enum EAiMessageStatus { queued, processing, completed, failed }

enum EThemePreference { light, dark }

enum EWsEventType {
  paymentSuccess('payment_success'),
  subscriptionCreated('subscription_created'),
  subscriptionUpdated('subscription_updated'),
  paymentIntentSucceeded('payment_intent.succeeded'),
  paymentFailed('payment_failed'),
  paymentIntentPaymentFailed('payment_intent.payment_failed'),
  subscriptionCanceled('subscription_canceled'),
  subscriptionResumed('subscription_resumed'),

  welcome('welcome'),
  aiResponseReady('ai_response_ready'),
  aiResponseFailed('ai_response_failed'),
  ttsReady('tts_ready'),
  ttsFailed('tts_failed'),
  inAppNotification('in_app_notification'),

  assetCompressing('asset_compressing'),
  assetCompressed('asset_compressed'),
  assetCompressionFailed('asset_compression_failed'),
  signInAlert('sign_in_alert'),

  unknown('unknown');

  final String value;
  const EWsEventType(this.value);

  factory EWsEventType.fromString(String value) {
    return EWsEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EWsEventType.unknown,
    );
  }
}

enum ESpeechListenResult {
  started,
  alreadyListening,
  disconnected,
  permissionDenied,
  failed,
}

enum ESpeechEventType {
  partial('partial'),
  finalPhrase('final'),
  error('error'),
  unknown('unknown');

  final String value;
  const ESpeechEventType(this.value);

  factory ESpeechEventType.fromString(String value) {
    return ESpeechEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ESpeechEventType.unknown,
    );
  }
}

enum EMediaDownloadState {
  none,
  queued,
  downloading,
  paused,
  processing,
  ready,
  failed;

  String get storageValue => name;

  static EMediaDownloadState fromStorage(String? value) {
    if (value == null || value.isEmpty) return EMediaDownloadState.none;
    return EMediaDownloadState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => EMediaDownloadState.none,
    );
  }
}
