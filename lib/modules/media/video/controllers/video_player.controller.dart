import 'dart:async';

import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/media_download.service.dart';

import '../../controllers/playlist.controller.dart';
import '../services/video_player.service.dart';

class VideoPlayerController extends GetxController {
  final VideoPlayerService player = Get.find<VideoPlayerService>();

  MediaDownloadService? get _downloads =>
      Get.isRegistered<MediaDownloadService>()
          ? Get.find<MediaDownloadService>()
          : null;
  MediaPlaylistController? get _playlist =>
      Get.isRegistered<MediaPlaylistController>()
          ? Get.find<MediaPlaylistController>()
          : null;

  EMediaDownloadState downloadStateFor(AssetModel asset) {
    if (_playlist != null) return _playlist!.downloadStateFor(asset);
    return _downloads?.stateFor(asset.id) ?? EMediaDownloadState.none;
  }

  double downloadProgressFor(AssetModel asset) {
    if (_playlist != null) return _playlist!.downloadProgressFor(asset);
    return _downloads?.progressFor(asset.id) ?? 0.0;
  }

  void onDownloadTap(AssetModel asset) {
    _playlist?.onDownloadTap(asset);
  }

  void onDownloadPauseTap(AssetModel asset) {
    _playlist?.onDownloadPauseTap(asset);
  }

  void onDownloadLongPress(AssetModel asset) {
    _playlist?.onDownloadLongPress(asset);
  }

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
