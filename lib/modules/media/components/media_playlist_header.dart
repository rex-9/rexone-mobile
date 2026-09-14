import 'package:flutter/material.dart';
import 'package:rexone_mobile/constants/enums.dart';
import 'package:rexone_mobile/design/design.dart';

import 'track_artwork.dart';

/// Hero artwork, title, subtitle, and play-all button for playlist pages.
class MediaPlaylistHeader extends StatelessWidget {
  const MediaPlaylistHeader({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.playAllLabel,
    required this.canPlay,
    required this.isPlayAllLoading,
    required this.onPlayAll,
  });

  final String thumbnailUrl;
  final String title;
  final String subtitle;
  final String playAllLabel;
  final bool canPlay;
  final bool isPlayAllLoading;
  final VoidCallback? onPlayAll;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final heroSize = Design.spacing.xxxl * 4;

    return Column(
      children: [
        Center(
          child: TrackArtwork(
            url: thumbnailUrl,
            size: heroSize,
            radius: Design.spacing.radiusLarge,
          ),
        ),
        SizedBox(height: Design.spacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: typo.headline3,
        ),
        SizedBox(height: Design.spacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: typo.bodyMedium,
        ),
        SizedBox(height: Design.spacing.xl),
        AppButton(
          type: EButtonType.primary,
          text: playAllLabel,
          icon: isPlayAllLoading ? null : Design.icons.play,
          onPressed: canPlay ? onPlayAll : null,
          isExpanded: true,
        ),
        SizedBox(height: Design.spacing.xxl),
      ],
    );
  }
}
