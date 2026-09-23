import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rexone_mobile/config/app.config.dart';
import 'package:rexone_mobile/constants/constants.dart';

/// Helper to normalize network URLs across platforms and environments.
///
/// In local development environments, backend services often return URLs referencing
/// `localhost` or `127.0.0.1` (such as Garage S3 at `http://localhost:3100`).
/// On Android emulators, `localhost` refers to the Android device itself, not the host machine.
/// This helper maps `localhost` and `127.0.0.1` to the host machine IP (`10.0.2.2` or the host
/// configured in [AppConfig.apiBaseUrl]).
class UrlHelper {
  const UrlHelper._();

  /// Normalizes a URL by mapping localhost/127.0.0.1 to the appropriate host on Android.
  ///
  /// [isAndroid] can be provided to override platform detection for testing.
  static String normalize(String url, {bool? isAndroid}) {
    if (url.isEmpty) return url;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return url;

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' &&
        scheme != 'https' &&
        scheme != 'ws' &&
        scheme != 'wss') {
      return url;
    }

    final host = uri.host.toLowerCase();
    if (host != 'localhost' && host != '127.0.0.1') {
      return url;
    }

    final onAndroid = isAndroid ?? Platform.isAndroid;
    if (!onAndroid) {
      return url;
    }

    String targetHost = '10.0.2.2';
    try {
      if (dotenv.isInitialized) {
        final apiUri = Uri.tryParse(AppConfig.apiBaseUrl);
        final configuredHost = apiUri?.host;
        if (configuredHost != null &&
            configuredHost.isNotEmpty &&
            configuredHost != 'localhost' &&
            configuredHost != '127.0.0.1') {
          targetHost = configuredHost;
        }
      }
    } catch (_) {
      // Fallback to default Android emulator host if dotenv throws or is not loaded
    }

    return uri.replace(host: targetHost).toString();
  }

  /// Normalizes a nullable URL.
  static String? normalizeNullable(String? url, {bool? isAndroid}) {
    if (url == null) return null;
    return normalize(url, isAndroid: isAndroid);
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

    final onAndroid = isAndroid ?? Platform.isAndroid;
    if (!onAndroid) return const {};

    final host = uri.host.toLowerCase();
    String? apiHost;
    try {
      if (dotenv.isInitialized) {
        apiHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host;
      }
    } catch (_) {}

    final isTargetHost =
        host == '10.0.2.2' ||
        host == '127.0.0.1' ||
        host == 'localhost' ||
        (apiHost != null && apiHost.isNotEmpty && host == apiHost);

    if (isTargetHost) {
      final portPart = uri.hasPort ? ':${uri.port}' : '';
      return {AuthHeaders.host: 'localhost$portPart'};
    }

    return const {};
  }
}
