// lib/design/components/access_gate.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/modules/auth/controllers/auth.controller.dart';

class AccessGate extends StatelessWidget {
  final String productId;
  final Widget child;
  final Widget? fallback;

  const AccessGate({
    super.key,
    required this.productId,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      return fallback ?? const SizedBox.shrink();
    }
    final authController = Get.find<AuthController>();
    return Obx(() {
      final hasAccess = authController.hasAccess(productId);
      if (hasAccess) {
        return child;
      }
      return fallback ?? const SizedBox.shrink();
    });
  }
}
