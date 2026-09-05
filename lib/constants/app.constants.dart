// lib/constants/app.constants.dart
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  const AppConstants._();

  // ===== ENVIRONMENT KEYS =====
  static String get envKey => 'APP_ENV';
  static String get nameKey => 'APP_NAME';
  static String get versionKey => 'APP_VERSION';
  static String get apiBaseUrlKey => 'API_BASE_URL';
  static String get googleServerClientIdKey => 'GOOGLE_SERVER_CLIENT_ID';
  static String get oneSignalAppIdKey => 'ONE_SIGNAL_APP_ID';
  static String get androidAppIdKey => 'ANDROID_APP_ID';
  static String get iosAppIdKey => 'IOS_APP_ID';

  // ===== VERSIONS from pubspec.yaml (Runtime) =====
  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  Future<String> getFullVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  // Validation Rules
  static const minPasswordLength = 6;
  static const maxPasswordLength = 6;
  static const minUsernameLength = 3;
  static const maxUsernameLength = 20;
  static const minNameLength = 2;
  static const maxNameLength = 50;

  // HTTP Headers
  static const headerContentType = 'Content-Type';
  static const headerAccept = 'Accept';
  static const headerAuthorization = 'Authorization';
  static const headerXPlatform = 'X-Platform';
  static const headerXLocale = 'X-Locale';
  static const headerAcceptLanguage = 'Accept-Language';
  static const contentTypeJson = 'application/json';
  static const platformAndroid = 'android';
  static const platformIos = 'ios';
  static const platformWeb = 'web';
  static const platformMobile = 'mobile';
  static const bearerPrefix = 'Bearer ';


  // Chat voice
  static const chatVoiceLevelBarCount = 12;
  static const chatInputMaxLines = 5;
  static const speechSampleRate = 16000;
  static const speechNumChannels = 1;
  // 100ms of 16 kHz 16-bit mono PCM.
  static const speechChunkBytes = 3200;

  /// Dynamic runtime platform identifier (android / ios / web)
  static String get currentPlatform {
    try {
      if (Platform.isIOS) return platformIos;
      if (Platform.isAndroid) return platformAndroid;
    } catch (_) {
      // In web or tests where Platform isn't supported
    }
    return platformAndroid;
  }
}
