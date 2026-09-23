// lib/design/components/app_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import '../design.dart';

class AppDialog {
  AppDialog._();

  static bool get isIOS => GetPlatform.isIOS;

  static Future<void> error({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return _show(
      context: context,
      title: title,
      message: message,
      background: Design.colors.error.withValues(alpha: 0.12),
      foreground: Design.colors.error,
      icon: Design.icons.error,
    );
  }

  static Future<void> success({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return _show(
      context: context,
      title: title,
      message: message,
      background: Design.colors.success.withValues(alpha: 0.12),
      foreground: Design.colors.success,
      icon: Design.icons.check,
    );
  }

  static Future<void> warning({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return _show(
      context: context,
      title: title,
      message: message,
      background: Design.colors.warning.withValues(alpha: 0.12),
      foreground: Design.colors.warning,
      icon: Design.icons.warning,
    );
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return _show(
      context: context,
      title: title,
      message: message,
      background: Design.colors.primary.withValues(alpha: 0.12),
      foreground: Design.colors.primary,
      icon: Design.icons.info,
    );
  }

  static Future<void> _show({
    required BuildContext context,
    required String title,
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
  }) {
    return _showOsDialog<void>(
      backgroundColor: background,
      title: Row(
        children: [
          Icon(icon, color: foreground),
          SizedBox(width: Design.spacing.md),
          Expanded(
            child: Text(
              title,
              style: context.typo.headline4.copyWith(color: foreground),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: context.typo.bodyMedium.copyWith(color: foreground),
      ),
      actions: [
        AppButton(type: EButtonType.text, onPressed: Get.back, text: 'OK'),
      ],
    );
  }

  /// Optional update prompt with 'Later' and 'Update' actions.
  /// Mandatory updates are handled by the sovereign full-screen SplashPage view.
  static Future<void> update({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onUpdate,
  }) {
    Get.addTranslations(AppTranslations().keys);
    final laterLabel = AppLocales.update.later.tr;
    final updateLabel = AppLocales.update.update.tr;
    final prompt = AppLocales.update.prompt.tr;
    final contentAlign = isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final content = Padding(
      padding: Design.spacing.paddingOnly(t: Design.spacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: contentAlign,
        children: [
          Text(message, style: context.typo.bodyMedium),
          Padding(
            padding: Design.spacing.paddingOnly(t: Design.spacing.lg),
            child: Text(prompt, style: context.typo.bodyMedium),
          ),
        ],
      ),
    );

    final Widget dialog;
    if (isIOS) {
      dialog = CupertinoAlertDialog(
        title: Text(title, style: context.typo.headline4),
        content: content,
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            child: Text(laterLabel),
          ),
          CupertinoDialogAction(
            onPressed: onUpdate,
            isDefaultAction: true,
            child: Text(updateLabel),
          ),
        ],
      );
    } else {
      dialog = AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Design.spacing.radiusLarge),
        ),
        title: Text(
          title,
          style: context.typo.headline4.copyWith(
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        content: content,
        actions: [
          AppButton(
            type: EButtonType.text,
            onPressed: Get.back,
            text: laterLabel,
          ),
          AppButton(
            type: EButtonType.text,
            onPressed: onUpdate,
            text: updateLabel,
          ),
        ],
      );
    }

    return Get.dialog<void>(
      dialog,
      barrierDismissible: true,
    );
  }

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
  }) async {
    Get.addTranslations(AppTranslations().keys);
    final label = confirmLabel ?? AppLocales.setting.confirmDelete.tr;
    if (isIOS) {
      final result = await Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text(title, style: context.typo.headline4),
          content: Padding(
            padding: EdgeInsets.only(top: Design.spacing.xs),
            child: Text(message, style: context.typo.bodyMedium),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              isDefaultAction: true,
              child: Text(AppLocales.common.cancel.tr),
            ),
            CupertinoDialogAction(
              onPressed: () => Get.back(result: true),
              isDestructiveAction: true,
              child: Text(label),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Design.spacing.radiusLarge),
        ),
        title: Text(
          title,
          style: context.typo.headline4.copyWith(
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: context.typo.bodyMedium.copyWith(
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          AppButton(
            type: EButtonType.text,
            onPressed: () => Get.back(result: false),
            text: AppLocales.common.cancel.tr,
          ),
          AppButton(
            type: EButtonType.text,
            onPressed: () => Get.back(result: true),
            text: label,
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> exit(BuildContext context) async {
    Get.addTranslations(AppTranslations().keys);
    if (isIOS) {
      final result = await Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text(
            AppLocales.common.exitTitle.tr,
            style: context.typo.headline4,
          ),
          content: Padding(
            padding: EdgeInsets.only(top: Design.spacing.xs),
            child: Text(
              AppLocales.common.exitConfirm.tr,
              style: context.typo.bodyMedium,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              isDefaultAction: true,
              child: Text(AppLocales.common.cancel.tr),
            ),
            CupertinoDialogAction(
              onPressed: () => Get.back(result: true),
              isDestructiveAction: true,
              child: Text(AppLocales.common.exit.tr),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Design.spacing.radiusLarge),
        ),
        title: Text(
          AppLocales.common.exitTitle.tr,
          style: context.typo.headline4.copyWith(
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocales.common.exitConfirm.tr,
          style: context.typo.bodyMedium.copyWith(
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          AppButton(
            type: EButtonType.text,
            onPressed: () => Get.back(result: false),
            text: AppLocales.common.cancel.tr,
          ),
          AppButton(
            type: EButtonType.text,
            onPressed: () => Get.back(result: true),
            text: AppLocales.common.exit.tr,
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<T?> _showOsDialog<T>({
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    Color? backgroundColor,
  }) {
    if (isIOS) {
      return Get.dialog<T>(
        CupertinoAlertDialog(
          title: title,
          content: content,
          actions: actions.map((action) {
            if (action is TextButton) {
              return CupertinoDialogAction(
                onPressed: action.onPressed,
                isDestructiveAction:
                    action.style?.foregroundColor?.resolve({}) ==
                        Design.colors.error ||
                    action.style?.foregroundColor?.resolve({}) ==
                        Colors.red,
                child: action.child ?? const Text(''),
              );
            }
            return CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            );
          }).toList(),
        ),
      );
    }
    return Get.dialog<T>(
      AlertDialog(
        backgroundColor: backgroundColor ?? Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Design.spacing.radiusLarge),
        ),
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}
