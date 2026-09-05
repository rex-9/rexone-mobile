import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../profile.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppLocales.user.profile.tr,
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(context),
              SizedBox(height: Design.spacing.xxxl),
              AppInputField(
                label: AppLocales.auth.signUpInfo.fullNameLabel.tr,
                hint: AppLocales.auth.signUpInfo.fullNameHint.tr,
                controller: controller.nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {},
              ),
              SizedBox(height: Design.spacing.lg),
              AppInputField(
                label: AppLocales.auth.signUpInfo.usernameLabel.tr,
                hint: AppLocales.auth.signUpInfo.usernameHint.tr,
                controller: controller.usernameController,
                onChanged: (_) {},
              ),
              SizedBox(height: Design.spacing.lg),
              AppInputField(
                label: AppLocales.auth.shared.emailLabel.tr,
                hint: AppLocales.auth.shared.emailHint.tr,
                controller: controller.emailController,
                enabled: false,
                onChanged: (_) {},
              ),
              SizedBox(height: Design.spacing.xxxl),
              AppButton(
                text: AppLocales.common.save.tr,
                isExpanded: true,
                onPressed: controller.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final diameter = Design.spacing.avatarRadius * 2;
    return Obx(() {
      final path = controller.pickedImagePath.value;
      final url = controller.photoUrl.value;
      final hasLocal = path != null && path.isNotEmpty;
      final hasNetwork = url != null && url.isNotEmpty;
      final hasPhoto = hasLocal || hasNetwork;
      return Semantics(
        button: true,
        label: AppLocales.user.changeAvatar.tr,
        child: GestureDetector(
          onTap: () => _showPhotoSourceSheet(context),
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  key: ValueKey(path ?? url ?? ''),
                  radius: Design.spacing.avatarRadius,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                  backgroundImage: hasLocal
                      ? FileImage(File(path))
                      : hasNetwork
                          ? NetworkImage(url)
                          : null,
                  child: hasPhoto
                      ? null
                      : Icon(
                          Design.icons.person,
                          size: Design.spacing.iconXLarge,
                          color: context.colors.primary,
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: Design.spacing.avatarBadgeRadius * 2,
                    height: Design.spacing.avatarBadgeRadius * 2,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surface),
                    ),
                    child: Icon(
                      Design.icons.edit,
                      size: Design.spacing.iconSmall,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showPhotoSourceSheet(BuildContext context) {
    Get.bottomSheet(
      _PhotoSourceSheet(controller: controller),
      backgroundColor: context.colors.background.withValues(alpha: 0),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Design.spacing.lg,
        right: Design.spacing.lg,
        top: Design.spacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + Design.spacing.xxl,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Design.spacing.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppHandleBar(),
          SizedBox(height: Design.spacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocales.user.changeAvatar.tr,
              style: context.typo.headline3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: Design.spacing.md),
          AppListTile(
            leading: Icon(Design.icons.camera, color: context.colors.primary),
            title: Text(AppLocales.user.takePhoto.tr),
            onTap: () {
              Get.back();
              controller.pickFromCamera();
            },
          ),
          AppListTile(
            leading: Icon(Design.icons.gallery, color: context.colors.primary),
            title: Text(AppLocales.user.chooseFromGallery.tr),
            onTap: () {
              Get.back();
              controller.pickFromGallery();
            },
          ),
        ],
      ),
    );
  }
}
