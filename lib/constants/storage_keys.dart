// lib/constants/storage_keys.dart

/// Centralized local storage keys matching rexone-web StorageKeys.
/// Prevents cross-platform state divergence and typo-related bugs.
class StorageKeys {
  const StorageKeys._();

  // Core Shared Keys (matching web StorageKeys exactly)
  static const locale = 'locale';
  static const token = 'token';
  static const user = 'user';
  static const theme = 'theme';

  // Mobile-specific session & navigation keys
  static const routes = 'routes';
  static const userEmail = 'user_email';
  static const remainingAttempts = 'remainingAttempts';
  static const hasFailureHistory = 'hasFailureHistory';
  static const skipPremium = 'skip_premium';
  static const audioSession = 'audio_session';
}
