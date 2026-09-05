import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

/// Shared OS permission requests and the Settings confirm dialog.
/// Feature controllers should not call [permission_handler] directly.
class PermissionService extends GetxService {
  Future<bool> isAllowed(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  /// Asks the OS if needed. Does not show in-app UI.
  Future<bool> request(Permission permission) async {
    if (await isAllowed(permission)) return true;
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  /// Requests the permission; if denied, offers to open Settings.
  Future<bool> ensure(
    Permission permission, {
    required String title,
    required String message,
  }) async {
    if (await request(permission)) return true;
    await promptSettings(title: title, message: message);
    return false;
  }

  Future<void> promptSettings({
    required String title,
    required String message,
  }) async {
    final context = Get.context;
    if (context == null || !context.mounted) return;

    final openSettings = await AppDialog.confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: AppLocales.ai.openSettings.tr,
    );

    if (openSettings) {
      await openAppSettings();
    }
  }

  Future<bool> requestMicrophone() => request(Permission.microphone);

  Future<void> promptMicrophoneSettings() => promptSettings(
        title: AppLocales.ai.micPermissionTitle.tr,
        message: AppLocales.ai.micPermissionMessage.tr,
      );

  Future<bool> ensureCamera() => ensure(
        Permission.camera,
        title: AppLocales.user.cameraPermissionTitle.tr,
        message: AppLocales.user.cameraPermissionMessage.tr,
      );

  Future<void> promptPhotosSettings() => promptSettings(
        title: AppLocales.user.photosPermissionTitle.tr,
        message: AppLocales.user.photosPermissionMessage.tr,
      );

  Future<void> promptPhotosIfDenied() async {
    final status = await Permission.photos.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      await promptPhotosSettings();
    }
  }
}
