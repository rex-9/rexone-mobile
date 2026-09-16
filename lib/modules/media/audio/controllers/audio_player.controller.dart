import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../../media.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayerService player = Get.find<AudioPlayerService>();

  Future<void> togglePlayback() async {
    if (!await player.toggle()) {
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
    }
  }

  Future<void> skipNext() async {
    if (!await player.next()) {
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
    }
  }

  Future<void> skipPrevious() async {
    if (!await player.previous()) {
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
    }
  }

  Future<void> closeAndExit() async {
    await player.dismiss();
    Get.back();
  }

  @override
  void onInit() {
    super.onInit();
    // Defer: GetView reads [controller] during AudioPlayerPage.build,
    // and writing .obs here would rebuild AppMiniPlayerHost mid-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      player.isFullPlayerOpen.value = true;
    });
  }

  @override
  void onClose() {
    player.isFullPlayerOpen.value = false;
    super.onClose();
  }
}
