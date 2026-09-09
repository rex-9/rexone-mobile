import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../audio.dart';

class AudioPlayerPage extends GetView<AudioPlayerController> {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;

    return AppPage(
      showBackButton: false,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final track = player.currentTrack;
        final duration = player.duration.value;
        final position = player.position.value;
        final maxMs = duration.inMilliseconds <= 0
            ? 1.0
            : duration.inMilliseconds.toDouble();
        final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Design.spacing.screenPadding),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AppButton(
                    type: EButtonType.icon,
                    icon: Design.icons.chevronDown,
                    tooltip: AppLocales.common.goBack.tr,
                    onPressed: Get.back,
                  ),
                ),
                SizedBox(height: Design.spacing.lg),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth;
                        return TrackArtwork(
                          url: track?.artworkUrl ?? '',
                          size: size,
                          radius: Design.spacing.radiusLarge,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: Design.spacing.xxl),
                Text(
                  track?.title ?? AppLocales.audio.nowPlaying.tr,
                  textAlign: TextAlign.center,
                  style: context.typo.headline3,
                ),
                SizedBox(height: Design.spacing.xs),
                Text(
                  track?.artist ?? '',
                  textAlign: TextAlign.center,
                  style: context.typo.bodyMedium,
                ),
                SizedBox(height: Design.spacing.xl),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: context.colors.primary,
                    inactiveTrackColor: context.colors.divider,
                    thumbColor: context.colors.primary,
                    overlayColor: context.colors.primary.withValues(alpha: 0.12),
                    trackHeight: Design.spacing.xs / 2,
                  ),
                  child: Slider(
                    min: 0,
                    max: maxMs,
                    value: valueMs,
                    onChanged: (value) {
                      player.seek(Duration(milliseconds: value.round()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Design.spacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_format(position), style: context.typo.caption),
                      Text(_format(duration), style: context.typo.caption),
                    ],
                  ),
                ),
                SizedBox(height: Design.spacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.skipPrevious,
                      tooltip: AppLocales.audio.previous.tr,
                      onPressed: player.previous,
                    ),
                    player.isLoading.value
                        ? AppLoading(
                            size: LoadingSize.medium,
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
                            color: context.colors.primary,
                            onPressed: player.isPlaying.value
                                ? player.dismiss
                                : player.toggle,
                          ),
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.skipNext,
                      tooltip: AppLocales.audio.next.tr,
                      onPressed: player.next,
                    ),
                  ],
                ),
                SizedBox(height: Design.spacing.xxl),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
