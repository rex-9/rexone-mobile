// lib/helpers/app_info.dart
import 'package:package_info_plus/package_info_plus.dart';

/// Centralized, high-performance cache for platform package and version metadata.
/// Initialized once during app bootstrap to eliminate redundant native channel calls.
class AppInfo {
  const AppInfo._();

  static late final PackageInfo _info;
  static bool _initialized = false;

  /// Initializes package info once during app startup.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      _info = await PackageInfo.fromPlatform();
      _initialized = true;
    } catch (_) {
      // Safe fallback in test harnesses or unsupported environments
      _info = PackageInfo(
        appName: 'RexOne',
        packageName: 'com.rex9.rexone',
        version: '1.0.0',
        buildNumber: '1',
      );
      _initialized = true;
    }
  }

  /// App name as defined in platform manifest.
  static String get appName {
    _ensureInitialized();
    return _info.appName;
  }

  /// Package name / bundle identifier (e.g. `com.rex9.rexone`).
  static String get packageName {
    _ensureInitialized();
    return _info.packageName;
  }

  /// Version semver string (e.g. `1.0.0`).
  static String get version {
    _ensureInitialized();
    return _info.version.isNotEmpty ? _info.version : '1.0.0';
  }

  /// Build number string (e.g. `1`).
  static String get buildNumber {
    _ensureInitialized();
    return _info.buildNumber.isNotEmpty ? _info.buildNumber : '1';
  }

  /// Build number integer (versionCode on Android / CFBundleVersion on iOS).
  static int get versionCode {
    _ensureInitialized();
    return int.tryParse(_info.buildNumber) ?? 1;
  }

  /// Full version with build number suffix (e.g. `1.0.0+1`).
  static String get fullVersion => '$version+$buildNumber';

  static void _ensureInitialized() {
    if (!_initialized) {
      _info = PackageInfo(
        appName: 'RexOne',
        packageName: 'com.rex9.rexone',
        version: '1.0.0',
        buildNumber: '1',
      );
      _initialized = true;
    }
  }
}
