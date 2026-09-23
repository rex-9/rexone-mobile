import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../../media.dart';

class AudioPlayerPage extends GetView<AudioPlayerController> {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;

    return AppPage(
      showBackButton: false,
      padding: Design.spacing.zero,
      child: Obx(() {
        final asset = player.currentAsset;
        final subtitleTracks = player.effectiveSubtitles;
        final hasLyrics = player.hasEffectiveSubtitles;
        final showLyrics = player.lyricsVisible.value && hasLyrics;
        final showLyricsTrackPicker =
            showLyrics && subtitleTracks.length > 1;

        return SafeArea(
          child: Padding(
            padding: Design.spacing.padding(Design.spacing.screenPadding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.chevronDown,
                      tooltip: AppLocales.common.goBack.tr,
                      onPressed: Get.back,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasLyrics) ...[
                          if (showLyricsTrackPicker)
                            AppButton(
                              type: EButtonType.icon,
                              icon: Design.icons.playlist,
                              tooltip: AppLocales.audio.lyricsTrack.tr,
                              onPressed: () => AudioLyricsTrackSheet.show(
                                context,
                                player: player,
                                onSelectTrack: controller.selectLyricsTrack,
                              ),
                            ),
                          AppButton(
                            type: EButtonType.icon,
                            icon: showLyrics
                                ? Design.icons.lyricsActive
                                : Design.icons.lyrics,
                            tooltip: AppLocales.audio.lyrics.tr,
                            color: showLyrics
                                ? context.colors.primary
                                : null,
                            onPressed: controller.toggleLyrics,
                          ),
                        ],
                        AppButton(
                          type: EButtonType.icon,
                          icon: Design.icons.close,
                          tooltip: AppLocales.audio.close.tr,
                          onPressed: controller.closeAndExit,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Design.spacing.lg),
                Expanded(
                  child: showLyrics
                      ? AudioLyricsView(player: player)
                      : Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = constraints.maxWidth;
                              return TrackArtwork(
                                url: asset?.displayThumbnailUrl ?? '',
                                size: size,
                                radius: Design.spacing.radiusLarge,
                              );
                            },
                          ),
                        ),
                ),
                SizedBox(height: Design.spacing.xxl),
                Text(
                  asset?.displayTitle ?? AppLocales.audio.nowPlaying.tr,
                  textAlign: TextAlign.center,
                  style: context.typo.headline3,
                ),
                SizedBox(height: Design.spacing.xs),
                Text(
                  asset?.displayDuration ?? '',
                  textAlign: TextAlign.center,
                  style: context.typo.bodyMedium,
                ),
                _AudioProgressBar(player: player),
                SizedBox(height: Design.spacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.skipPrevious,
                      tooltip: AppLocales.audio.previous.tr,
                      onPressed: controller.skipPrevious,
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
                            onPressed: controller.togglePlayback,
                          ),
                    AppButton(
                      type: EButtonType.icon,
                      icon: Design.icons.skipNext,
                      tooltip: AppLocales.audio.next.tr,
                      onPressed: controller.skipNext,
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
}

class _AudioProgressBar extends StatefulWidget {
  const _AudioProgressBar({required this.player});

  final AudioPlayerService player;

  @override
  State<_AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<_AudioProgressBar> {
  double? _dragValueMs;

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final duration = widget.player.duration.value;
      final position = widget.player.position.value;
      final maxMs = duration.inMilliseconds <= 0
          ? 1.0
          : duration.inMilliseconds.toDouble();
      final currentMs =
          position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();
      final displayMs = (_dragValueMs ?? currentMs).clamp(0.0, maxMs);

      final displayPosition = _dragValueMs != null
          ? Duration(milliseconds: _dragValueMs!.round())
          : position;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              value: displayMs,
              onChangeStart: (value) {
                setState(() => _dragValueMs = value);
              },
              onChanged: (value) {
                setState(() => _dragValueMs = value);
              },
              onChangeEnd: (value) {
                final targetMs = value.round();
                setState(() => _dragValueMs = null);
                widget.player.seek(Duration(milliseconds: targetMs));
              },
            ),
          ),
          Padding(
            padding: Design.spacing.paddingSymmetric(h: Design.spacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_format(displayPosition), style: context.typo.caption),
                Text(_format(duration), style: context.typo.caption),
              ],
            ),
          ),
        ],
      );
    });
  }
}
