import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:rexone_mobile/design/design.dart';

import '../services/video_player.service.dart';

/// On-screen caption styling for the inline 16:9 video player.
class VideoSubtitleOverlay {
  const VideoSubtitleOverlay._();

  static SubtitleViewConfiguration config(
    BuildContext context,
    VideoPlayerService player,
  ) {
    // media_kit auto-scales subtitle text down on small players; use a fixed
    // scaler so captions stay readable in the inline 16:9 view.
    return SubtitleViewConfiguration(
      visible: player.subtitlesEnabled.value,
      style: context.typo.headline3.copyWith(
        color: Design.colors.glowWhite,
        fontWeight: FontWeight.w600,
        height: 1.35,
        backgroundColor: Design.colors.night.background.withValues(alpha: 0.6),
      ),
      textScaler: TextScaler.linear(1.0),
      padding: Design.spacing.paddingOnly(
        l: Design.spacing.md,
        r: Design.spacing.md,
        b: Design.spacing.xxxl,
      ),
    );
  }
}
