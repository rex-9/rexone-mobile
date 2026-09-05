import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/services.dart';

import '../../auth/auth.dart';
import '../profile.dart';

/// Profile form state. Save persists name/username and any picked photo.
class ProfileController extends GetxController {
  final ProfileService _profile = Get.find<ProfileService>();
  final StorageService _storage = Get.find<StorageService>();
  final PermissionService _permissions = Get.find<PermissionService>();
  final MediaService _media = Get.find<MediaService>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController nameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;

  final photoUrl = RxnString();
  final pickedImagePath = RxnString();

  @override
  void onInit() {
    super.onInit();
    final user = _storage.getUserData();
    nameController = TextEditingController(text: user?.name ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    photoUrl.value = user?.photo;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim().toLowerCase();

    final nameError = FullnameValidator.error(name);
    if (nameError != null) {
      AppSnackbar.error(nameError);
      return;
    }
    final usernameError = UsernameValidator.error(username);
    if (usernameError != null) {
      AppSnackbar.error(usernameError);
      return;
    }

    try {
      final path = pickedImagePath.value;
      if (path != null && path.isNotEmpty) {
        final userId = _storage.getUserData()?.id;
        if (userId == null || userId.isEmpty) {
          AppSnackbar.error(AppLocales.user.uploadAvatarFailed.tr);
          return;
        }

        final upload = await _media.uploadImage(
          filePath: path,
          type: AssetKeys.typeAvatar,
          assetableType: AssetKeys.assetableUser,
          assetableId: userId,
        );
        if (!upload.success) {
          AppSnackbar.error(upload.error ?? upload.message);
          return;
        }
      }

      final profile = await _profile.updateCurrentUser(
        UpdateUserRequest(name: name, username: username),
      );
      if (!profile.success) {
        AppSnackbar.error(profile.error ?? profile.message);
        return;
      }


      if (profile.data != null) {
        _cacheUser(profile.data!);
      }

      Get.back();
      AppSnackbar.success(AppLocales.user.updateSuccess.tr);
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.user.updateFailed.tr, e: e, stk: stk);
    }
  }

  void _cacheUser(UserModel user) {
    _storage.setUserData(user);
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().currentUser.value = user;
    }
  }

  Future<void> pickFromCamera() async {
    if (!await _permissions.ensureCamera()) return;
    await _pick(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pick(ImageSource.gallery);
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      pickedImagePath.value = file.path;
    } catch (_) {
      if (source != ImageSource.gallery) return;
      await _permissions.promptPhotosIfDenied();
    }
  }
}
