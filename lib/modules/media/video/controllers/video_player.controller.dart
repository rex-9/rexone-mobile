import 'dart:async';

import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../../media.dart';

class VideoPlayerController extends GetxController {
  final VideoPlayerService player = Get.find<VideoPlayerService>();

  Future<void> playAt(int index) async {
    if (player.hasSession.value && player.currentIndex.value == index) {
      await player.toggle();
      return;
    }
    if (!await player.play(index)) {
      AppSnackbar.error(AppLocales.video.playbackFailed.tr);
    }
  }

  Future<void> closeAndExit() async {
    await player.dismiss();
    Get.back();
  }

  @override
  void onClose() {
    if (player.hasSession.value) {
      unawaited(player.dismiss());
    }
    super.onClose();
  }
}
