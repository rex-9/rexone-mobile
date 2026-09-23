import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../../media.dart';

class MiniPlayer extends GetView<MiniPlayerController> {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.isRegistered) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (!controller.hasSession) return const SizedBox.shrink();
      final asset = controller.currentAsset;
      if (asset == null) return const SizedBox.shrink();

      return Material(
        color: context.colors.surface,
        child: InkWell(
          onTap: controller.openFullPlayer,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.colors.divider),
              ),
            ),
            padding: Design.spacing.paddingSymmetric(
              h: Design.spacing.lg,
              v: Design.spacing.sm,
            ),
            child: Row(
              children: [
                TrackArtwork(
                  url: asset.displayThumbnailUrl,
                  size: Design.spacing.iconXLarge + Design.spacing.lg,
                ),
                SizedBox(width: Design.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        asset.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.labelLarge,
                      ),
                      Text(
                        asset.displayDuration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.caption,
                      ),
                    ],
                  ),
                ),
                controller.isLoading
                    ? AppLoading(
                        size: LoadingSize.small,
                        color: context.colors.primary,
                      )
                    : AppButton(
                        type: EButtonType.icon,
                        icon: controller.isPlaying
                            ? Design.icons.pause
                            : Design.icons.play,
                        tooltip: controller.isPlaying
                            ? AppLocales.audio.pause.tr
                            : AppLocales.audio.play.tr,
                        onPressed: controller.togglePlayPause,
                      ),
                AppButton(
                  type: EButtonType.icon,
                  icon: Design.icons.skipNext,
                  tooltip: AppLocales.audio.next.tr,
                  onPressed: controller.playNext,
                ),
                AppButton(
                  type: EButtonType.icon,
                  icon: Design.icons.close,
                  tooltip: AppLocales.audio.close.tr,
                  onPressed: controller.dismiss,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
