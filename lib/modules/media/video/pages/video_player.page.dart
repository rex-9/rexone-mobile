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

    return AppPage(
      showBackButton: false,
      padding: Design.spacing.zero,
      child: Obx(() {
        final asset = player.currentAsset;
        final betterPlayer = player.controller.value;
        player.subtitlesEnabled.value;
        final assets = player.assets;
        final currentIndex = player.currentIndex.value;
        final playing = player.isPlaying.value;

        return SafeArea(
          child: Padding(
            padding: Design.spacing.padding(Design.spacing.screenPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final videoSize = VideoLayoutHelper.inlineVideoSize(constraints);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.chevronDown,
                      tooltip: AppLocales.video.close.tr,
                      onPressed: controller.closeAndExit,
                    ),
                    SizedBox(height: Design.spacing.md),
                    VideoPlayerViewport(
                      size: videoSize,
                      controller: betterPlayer,
                    ),
                    SizedBox(height: Design.spacing.lg),
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
          ),
        );
      }),
    );
  }
}
