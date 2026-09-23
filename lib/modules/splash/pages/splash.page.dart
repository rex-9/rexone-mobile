import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

import '../controllers/splash.controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      backgroundColor: context.colors.background,
      child: Obx(() {
        if (controller.isForceUpdateBlocked.value) {
          final version = controller.latestVersion.value;
          final title = (version?.title?.trim().isNotEmpty == true)
              ? version!.title!.trim()
              : AppLocales.update.title.tr;
          final message = (version?.description?.trim().isNotEmpty == true)
              ? version!.description!.trim()
              : AppLocales.update.message.tr;

          return PopScope(
            canPop: false,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: Design.spacing.padding(Design.spacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: Design.spacing.padding(Design.spacing.lg),
                        decoration: BoxDecoration(
                          color: Design.colors.warning.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Design.icons.warning,
                          size: 48,
                          color: Design.colors.warning,
                        ),
                      ),
                      SizedBox(height: Design.spacing.xl),
                      Text(
                        title,
                        style: context.typo.headline3,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Design.spacing.md),
                      Text(
                        message,
                        style: context.typo.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Design.spacing.sm),
                      Text(
                        '${AppInfo.version} (${AppInfo.buildNumber}) -> ${version?.number ?? ''}',
                        style: context.typo.caption.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                      SizedBox(height: Design.spacing.xxl),
                      AppButton(
                        text: AppLocales.update.update.tr,
                        onPressed: controller.openStore,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Center(
          child: AppLoading(type: LoadingType.pulse, size: LoadingSize.xlarge),
        );
      }),
    );
  }
}
