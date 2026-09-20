import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/video_layout.helper.dart';

import '../../media.dart';

class VideoPlayerPage extends GetView<VideoPlayerController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    final colors = context.colors;
    final typo = context.typo;

    return Obx(() {
      final asset = player.currentAsset;
      final videoController = player.videoController;
      player.subtitlesEnabled.value;
      final controlsTheme = VideoPlayerControls.theme(context, player);
      final subtitleConfig = VideoSubtitleOverlay.config(context, player);
      final assets = player.assets;
      final currentIndex = player.currentIndex.value;
      final playing = player.isPlaying.value;

      return AppPage(
        title: asset?.displayTitle ?? AppLocales.video.nowPlaying.tr,
        showBackButton: true,
        onBackPressed: controller.closeAndExit,
        padding: Design.spacing.padding(Design.spacing.screenPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final videoSize = VideoLayoutHelper.inlineVideoSize(constraints);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VideoPlayerViewport(
                  size: videoSize,
                  videoController: videoController,
                  controlsTheme: controlsTheme,
                  subtitleConfig: subtitleConfig,
                ),
                SizedBox(height: Design.spacing.md),
                Text(
                  asset?.displayTitle ?? AppLocales.video.nowPlaying.tr,
                  style: typo.headline3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (asset?.displayDuration.isNotEmpty ?? false) ...[
                  SizedBox(height: Design.spacing.xs),
                  Text(
                    asset!.displayDuration,
                    style: typo.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: Design.spacing.lg),
                Expanded(
                  child: VideoPlaylistPanel(
                    assets: assets,
                    currentIndex: currentIndex,
                    hasSession: player.hasSession.value,
                    isPlaying: playing,
                    isLoading: player.isLoading.value,
                    onPlayAt: controller.playAt,
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
