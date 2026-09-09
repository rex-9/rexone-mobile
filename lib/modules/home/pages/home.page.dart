// lib/modules/home/pages/home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../../auth/auth.dart';
import '../../notification/notification.dart';

class HomePage extends GetView<AuthController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppLocales.common.home.tr,
      actions: [
        Obx(() {
          final count = Get.isRegistered<NotificationController>()
              ? Get.find<NotificationController>().unreadCount.value
              : 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              AppButton(
                type: EButtonType.icon,
                icon: count > 0 ? Design.icons.bellActive : Design.icons.bell,
                onPressed: AppRoutes.toNotifications,
                tooltip: AppLocales.notification.title.tr,
                color: count > 0 ? context.colors.primary : null,
              ),
              if (count > 0)
                Positioned(
                  right: Design.spacing.xs,
                  top: Design.spacing.xs,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Design.spacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.error,
                      borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
                    ),
                    constraints: BoxConstraints(
                      minWidth: Design.spacing.lg,
                      minHeight: Design.spacing.lg,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: context.typo.caption.copyWith(
                        color: context.colors.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        AppButton(
          type: EButtonType.icon,
          icon: Design.icons.settings,
          onPressed: AppRoutes.toSettings,
          tooltip: AppLocales.setting.settings.tr,
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocales.common.welcomeHome.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.lg),
              Obx(
                () => Column(
                  children: [
                    if (controller.currentUser.value?.photo != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          controller.currentUser.value!.photo!,
                        ),
                      ),
                    SizedBox(height: Design.spacing.md),
                    Text(
                      controller.currentUser.value?.name ??
                          controller.currentUser.value?.username ??
                          controller.currentUser.value?.email ??
                          AppLocales.common.loading.tr,
                      style: context.typo.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Design.spacing.xs),
                    Text(
                      controller.currentUser.value?.email ??
                          AppLocales.common.loading.tr,
                      style: context.typo.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Design.spacing.xxxl),

              // ── Navigation Actions ─────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!controller.skipPremium) ...[
                      AppButton(
                        type: EButtonType.secondary,
                        text: '💳 ${AppLocales.payment.upgradePlan.tr}',
                        onPressed: AppRoutes.toPayment,
                      ),
                      SizedBox(height: Design.spacing.md),
                    ],
                    AppButton(
                      type: EButtonType.secondary,
                      text: '🤖 ${AppLocales.ai.title.tr}',
                      onPressed: AppRoutes.toAi,
                    ),
                    SizedBox(height: Design.spacing.md),
                    AppButton(
                      type: EButtonType.secondary,
                      text: AppLocales.audio.title.tr,
                      icon: Design.icons.playlist,
                      onPressed: AppRoutes.toAudioPlaylist,
                    ),
                    SizedBox(height: Design.spacing.lg),
                    AppButton(
                      type: EButtonType.text,
                      text: AppLocales.common.signOut.tr,
                      onPressed: () async {
                        final ok = await AppDialog.confirm(
                          context: context,
                          title: AppLocales.common.signOut.tr,
                          message: AppLocales.setting.logoutConfirmation.tr,
                          confirmLabel: AppLocales.common.signOut.tr,
                        );
                        if (ok) controller.signOut();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: Design.spacing.xxxl),

              // ── Dev: Log Service Triggers ──────────────────
              // Hide behind a debug flag before production.
              if (kDebugMode) ...[
                Divider(color: context.colors.divider),
                SizedBox(height: Design.spacing.md),
                Text(
                  '🐛 Dev — Log Service Tests',
                  style: context.typo.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: Design.spacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        type: EButtonType.secondary,
                        text: '📋 Send Manual Test Log',
                        onPressed: () => _sendTestLog(),
                      ),
                      SizedBox(height: Design.spacing.sm),
                      AppButton(
                        type: EButtonType.secondary,
                        text: '💥 Trigger Flutter Error',
                        onPressed: () => _triggerFlutterError(),
                      ),
                      SizedBox(height: Design.spacing.sm),
                      AppButton(
                        type: EButtonType.secondary,
                        text: '⚡ Trigger Dart Async Error',
                        onPressed: () => _triggerDartError(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Design.spacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Log Service Test Helpers ─────────────────────────────────

  Future<void> _sendTestLog() async {
    try {
      final log = Get.find<LogService>();
      await log.logError(
        'Manual test log from HomePage',
        context: {
          'source': 'dev_button',
          'route': Get.currentRoute,
          'user': controller.currentUser.value?.email ?? 'unknown',
        },
        severity: 'info',
      );
      AppSnackbar.success('Test log sent to backend');
    } catch (e) {
      AppSnackbar.error('Failed: $e');
    }
  }

  void _triggerFlutterError() {
    // Throws inside a widget build context — caught by FlutterError.onError
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: Exception('Dev-triggered Flutter error from HomePage'),
        stack: StackTrace.current,
        library: 'dev_test',
        context: ErrorDescription('Log service trigger button'),
      ),
    );
    AppSnackbar.success('Flutter error reported — check backend logs');
  }

  void _triggerDartError() {
    // Throws in an unguarded async chain — caught by PlatformDispatcher.onError
    Future<void>.delayed(Duration.zero, () {
      throw Exception('Dev-triggered Dart async error from HomePage');
    });
    AppSnackbar.success('Async error triggered — check backend logs');
  }
}
