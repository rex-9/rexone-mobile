// lib/modules/auth/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../auth.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: controller.email.value);

    return AppPage(
      title: AppLocales.auth.forgotPasscode.title.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocales.auth.forgotPasscode.subtitle.tr,
                style: context.typo.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.xxxl),

              Obx(
                () => AppInputField(
                  label: AppLocales.auth.shared.emailLabel.tr,
                  hint: AppLocales.auth.shared.emailHint.tr,
                  error: controller.emailError.value,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => controller.email.value = value,
                ),
              ),

              SizedBox(height: Design.spacing.xxxl),
              Obx(() {
                final waiting = controller.resendSecondsLeft.value > 0;
                return AppButton(
                  text: waiting
                      ? AppLocales.auth.confirmEmail.resendCodeIn.trParams({
                          'seconds': '${controller.resendSecondsLeft.value}',
                        })
                      : AppLocales.auth.forgotPasscode.sendResetLink.tr,
                  onPressed: () {
                    if (waiting) return;
                    controller.forgotPassword();
                  },
                );
              }),

              SizedBox(height: Design.spacing.lg),
              AppButton(
                type: EButtonType.text,
                onPressed: () => Get.back(),
                text: AppLocales.auth.forgotPasscode.backToSignIn.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
