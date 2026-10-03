// lib/modules/auth/pages/signin_password_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/routes.dart';

import '../auth.dart';

class SignInPasswordPage extends GetView<AuthController> {
  const SignInPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppLocales.auth.signInPasscode.title.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocales.auth.signInPasscode.heading.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.sm),
              Obx(
                () => Text(
                  AppLocales.auth.signInPasscode.subtitle.trParams({
                    'email': controller.email.value,
                  }),
                  style: context.typo.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: Design.spacing.xxxl),

              Obx(
                () => AppPasswordField(
                  pinController: controller.signinPin,
                  enabled: controller.cooldownSecondsLeft.value == 0,
                  onChanged: (value) => controller.password.value = value,
                  onCompleted: (pin) {
                    controller.password.value = pin;
                    controller.signIn();
                  },
                ),
              ),

              // Attempts remaining + cooldown feedback
              Obx(() {
                if (controller.cooldownSecondsLeft.value > 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: Design.spacing.lg),
                    child: Text(
                      AppLocales.auth.signInPasscode.cooldownMessage.trParams({
                        'seconds': '${controller.cooldownSecondsLeft.value}',
                      }),
                      style: context.typo.caption.copyWith(
                        color: context.colors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (controller.hasFailureHistory.value &&
                    controller.attemptsLeft.value <
                        AuthController.maxAttempts) {
                  return Padding(
                    padding: EdgeInsets.only(top: Design.spacing.lg),
                    child: Text(
                      AppLocales.auth.signInPasscode.attemptsRemaining.trParams({
                        'left': '${controller.attemptsLeft.value}',
                        'total': '${AuthController.maxAttempts}',
                      }),
                      style: context.typo.caption,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              SizedBox(height: Design.spacing.xxxl),
              Obx(
                () => AppButton(
                  text: controller.cooldownSecondsLeft.value > 0
                      ? AppLocales.auth.signInPasscode.tryAgainIn.trParams({
                          'seconds': '${controller.cooldownSecondsLeft.value}',
                        })
                      : AppLocales.auth.signInPasscode.title.tr,
                  onPressed: () => controller.signIn(),
                ),
              ),

              SizedBox(height: Design.spacing.lg),
              AppButton(
                type: EButtonType.text,
                onPressed: () {
                  controller.password.value = '';
                  controller.signinPin.clear();
                  Get.back();
                },
                text: AppLocales.auth.shared.useDifferentEmail.tr,
              ),
              AppButton(
                type: EButtonType.text,
                onPressed: () => AppRoutes.toForgotPassword(),
                text: AppLocales.auth.signInPasscode.forgotPasscodeLink.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
