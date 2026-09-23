import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../../video/components/video_bottom_sheet.dart';
import '../../video/components/video_sheet_header.dart';
import '../../video/components/video_sheet_option.dart';
import '../services/audio_player.service.dart';

/// Dark sheet for selecting a synced lyrics subtitle track.
class AudioLyricsTrackSheet {
  const AudioLyricsTrackSheet._();

  static Future<void> show(
    BuildContext context, {
    required AudioPlayerService player,
    required void Function(int index) onSelectTrack,
  }) {
    return VideoBottomSheet.show(
      context,
      child: _AudioLyricsTrackSheetBody(
        player: player,
        onSelectTrack: onSelectTrack,
      ),
    );
  }
}

class _AudioLyricsTrackSheetBody extends StatelessWidget {
  const _AudioLyricsTrackSheetBody({
    required this.player,
    required this.onSelectTrack,
  });

  final AudioPlayerService player;
  final void Function(int index) onSelectTrack;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tracks = player.effectiveSubtitles;
      final selectedIndex = player.selectedSubtitleIndex.value;

      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VideoSheetHeader(title: AppLocales.audio.lyricsTrack.tr),
            ...List.generate(tracks.length, (index) {
              final track = tracks[index];
              return VideoSheetOption(
                label: track.displayLabel,
                selected: selectedIndex == index,
                onTap: () {
                  onSelectTrack(index);
                  Get.back();
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
