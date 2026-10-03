// lib/modules/auth/pages/signup_info_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../auth.dart';

class SignUpInfoPage extends GetView<AuthController> {
  const SignUpInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;

    controller.email.value = arguments['email'] ?? '';
    controller.password.value = arguments['password'] ?? '';
    controller.confirmPassword.value =
        arguments['confirm_password'] ?? arguments['password'] ?? '';

    return AppPage(
      title: AppLocales.auth.signUpInfo.title.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Design.spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocales.auth.signUpInfo.heading.tr,
                style: context.typo.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Design.spacing.xxxl),

              AppInputField(
                label: AppLocales.auth.signUpInfo.fullNameLabel.tr,
                hint: AppLocales.auth.signUpInfo.fullNameHint.tr,
                onChanged: (value) => controller.fullName.value = value,
              ),
              SizedBox(height: Design.spacing.lg),

              AppInputField(
                label: AppLocales.auth.signUpInfo.usernameLabel.tr,
                hint: AppLocales.auth.signUpInfo.usernameHint.tr,
                onChanged: (value) =>
                    controller.username.value = value.toLowerCase().trim(),
              ),

              SizedBox(height: Design.spacing.xxxl),
              AppButton(
                text: AppLocales.auth.signUpInfo.createAccountButton.tr,
                onPressed: () => controller.signUp(),
              ),

              SizedBox(height: Design.spacing.lg),
              AppButton(
                type: EButtonType.text,
                onPressed: () {
                  controller.password.value = '';
                  controller.confirmPassword.value = '';
                  controller.signupPin.clear();
                  controller.signupConfirmPin.clear();
                  Get.back();
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
