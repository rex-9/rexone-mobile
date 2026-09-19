// lib/config/app.config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rexone_mobile/constants/constants.dart';

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
  static String get appName => dotenv.env[AppConstants.nameKey] ?? 'RexOne';
  static String get appVersion =>
      dotenv.env[AppConstants.versionKey] ?? '1.0.0';
  static String get apiBaseUrl =>
      dotenv.env[AppConstants.apiBaseUrlKey] ?? 'api base url not found';
  static String get wsBaseUrl {
    final api = apiBaseUrl;
    if (api.startsWith('https://')) {
      return api.replaceFirst('https://', 'wss://');
    } else if (api.startsWith('http://')) {
      return api.replaceFirst('http://', 'ws://');
    }
    return 'ws://$api';
  }

  static String get googleServerClientId =>
      dotenv.env[AppConstants.googleServerClientIdKey] ??
      'google server client id not found';

  static String get oneSignalAppId =>
      dotenv.env[AppConstants.oneSignalAppIdKey] ??
      'one signal app id not found';

  static String get androidAppId =>
      dotenv.env[AppConstants.androidAppIdKey] ?? 'com.rexone.mobile';

  static String get iosAppId =>
      dotenv.env[AppConstants.iosAppIdKey] ?? 'com.rexone.mobile';
}
