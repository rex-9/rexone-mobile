import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../audio.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AudioPlayerService>()) {
      return const SizedBox.shrink();
    }
    final player = Get.find<AudioPlayerService>();

    return Obx(() {
      if (!player.hasSession.value) return const SizedBox.shrink();
      final track = player.currentTrack;
      if (track == null) return const SizedBox.shrink();

      return Material(
        color: context.colors.surface,
        child: InkWell(
          onTap: () {
            player.isFullPlayerOpen.value = true;
            Get.toNamed(AudioRoutes.player);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.colors.divider),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Design.spacing.lg,
              vertical: Design.spacing.sm,
            ),
            child: Row(
              children: [
                TrackArtwork(
                  url: track.artworkUrl,
                  size: Design.spacing.iconXLarge + Design.spacing.lg,
                ),
                SizedBox(width: Design.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.labelLarge,
                      ),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.caption,
                      ),
                    ],
                  ),
                ),
                player.isLoading.value
                    ? AppLoading(
                        size: LoadingSize.small,
                        color: context.colors.primary,
                      )
                    : AppButton(
                        type: EButtonType.icon,
                        icon: player.isPlaying.value
                            ? Design.icons.pause
                            : Design.icons.play,
                        tooltip: player.isPlaying.value
                            ? AppLocales.audio.pause.tr
                            : AppLocales.audio.play.tr,
                        onPressed: player.toggle,
                      ),
                AppButton(
                  type: EButtonType.icon,
                  icon: Design.icons.skipNext,
                  tooltip: AppLocales.audio.next.tr,
                  onPressed: player.next,
                ),
                AppButton(
                  type: EButtonType.icon,
                  icon: Design.icons.close,
                  tooltip: AppLocales.audio.close.tr,
                  onPressed: player.dismiss,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
