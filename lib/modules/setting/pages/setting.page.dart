// lib/modules/setting/pages/setting.page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/routes/app.routes.dart';

import '../../auth/auth.dart';
import '../../feedback/feedback.dart';
import '../../profile/profile.dart';
import '../setting.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppPage(
      title: AppLocales.setting.settings.tr,
      showBackButton: true,
      child: ListView(
        padding: EdgeInsets.all(Design.spacing.lg),
        children: [
          // Theme Section
          AppSectionCard(
            title: AppLocales.setting.theme.tr,
            children: [
              _buildThemeTile(context),
            ],
          ),

          SizedBox(height: Design.spacing.xxl),

          // Language Section
          AppSectionCard(
            title: AppLocales.setting.language.tr,
            children: [
              _buildLanguageTile(context),
            ],
          ),

          SizedBox(height: Design.spacing.xxl),

          // Account Section
          AppSectionCard(
            title: AppLocales.setting.account.tr,
            children: [
              Obx(
                () => AppListTile(
                  leading: AppAvatar(
                    url: authController.currentUser.value?.photo,
                    name: authController.currentUser.value?.name ??
                        authController.currentUser.value?.username ??
                        authController.currentUser.value?.email,
                    radius: Design.spacing.avatarRadius / 2,
                  ),
                  title: Text(
                    authController.currentUser.value?.name ??
                        authController.currentUser.value?.username ??
                        AppLocales.setting.account.tr,
                  ),
                  subtitle: Text(
                    authController.currentUser.value?.email ??
                        AppLocales.common.loading.tr,
                  ),
                  trailing: Icon(
                    Design.icons.rightArrow,
                    color: context.colors.textSecondary,
                  ),
                  onTap: AppRoutes.toProfile,
                ),
              ),
              AppListTile(
                leading: Icon(Design.icons.logout, color: context.colors.error),
                title: Text(AppLocales.common.signOut.tr),
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, authController),
              ),
              AppListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: context.colors.error,
                ),
                title: Text(AppLocales.user.deleteAccount.tr),
                isDestructive: true,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),

          SizedBox(height: Design.spacing.xxl),

          // Feedback Section
          AppSectionCard(
            title: AppLocales.feedback.title.tr,
            children: [
              _buildFeedbackTile(context),
            ],
          ),

          SizedBox(height: Design.spacing.xxl),

          // App Info Section
          AppSectionCard(
            title: AppLocales.setting.appInfo.tr,
            children: [
              _buildAppInfoTile(context),
            ],
          ),

          SizedBox(height: Design.spacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFeedbackTile(BuildContext context) {
    return AppListTile(
      leading: Icon(Icons.feedback_outlined, color: context.colors.primary),
      title: Text(AppLocales.feedback.title.tr),
      subtitle: Text(AppLocales.feedback.description.tr),
      trailing: Icon(
        Design.icons.rightArrow,
        color: context.colors.textSecondary,
      ),
      onTap: () => FeedbackBottomSheet.show(),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return Obx(
      () => AppListTile(
        leading: Icon(controller.themeIcon, color: context.colors.primary),
        title: Text(AppLocales.setting.theme.tr),
        subtitle: Text(controller.themeLabel),
        trailing: AppToggle(
          value: controller.isDarkMode.value,
          onChanged: (_) => controller.toggleTheme(),
          activeColor: context.colors.primary,
        ),
        onTap: controller.toggleTheme,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return AppListTile(
      leading: _buildFlagIcon(context),
      title: Text(AppLocales.setting.language.tr),
      subtitle: Obx(() => Text(controller.currentLanguageName)),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Design.icons.downArrow,
          color: context.colors.textSecondary,
        ),
        onSelected: controller.changeLocale,
        itemBuilder: (context) => controller.supportedLocales
            .map(
              (entry) => PopupMenuItem<String>(
                value: entry.key,
                child: Obx(
                  () => Row(
                    children: [
                      _buildFlagIcon(context, locale: entry.key),
                      SizedBox(width: Design.spacing.sm),
                      Text(
                        entry.value,
                        style: context.typo.bodyMedium.copyWith(
                          color: controller.isLocale(entry.key)
                              ? context.colors.primary
                              : context.colors.textPrimary,
                        ),
                      ),
                      if (controller.isLocale(entry.key)) ...[
                        SizedBox(width: Design.spacing.xs),
                        Icon(
                          Design.icons.check,
                          size: Design.spacing.iconSmall,
                          color: context.colors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFlagIcon(BuildContext context, {String? locale}) {
    final String code = locale ?? controller.localeCode.value;
    return Text(
      FlagHelper.getEmoji(code),
      style: TextStyle(fontSize: Design.spacing.iconLarge),
    );
  }

  Widget _buildAppInfoTile(BuildContext context) {
    return AppListTile(
      leading: Icon(Design.icons.info, color: context.colors.textSecondary),
      title: Text(AppConfig.appName),
      subtitle: Obx(() => Text('v${controller.appVersion.value}')),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthController authController,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: AppLocales.common.signOut.tr,
      message: AppLocales.setting.logoutConfirmation.tr,
      confirmLabel: AppLocales.common.signOut.tr,
    );
    if (confirmed) authController.signOut();
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: AppLocales.user.deleteConfirmTitle.tr,
      message: AppLocales.user.deleteConfirmMessage.trParams({
        'email': AppConfig.fromEmail,
      }),
      confirmLabel: AppLocales.user.deleteAccount.tr,
    );
    if (confirmed) {
      AppLoading.show();
      try {
        final profileService = Get.find<ProfileService>();
        final res = await profileService.discardCurrentUser();
        if (!res.success) {
          AppSnackbar.error(res.error ?? res.message);
          return;
        }
        AppSnackbar.success(AppLocales.user.deleteSuccess.tr);
        if (Get.isRegistered<AuthController>()) {
          await Get.find<AuthController>().signOut();
        }
      } catch (e, stk) {
        AppSnackbar.error(AppLocales.user.deleteFailed.tr, e: e, stk: stk);
      } finally {
        AppLoading.hide();
      }
    }
  }
}
