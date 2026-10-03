// lib/modules/auth/pages/signup_password_confirm_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../auth.dart';

class SignUpPasswordConfirmPage extends GetView<AuthController> {
  const SignUpPasswordConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppLocales.auth.signUpPasscodeConfirm.title.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocales.auth.signUpPasscodeConfirm.heading.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.sm),
              Text(
                AppLocales.auth.signUpPasscodeConfirm.subtitle.tr,
                style: context.typo.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.xxxl),

              Text(
                AppLocales.auth.signUpPasscodeConfirm.heading.tr,
                style: context.typo.labelMedium,
              ),
              SizedBox(height: Design.spacing.sm),
              AppPasswordField(
                pinController: controller.signupConfirmPin,
                onChanged: (value) => controller.confirmPassword.value = value,
                onCompleted: (_) => controller.handleConfirmPassword(),
              ),

              SizedBox(height: Design.spacing.xxxl),
              AppButton(
                text: AppLocales.auth.signUpPasscodeConfirm.confirm.tr,
                onPressed: controller.handleConfirmPassword,
              ),

              SizedBox(height: Design.spacing.lg),
              AppButton(
                type: EButtonType.text,
                onPressed: () {
                  controller.confirmPassword.value = '';
                  controller.signupConfirmPin.clear();
                  controller.password.value = '';
                  controller.signupPin.clear();
                  Get.back();
                },
                text: AppLocales.auth.signUpPasscodeConfirm.changePasscode.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
