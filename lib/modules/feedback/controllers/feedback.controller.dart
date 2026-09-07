// lib/modules/feedback/controllers/feedback.controller.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import '../services/feedback.service.dart';

class FeedbackController extends GetxController {
  late final FeedbackService _service;

  final textController = TextEditingController();
  final rating = 8.obs; // 1 to 10 scale
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<FeedbackService>()) {
      _service = Get.find<FeedbackService>();
    } else {
      _service = Get.put(FeedbackService());
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void setRating(int value) {
    if (value >= 1 && value <= 10) {
      rating.value = value;
    }
  }

  Future<bool> submitFeedback() async {
    final content = textController.text.trim();
    if (content.isEmpty) {
      AppSnackbar.warning('Please enter your feedback');
      return false;
    }

    try {
      isSubmitting.value = true;

      String? appVersion;
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = info.version;
      } catch (_) {}

      String os = 'unknown';
      if (!kIsWeb) {
        if (Platform.isAndroid) os = 'Android';
        if (Platform.isIOS) os = 'iOS';
      }

      final payload = <String, dynamic>{
        FeedbackKeys.content: content,
        FeedbackKeys.rating: rating.value,
        FeedbackKeys.page: Get.currentRoute,
        FeedbackKeys.os: os,
        ...?appVersion != null ? {FeedbackKeys.appVersion: appVersion} : null,
        FeedbackKeys.metadata: {
          'current_route': Get.currentRoute,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final response = await _service.submitFeedback(payload);

      if (response.success) {
        textController.clear();
        rating.value = 8;
        if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
          Get.back(); // Close bottom sheet/dialog smoothly
        }
        AppSnackbar.success(
          response.message.isNotEmpty
              ? response.message
              : 'Thank you for your feedback!',
        );
        return true;
      } else {
        AppSnackbar.error(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to submit feedback. Please try again.',
        );
        return false;
      }
    } catch (e) {
      AppSnackbar.error('Failed to submit feedback: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
