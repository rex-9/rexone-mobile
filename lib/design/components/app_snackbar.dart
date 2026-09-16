// lib/design/components/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import '../design.dart';

class AppSnackbar {
  AppSnackbar._();

  static bool get isIOS => GetPlatform.isIOS;

  static void error(String message, {dynamic e, StackTrace? stk}) {
    _logError(message, e, stk);
    _show(
      title: AppLocales.common.error.tr,
      message: message,
      background: Design.colors.error.withValues(alpha: 0.12),
      foreground: Design.colors.error,
      icon: Design.icons.error,
    );
  }

  static void success(String message) {
    _show(
      title: AppLocales.common.success.tr,
      message: message,
      background: Design.colors.success.withValues(alpha: 0.12),
      foreground: Design.colors.success,
      icon: Design.icons.check,
    );
  }

  static void warning(String message) {
    _show(
      title: AppLocales.common.warning.tr,
      message: message,
      background: Design.colors.warning.withValues(alpha: 0.12),
      foreground: Design.colors.warning,
      icon: Design.icons.warning,
    );
  }

  static void info(String message) {
    _show(
      title: AppLocales.common.info.tr,
      message: message,
      background: Design.colors.primary.withValues(alpha: 0.12),
      foreground: Design.colors.primary,
      icon: Design.icons.info,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
  }) {
    _showOsSnackbar(
      title: title,
      message: message,
      background: background,
      foreground: foreground,
      icon: icon,
    );
  }

  // ===== PRIVATE LOGGING =====
  static void _logError(String message, dynamic e, StackTrace? stk) {
    if (Get.testMode) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '═══════════════════════════════════════════════════════════',
    );
    buffer.writeln('❌ ERROR ===> $message');
    buffer.writeln(
      '───────────────────────────────────────────────────────────',
    );

    buffer.writeln('📦 Error ===> $e');
    buffer.writeln('📦 Type ===> ${e.runtimeType}');

    if (stk != null) {
      buffer.writeln(
        '───────────────────────────────────────────────────────────',
      );
      buffer.writeln('📚 Stack Trace:');
      buffer.writeln(stk.toString());
    }

    // Print to console
    debugPrint(buffer.toString());

    // Optional: Send to crash reporting service
    // Crashlytics.instance.recordError(e, stk, reason: message);
  }

  static void _showOsSnackbar({
    required String title,
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
    Duration? duration,
  }) {
    if (isIOS) {
      _showCupertinoSnackbar(
        title: title,
        message: message,
        background: background,
        foreground: foreground,
        icon: icon,
        duration: duration,
      );
    } else {
      _showMaterialSnackbar(
        title: title,
        message: message,
        background: background,
        foreground: foreground,
        icon: icon,
        duration: duration,
      );
    }
  }

  static void _showCupertinoSnackbar({
    required String title,
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
    Duration? duration,
  }) {
    final context = Get.context;
    if (context == null) return;

    Get.closeAllSnackbars();

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      titleText: Row(
        children: [
          Icon(icon, color: foreground, size: 20),
          SizedBox(width: Design.spacing.sm),
          Expanded(
            child: Text(
              title,
              style: Design.typo.labelLarge.copyWith(color: foreground),
            ),
          ),
        ],
      ),
      messageText: Text(
        message,
        style: Design.typo.bodyMedium.copyWith(color: foreground),
      ),
      backgroundColor: background,
      margin: EdgeInsets.all(Design.spacing.lg),
      borderRadius: Design.spacing.radiusMedium,
      duration: duration ?? Design.timers.snackbar,
      padding: EdgeInsets.symmetric(
        horizontal: Design.spacing.lg,
        vertical: Design.spacing.md,
      ),
      borderColor: foreground.withValues(alpha: 0.25),
      borderWidth: 1,
    );
  }

  static void _showMaterialSnackbar({
    required String title,
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
    Duration? duration,
  }) {
    final context = Get.context;
    if (context == null) return;

    Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: background,
      colorText: foreground,
      margin: EdgeInsets.all(Design.spacing.lg),
      borderRadius: Design.spacing.radiusMedium,
      duration: duration ?? Design.timers.snackbar,
      icon: Icon(icon, color: foreground),
      borderColor: foreground.withValues(alpha: 0.25),
      borderWidth: 1,
      titleText: Text(
        title,
        style: Design.typo.labelLarge.copyWith(color: foreground),
      ),
      messageText: Text(
        message,
        style: Design.typo.bodyMedium.copyWith(color: foreground),
      ),
    );
  }
}
