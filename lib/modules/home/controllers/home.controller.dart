import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final VersionService _version = Get.find<VersionService>();
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.testMode) return;
    reportUserVersion();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVersionOnResume();
    }
  }

  Future<void> reportUserVersion() async {
    try {
      await _version.reportUserVersion(
        version: AppInfo.version,
        buildNumber: AppInfo.versionCode,
      );
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  Future<void> _checkVersionOnResume() async {
    try {
      final result = await _version.getCurrent(
        version: AppInfo.version,
        buildNumber: AppInfo.versionCode,
      );
      if (result.success && result.data != null) {
        final version = result.data!;
        _storage.setSkipPremium(version.skipPremium);

        if (version.mustUpdate) {
          AppRoutes.toSplash();
          return;
        }

        if (version.updateRequired) {
          final context = Get.context;
          if (context != null && context.mounted) {
            final title = (version.title?.trim().isNotEmpty == true)
                ? version.title!.trim()
                : AppLocales.update.title.tr;
            final message = (version.description?.trim().isNotEmpty == true)
                ? version.description!.trim()
                : AppLocales.update.message.tr;
            await AppDialog.update(
              context: context,
              title: title,
              message: message,
              onUpdate: () async {
                if (version.storeUrl != null && version.storeUrl!.isNotEmpty) {
                  final uri = Uri.tryParse(version.storeUrl!);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            );
          }
        }
      }
    } catch (error) {
      debugPrint('Resume version check error: $error');
    }
  }
}
