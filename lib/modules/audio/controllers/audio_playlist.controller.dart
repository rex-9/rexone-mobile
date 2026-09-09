import 'package:get/get.dart';
import 'package:rexone_mobile/routes/app.routes.dart';

import '../audio.dart';

class AudioPlaylistController extends GetxController {
  final AudioPlayerService player = Get.find<AudioPlayerService>();

  List<TrackModel> get tracks => player.tracks;

  Future<void> playAll() => player.play(0);

  Future<void> playAt(int index) async {
    if (player.hasSession.value && player.currentIndex.value == index) {
      AppRoutes.toAudioPlayer();
      return;
    }
    await player.play(index);
  }
}
