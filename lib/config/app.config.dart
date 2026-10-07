// lib/config/app.config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const dev = '.env.dev';
  static const uat = '.env.uat';
  static const prod = '.env.prod';

  static const development = 'development';
  static const staging = 'staging';
  static const production = 'production';
}

class AppConfig {
  const AppConfig();

  // ===== ENVIRONMENT VARIABLES =====
  /// Raw env key injected at build time via --dart-define (e.g. ".env.dev").
  static String get appEnv =>
      String.fromEnvironment(AppConstants.envKey, defaultValue: '.env.dev');

  /// Canonical environment name expected by the backend: development | staging | production.
  static String get environment => switch (appEnv) {
    AppEnvironment.dev => AppEnvironment.development,
    AppEnvironment.uat => AppEnvironment.staging,
    AppEnvironment.prod => AppEnvironment.production,
    _ => AppEnvironment.development,
  };
  static String _env(String key, [String fallback = '']) {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env[key] ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  static String get appName => _env(AppConstants.nameKey, 'App');
  static String get appVersion => AppInfo.version;

  /// Canonical brand slug (e.g. 'rexone' or 'meritmoon').
  static String get appSlug => appName
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'\s+mobile$', caseSensitive: false), '')
      .replaceAll(RegExp(r'[^a-z0-9_]'), '_');

  /// Universal offline database name (e.g. 'rexone_offline' or 'meritmoon_offline').
  static String get offlineDbName => '${appSlug}_offline';
  static String get apiBaseUrl => UrlHelper.normalizeBaseUrl(
    _env(AppConstants.apiBaseUrlKey, ''),
  );
  static String get wsBaseUrl {
    final api = apiBaseUrl;
    if (api.startsWith('${NetworkSchemes.https}://')) {
      return api.replaceFirst(
        '${NetworkSchemes.https}://',
        '${NetworkSchemes.wss}://',
      );
    } else if (api.startsWith('${NetworkSchemes.http}://')) {
      return api.replaceFirst(
        '${NetworkSchemes.http}://',
        '${NetworkSchemes.ws}://',
      );
    }
    return '${NetworkSchemes.ws}://$api';
  }

  static String get googleServerClientId =>
      _env(AppConstants.googleServerClientIdKey, '');

  static String get oneSignalAppId =>
      _env(AppConstants.oneSignalAppIdKey, '');

  static String get androidAppId =>
      _env(AppConstants.androidAppIdKey, '');

  static String get iosAppId =>
      _env(AppConstants.iosAppIdKey, '');

  static String get offlineEncryptionKey =>
      _env(AppConstants.mediaOfflineEncryptionKey, '').trim();

  static String get fromEmail =>
      _env(AppConstants.fromEmailKey, '');
}
