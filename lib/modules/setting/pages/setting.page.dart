// lib/modules/setting/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/routes/app.routes.dart';

import '../../auth/auth.dart';
import '../../feedback/feedback.dart';
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
          _buildSectionHeader(context, AppLocales.setting.theme.tr),
          _buildThemeTile(context),

          SizedBox(height: Design.spacing.xxl),

          // Language Section
          _buildSectionHeader(context, AppLocales.setting.language.tr),
          _buildLanguageTile(context),

          SizedBox(height: Design.spacing.xxl),

          // Account Section
          _buildSectionHeader(context, AppLocales.setting.account.tr),
          _buildAccountTile(context, authController),

          SizedBox(height: Design.spacing.xxl),

          // Feedback Section
          _buildSectionHeader(context, AppLocales.feedback.title.tr),
          _buildFeedbackTile(context),

          SizedBox(height: Design.spacing.xxl),

          // App Info Section
          _buildSectionHeader(context, AppLocales.setting.appInfo.tr),
          _buildAppInfoTile(context),
        ],
      ),
    );
  }

  Widget _buildFeedbackTile(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListTile(
        leading: Icon(Icons.feedback_outlined, color: context.colors.primary),
        title: Text(AppLocales.feedback.title.tr),
        subtitle: Text(AppLocales.feedback.description.tr),
        trailing:
            Icon(Design.icons.rightArrow, color: context.colors.textSecondary),
        onTap: () => FeedbackBottomSheet.show(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: Design.spacing.sm,
        bottom: Design.spacing.md,
        top: Design.spacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.typo.labelMedium.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return Obx(
      () => AppCard(
        padding: EdgeInsets.zero,
        child: AppListTile(
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
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListTile(
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
                        if (controller.isLocale(entry.key))
                          Icon(
                            Design.icons.check,
                            size: Design.spacing.iconSmall,
                            color: context.colors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
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

  Widget _buildAccountTile(
    BuildContext context,
    AuthController authController,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Obx(
            () => AppListTile(
              leading: CircleAvatar(
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                backgroundImage: authController.currentUser.value?.photo != null
                    ? NetworkImage(authController.currentUser.value!.photo!)
                    : null,
                child: authController.currentUser.value?.photo == null
                    ? Icon(Design.icons.person, color: context.colors.primary)
                    : null,
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
          Divider(
            color: context.colors.divider,
            height: 1,
            indent: Design.spacing.lg,
            endIndent: Design.spacing.lg,
          ),
          AppListTile(
            leading: Icon(Design.icons.logout, color: context.colors.error),
            title: Text(AppLocales.common.signOut.tr),
            isDestructive: true,
            onTap: () => _showLogoutDialog(context, authController),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoTile(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListTile(
        leading: Icon(Design.icons.info, color: context.colors.textSecondary),
        title: Text(AppConfig.appName),
        subtitle: Obx(() => Text('v${controller.appVersion.value}')),
      ),
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
}
