import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:rexone_mobile/design/design.dart';

/// Inline 16:9 video surface with loading and media_kit controls.
class VideoPlayerViewport extends StatelessWidget {
  const VideoPlayerViewport({
    super.key,
    required this.size,
    required this.videoController,
    required this.controlsTheme,
    required this.subtitleConfig,
  });

  final Size size;
  final VideoController? videoController;
  final MaterialVideoControlsThemeData controlsTheme;
  final SubtitleViewConfiguration subtitleConfig;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
          child: ColoredBox(
            color: colors.surface,
            child: videoController == null
                ? Center(child: AppLoading(color: colors.primary))
                : MaterialVideoControlsTheme(
                    normal: controlsTheme,
                    fullscreen: controlsTheme,
                    child: Video(
                      controller: videoController!,
                      controls: MaterialVideoControls,
                      subtitleViewConfiguration: subtitleConfig,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
