import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

class SplashController extends GetxController with WidgetsBindingObserver {
  final VersionService _version = Get.find<VersionService>();
  final StorageService _storage = Get.find<StorageService>();
  final AuthController _auth = Get.find<AuthController>();

  final latestVersion = Rxn<VersionModel>();
  final isForceUpdateBlocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.testMode) return;
    _bootstrap();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isForceUpdateBlocked.value) {
      _recheckOnResume();
    }
  }

  Future<void> _bootstrap() async {
    await checkAppVersion();

    final version = latestVersion.value;
    if (version != null && version.mustUpdate) {
      isForceUpdateBlocked.value = true;
      return;
    }

    await navigate();
  }

  Future<void> checkAppVersion() async {
    try {
      final result = await _version.getCurrent(
        version: AppInfo.version,
        buildNumber: AppInfo.versionCode,
      );
      if (result.success && result.data != null) {
        latestVersion.value = result.data;
        _storage.setSkipPremium(result.data!.skipPremium);
      }
    } catch (error) {
      debugPrint("Error: $error");
      // Offline or unexpected errors must not block launch.
    }
  }

  Future<void> _recheckOnResume() async {
    await checkAppVersion();
    final version = latestVersion.value;
    if (version != null && !version.mustUpdate) {
      isForceUpdateBlocked.value = false;
      await navigate();
    }
  }

  Future<void> openStore() async {
    final storeUrl = latestVersion.value?.storeUrl;
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
