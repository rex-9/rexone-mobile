import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../audio.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayerService player = Get.find<AudioPlayerService>();

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
