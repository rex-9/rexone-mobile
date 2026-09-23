import 'package:flutter/material.dart';
import 'package:rexone_mobile/constants/enums.dart';
import 'package:rexone_mobile/design/design.dart';

import 'track_artwork.dart';

/// Hero artwork, title, subtitle, play-all and download-all for the media library.
class MediaPlaylistHeader extends StatelessWidget {
  const MediaPlaylistHeader({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.playAllLabel,
    required this.downloadAllLabel,
    required this.canPlay,
    required this.canDownloadAll,
    required this.isPlayAllLoading,
    required this.isDownloadAllLoading,
    required this.onPlayAll,
    required this.onDownloadAll,
  });

  final String thumbnailUrl;
  final String title;
  final String subtitle;
  final String playAllLabel;
  final String downloadAllLabel;
  final bool canPlay;
  final bool canDownloadAll;
  final bool isPlayAllLoading;
  final bool isDownloadAllLoading;
  final VoidCallback? onPlayAll;
  final VoidCallback? onDownloadAll;

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
        SizedBox(height: Design.spacing.sm),
        AppButton(
          type: EButtonType.secondary,
          text: downloadAllLabel,
          icon: isDownloadAllLoading ? null : Design.icons.download,
          onPressed: canDownloadAll ? onDownloadAll : null,
          isExpanded: true,
        ),
        SizedBox(height: Design.spacing.xxl),
      ],
    );
  }
}
