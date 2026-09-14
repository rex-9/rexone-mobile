import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../services/video_player.service.dart';
import 'video_bottom_sheet.dart';
import 'video_sheet_header.dart';
import 'video_sheet_option.dart';

/// Dark sheet for selecting closed-caption tracks.
class VideoSubtitleSheet {
  const VideoSubtitleSheet._();

  static Future<void> show(
    BuildContext context,
    VideoPlayerService player,
  ) {
    return VideoBottomSheet.show(
      context,
      child: _VideoSubtitleSheetBody(player: player),
    );
  }
}

class _VideoSubtitleSheetBody extends StatelessWidget {
  const _VideoSubtitleSheetBody({required this.player});

  final VideoPlayerService player;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final colors = Design.colors.night;

    return Obx(() {
      final tracks = player.effectiveSubtitles;
      final enabled = player.subtitlesEnabled.value;
      final selectedIndex = player.selectedSubtitleIndex.value;

      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VideoSheetHeader(title: AppLocales.video.subtitles.tr),
            VideoSheetOption(
              label: AppLocales.video.subtitlesOff.tr,
              selected: !enabled,
              onTap: () {
                unawaited(player.setSubtitlesEnabled(false));
                Navigator.pop(context);
              },
            ),
            if (tracks.isEmpty)
              Padding(
                padding: Design.spacing.paddingSymmetric(
                  h: Design.spacing.lg,
                  v: Design.spacing.md,
                ),
                child: Text(
                  AppLocales.video.subtitlesUnavailable.tr,
                  style: typo.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              )
            else
              ...List.generate(tracks.length, (index) {
                final track = tracks[index];
                return VideoSheetOption(
                  label: track.displayLabel,
                  selected: enabled && selectedIndex == index,
                  onTap: () {
                    unawaited(player.selectSubtitleTrack(index));
                    Navigator.pop(context);
                  },
                );
              }),
            SizedBox(height: Design.spacing.sm),
          ],
        ),
      );
    });
  }
}
