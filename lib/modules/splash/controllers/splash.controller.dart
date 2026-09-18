import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

class SplashController extends GetxController {
  final VersionService _version = Get.find<VersionService>();
  final StorageService _storage = Get.find<StorageService>();
  final AuthController _auth = Get.find<AuthController>();

  final latestVersion = Rxn<VersionModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.testMode) return;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await checkAppVersion();
    await promptUpdateIfNeeded();
    await navigate();
  }

  Future<void> checkAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.isNotEmpty
          ? info.version
          : AppConfig.appVersion;
      final result = await _version.getCurrent(version);
      if (result.success && result.data != null) {
        latestVersion.value = result.data;
        _storage.setSkipPremium(result.data!.skipPremium);
      }
    } catch (error) {
      debugPrint("Error: $error");
      // Offline or unexpected errors must not block launch.
    }

  }

  Future<void> promptUpdateIfNeeded() async {
    final version = latestVersion.value;
    final context = Get.context;
    if (version == null || !version.updateRequired || context == null) return;

    final title = version.title?.trim();
    final message = version.description?.trim();

    await AppDialog.update(
      context: context,
      title: (title != null && title.isNotEmpty)
          ? title
          : AppLocales.update.title.tr,
      message: (message != null && message.isNotEmpty)
          ? message
          : AppLocales.update.message.tr,
      mustUpdate: version.mustUpdate,
      onUpdate: () => _openStore(version.storeUrl),
    );
  }

  Future<void> _openStore(String? storeUrl) async {
    if (storeUrl == null || storeUrl.isEmpty) return;
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> navigate() async {
    // Give AuthController.checkAuthStatus() a tick to finish if it was
    // triggered in onInit before the widget tree was ready.
    await Future.delayed(const Duration(milliseconds: 10));

    if (_auth.isLoggedIn.value) {
      _storage.saveRouteStack([AppRoutes.home]);
      AppRoutes.toHome();
    } else {
      _storage.clearRouteStack();
      AppRoutes.toAuth();
    }
  }
}
