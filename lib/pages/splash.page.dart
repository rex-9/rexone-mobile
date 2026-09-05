// lib/modules/splash/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../../../design/design.dart';

/// Entry point page. Reacts to [AuthController.isLoggedIn] via GetX workers
class SplashPage extends GetView<AuthController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Run once after first frame: wait for auth check then navigate.
    // Using ever() would re-fire on every login/logout; a one-shot
    // addPostFrameCallback + direct read is the right tool here.
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());

    return AppPage(
      backgroundColor: context.colors.background,
      child: const Center(
        child: AppLoading(type: LoadingType.pulse, size: LoadingSize.xlarge),
      ),
    );
  }

  Future<void> _navigate() async {
    final storage = Get.find<StorageService>();

    // Give AuthController.checkAuthStatus() a tick to finish if it was
    // triggered in onInit before the widget tree was ready.
    await Future.delayed(const Duration(milliseconds: 10));


    if (controller.isLoggedIn.value) {
      final stack = storage.getRouteStack();
      const protectedRoutes = [
        AppRoutes.home,
        AppRoutes.settings,
        AppRoutes.payment,
        AppRoutes.ai,
      ];

      if (stack.isNotEmpty && protectedRoutes.contains(stack.last)) {
        Get.offAllNamed(stack.last);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      storage.clearRouteStack();
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
