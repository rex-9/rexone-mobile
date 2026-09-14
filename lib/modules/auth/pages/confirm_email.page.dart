// lib/modules/auth/pages/confirm_email_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/routes.dart';

import '../auth.dart';

class ConfirmEmailPage extends GetView<AuthController> {
  const ConfirmEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;

    controller.email.value = arguments['email'];

    return AppPage(
      title: AppLocales.auth.confirmEmail.title.tr,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocales.auth.confirmEmail.heading.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.sm),
              Obx(
                () => Text(
                  AppLocales.auth.confirmEmail.subtitle.trParams({
                    'email': controller.email.value,
                  }),
                  style: context.typo.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: Design.spacing.xxxl),

              AppPasswordField(
                pinController: controller.confirmPin,
                obscureText: false,
                onCompleted: controller.confirmOTPCode,
              ),

              SizedBox(height: Design.spacing.xxxl),
              AppButton(
                text: AppLocales.auth.confirmEmail.confirmCodeButton.tr,
                onPressed: () {
                  if (controller.confirmPin.text.length != 6) {
                    controller.confirmPin.triggerError();
                    AppSnackbar.error(
                      AppLocales.auth.confirmEmail.enter6DigitCode.tr,
                    );
                    return;
                  }
                  controller.confirmOTPCode(controller.confirmPin.text);
                },
              ),

              SizedBox(height: Design.spacing.lg),
              Obx(
                () => AppButton(
                  type: EButtonType.text,
                  onPressed: controller.resendSecondsLeft.value > 0
                      ? null
                      : controller.sendConfirmationOTPCode,
                  text: controller.resendSecondsLeft.value > 0
                      ? AppLocales.auth.confirmEmail.resendCodeIn.trParams({
                          'seconds': '${controller.resendSecondsLeft.value}',
                        })
                      : AppLocales.auth.confirmEmail.resendCode.tr,
                ),
              ),

              SizedBox(height: Design.spacing.lg),
              AppButton(
                type: EButtonType.text,
                onPressed: () {
                  controller.email.value = '';
                  controller.confirmPin.clear();
                  Get.offAllNamed(AppRoutes.auth);
                },
                text: AppLocales.auth.shared.useDifferentEmail.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
