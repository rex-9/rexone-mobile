import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rexone_mobile/constants/constants.dart';

/// Helper to normalize network URLs across platforms and environments.
///
/// In local development environments:
/// - Backend services or .env often reference `localhost` or `127.0.0.1` (such as Garage S3 or Rails API).
///   On Android emulators, `localhost` refers to the Android device itself, not the host machine,
///   so it is mapped to `10.0.2.2` (or the host configured in `API_BASE_URL`).
/// - Conversely, when `.env.dev` contains `http://10.0.2.2:3000` (for Android emulators),
///   iOS simulators cannot reach `10.0.2.2` because iOS shares the host macOS network stack.
///   On iOS, macOS, and web, `10.0.2.2` is mapped to `localhost`.
/// - Remote production/staging domains (e.g. `api.rexone.com`) and LAN IPs are preserved untouched.
class UrlHelper {
  const UrlHelper._();

  /// Normalizes a URL across Android and iOS/macOS/Web platforms.
  ///
  /// - On Android: maps `localhost` and `127.0.0.1` to `10.0.2.2` (or configured host in `API_BASE_URL`).
  /// - On non-Android (iOS, macOS, web): maps `10.0.2.2` to `localhost`.
  ///
  /// [isAndroid] and [isIOS] can be provided to override platform detection for testing.
  static String normalize(String url, {bool? isAndroid, bool? isIOS}) {
    if (url.isEmpty) return url;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return url;

    final scheme = uri.scheme.toLowerCase();
    if (scheme != NetworkSchemes.http &&
        scheme != NetworkSchemes.https &&
        scheme != NetworkSchemes.ws &&
        scheme != NetworkSchemes.wss) {
      return url;
    }

    final host = uri.host.toLowerCase();

    bool onAndroid = isAndroid ?? false;
    if (isAndroid == null) {
      try {
        onAndroid = Platform.isAndroid;
      } catch (_) {}
    }

    if (onAndroid) {
      if (host == NetworkHosts.localhost || host == NetworkHosts.loopbackIp) {
        String targetHost = NetworkHosts.androidEmulatorLoopback;
        try {
          if (dotenv.isInitialized) {
            final rawApi = dotenv.env[AppConstants.apiBaseUrlKey];
            if (rawApi != null && rawApi.isNotEmpty) {
              final apiUri = Uri.tryParse(rawApi);
              final configuredHost = apiUri?.host.toLowerCase();
              if (configuredHost != null &&
                  configuredHost.isNotEmpty &&
                  configuredHost != NetworkHosts.localhost &&
                  configuredHost != NetworkHosts.loopbackIp &&
                  configuredHost != NetworkHosts.androidEmulatorLoopback) {
                targetHost = configuredHost;
              }
            }
          }
        } catch (_) {
          // Fallback to default Android emulator host if dotenv throws or is not loaded
        }

        return uri.replace(host: targetHost).toString();
      }
      return url;
    }

    // Non-Android platforms (iOS simulator, macOS, web):
    // Map Android emulator loopback host (10.0.2.2) back to host machine's localhost.
    if (host == NetworkHosts.androidEmulatorLoopback) {
      return uri.replace(host: NetworkHosts.localhost).toString();
    }

    return url;
  }

  /// Normalizes a nullable URL.
  static String? normalizeNullable(
    String? url, {
    bool? isAndroid,
    bool? isIOS,
  }) {
    if (url == null) return null;
    return normalize(url, isAndroid: isAndroid, isIOS: isIOS);
  }

  /// Normalizes base URLs such as [AppConfig.apiBaseUrl] across platforms.
  static String normalizeBaseUrl(
    String url, {
    bool? isAndroid,
    bool? isIOS,
  }) {
    return normalize(url, isAndroid: isAndroid, isIOS: isIOS);
  }

  /// Returns HTTP headers required for local development services (e.g. AWS SigV4 compatibility).
  ///
  /// When URLs referencing `localhost` are rewritten to `10.0.2.2` on Android, AWS S3 / Garage SigV4
  /// validates the `Host` header against what was signed by the server (`localhost:3100`).
  /// Providing `Host: localhost:PORT` ensures signature verification succeeds.
  static Map<String, String> headersFor(String url, {bool? isAndroid}) {
    if (url.isEmpty) return const {};

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return const {};

    bool onAndroid = isAndroid ?? false;
    if (isAndroid == null) {
      try {
        onAndroid = Platform.isAndroid;
      } catch (_) {}
    }
    if (!onAndroid) return const {};

    final host = uri.host.toLowerCase();
    String? apiHost;
    try {
      if (dotenv.isInitialized) {
        final rawApi = dotenv.env[AppConstants.apiBaseUrlKey];
        if (rawApi != null && rawApi.isNotEmpty) {
          apiHost = Uri.tryParse(rawApi)?.host;
        }
      }
    } catch (_) {}

    final isTargetHost =
        host == NetworkHosts.androidEmulatorLoopback ||
        host == NetworkHosts.loopbackIp ||
        host == NetworkHosts.localhost ||
        (apiHost != null && apiHost.isNotEmpty && host == apiHost);

    if (isTargetHost) {
      final portPart = uri.hasPort ? ':${uri.port}' : '';
      return {AuthHeaders.host: '${NetworkHosts.localhost}$portPart'};
    }

    return const {};
  }
}
