// lib/modules/auth/pages/signup_password_create_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/routes.dart';

import '../auth.dart';

class SignUpPasswordCreatePage extends GetView<AuthController> {
  const SignUpPasswordCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isGoogle = controller.isGooglePasswordSetup;

    return AppPage(
      title: AppLocales.auth.signUpPasscodeCreate.title.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isGoogle
                    ? AppLocales.auth.signUpPasscodeCreate.googleHeading.tr
                    : AppLocales.auth.signUpPasscodeCreate.heading.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.sm),
              Text(
                isGoogle
                    ? AppLocales.auth.signUpPasscodeCreate.googleSubtitle.tr
                    : AppLocales.auth.signUpPasscodeCreate.subtitle.tr,
                style: context.typo.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.xxxl),

              Text(
                AppLocales.auth.signInPasscode.passcodeLabel.tr,
                style: context.typo.labelMedium,
              ),
              SizedBox(height: Design.spacing.sm),
              AppPasswordField(
                pinController: controller.signupPin,
                onChanged: (value) => controller.password.value = value,
                onCompleted: (_) {
                  // Auto-move to confirm page when 6 digits entered
                  if (controller.password.value.length == 6) {
                    controller.signupConfirmPin.clear();
                    controller.confirmPassword.value = '';
                    AppRoutes.toSignUpPasswordConfirm();
                  }
                },
              ),

              SizedBox(height: Design.spacing.xl),
              AppButton(
                type: EButtonType.text,
                onPressed: () => Get.back(),
                text: AppLocales.auth.initial.goBack.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
