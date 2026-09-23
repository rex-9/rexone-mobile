import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/app.routes.dart';

import '../services/audio_player.service.dart';

class MiniPlayerController extends GetxController {
  AudioPlayerService? get _player =>
      Get.isRegistered<AudioPlayerService>()
          ? Get.find<AudioPlayerService>()
          : null;

  bool get isRegistered => _player != null;
  bool get hasSession => _player?.hasSession.value ?? false;
  bool get isPlaying => _player?.isPlaying.value ?? false;
  bool get isLoading => _player?.isLoading.value ?? false;
  AssetModel? get currentAsset => _player?.currentAsset;

  void openFullPlayer() {
    final player = _player;
    if (player == null) return;
    player.isFullPlayerOpen.value = true;
    AppRoutes.toAudioPlayer();
  }

  Future<void> togglePlayPause() async {
    final player = _player;
    if (player == null) return;
    final success = await player.toggle();
    if (!success) {
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
    }
  }

  Future<void> playNext() async {
    final player = _player;
    if (player == null) return;
    final success = await player.next();
    if (!success) {
      AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
    }
  }

  void dismiss() {
    _player?.dismiss();
  }
}
