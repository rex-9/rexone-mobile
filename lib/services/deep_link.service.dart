// lib/services/deep_link.service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/routes/routes.dart';

class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<DeepLinkService> init() async {
    _setupDeepLinkListeners();
    return this;
  }

  void _setupDeepLinkListeners() {
    try {
      // 1. Listen for background & foreground link events
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('🔗 [DeepLinkService] Received deep link: $uri');
          _handleUri(uri);
        },
        onError: (err) {
          debugPrint('❌ [DeepLinkService] Stream error: $err');
        },
      );

      // 2. Check for cold-start initial link
      _appLinks
          .getInitialLink()
          .then((uri) {
            if (uri != null) {
              debugPrint(
                '🔗 [DeepLinkService] Received initial deep link: $uri',
              );
              _handleUri(uri);
            }
          })
          .catchError((err) {
            debugPrint('⚠️ [DeepLinkService] Initial link error: $err');
          });
    } catch (e) {
      debugPrint('⚠️ [DeepLinkService] Platform channel setup error: $e');
    }
  }

  void _handleUri(Uri uri) {
    AppRoutes.handleDeepLink(uri.toString());
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
