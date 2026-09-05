// lib/routes/route_guard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/services/services.dart';
import '../modules/auth/auth.dart';
import 'app.routes.dart';

class GuardRoutes extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final storage = Get.find<StorageService>();
    final isLoggedIn = authController.isLoggedIn.value;

    // ===== AUTH-PROTECTED ROUTES =====
    // Requires a valid session. Unauthenticated users are sent to /auth.
    // NOTE: checkout is intentionally excluded from stackTrackedRoutes below
    //       — it is ephemeral and must not be restored after login.
    const authRequiredRoutes = [
      AppRoutes.home,
      AppRoutes.settings,
      AppRoutes.payment,
      AppRoutes.checkout,
      AppRoutes.ai,
      AppRoutes.profile,
      AppRoutes.notifications,
    ];

    // ===== STACK-TRACKED ROUTES =====
    // Their position in the navigation history is persisted and restored after login.
    // Transient routes like /checkout must NOT be added here.
    const stackTrackedRoutes = [
      AppRoutes.home,
      AppRoutes.settings,
      AppRoutes.payment,
      AppRoutes.ai,
      AppRoutes.notifications,
    ];

    // Redirect unauthenticated access to auth
    if (route != null && authRequiredRoutes.contains(route) && !isLoggedIn) {
      storage.clearRouteStack();
      return const RouteSettings(name: AppRoutes.auth);
    }

    // If already logged in and landing on auth page — restore last tracked route
    if (route == AppRoutes.auth && isLoggedIn) {
      final stack = storage.getRouteStack();
      if (stack.isNotEmpty) {
        return RouteSettings(name: stack.last);
      }
      return const RouteSettings(name: AppRoutes.home);
    }

    // Maintain the navigation stack for tracked routes only
    if (route != null && stackTrackedRoutes.contains(route) && isLoggedIn) {
      final stack = storage.getRouteStack();

      if (route == AppRoutes.home) {
        // Home is always the stack root
        storage.saveRouteStack([AppRoutes.home]);
        return null;
      }

      // Ensure home is always the base; move route to the top
      if (stack.isEmpty) {
        storage.saveRouteStack([AppRoutes.home, route]);
      } else if (stack.last != route) {
        if (stack.contains(route)) stack.remove(route);
        stack.add(route);
        storage.saveRouteStack(stack);
      }
    }

    return null;
  }
}
