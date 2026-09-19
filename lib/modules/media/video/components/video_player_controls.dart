import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:rexone_mobile/design/design.dart';

import '../services/video_player.service.dart';
import 'video_settings_sheet.dart';
import 'video_subtitle_sheet.dart';

/// Builds media_kit control bar theme for the video player.
class VideoPlayerControls {
  const VideoPlayerControls._();

  static MaterialVideoControlsThemeData theme(
    BuildContext context,
    VideoPlayerService player,
  ) {
    final hasCaptions = player.hasEffectiveSubtitles;

    return kDefaultMaterialVideoControlsThemeDataFullscreen.copyWith(
      onVolumeChanged: (value) {
        unawaited(player.setVolume(value * 100));
      },
      initialVolume: (player.volume / 100).clamp(0.0, 1.0),
      brightnessGesture: false,
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        MaterialCustomButton(
          onPressed: () => VideoSettingsSheet.show(context, player),
        ),
        if (hasCaptions)
          MaterialCustomButton(
            icon: Icon(
              player.subtitlesEnabled.value
                  ? Design.icons.captionsActive
                  : Design.icons.captions,
            ),
            onPressed: () => VideoSubtitleSheet.show(context, player),
          ),
        const MaterialFullscreenButton(),
      ],
    );
  }
}
