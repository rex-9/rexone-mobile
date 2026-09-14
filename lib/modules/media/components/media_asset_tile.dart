import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';

import 'track_artwork.dart';

/// Shared playlist row for audio and video asset lists.
class MediaAssetTile extends StatelessWidget {
  const MediaAssetTile({
    super.key,
    required this.asset,
    required this.isCurrent,
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
    this.showLoadingTrailing = true,
  });

  final AssetModel asset;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  /// When true, the current row shows a spinner while [isLoading].
  /// When false, shows pause icon if [isPlaying] or [isLoading] (video player).
  final bool showLoadingTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final tileArtSize = Design.spacing.xxxl + Design.spacing.lg;

    return AppListTile(
      onTap: onTap,
      leading: TrackArtwork(
        url: asset.displayThumbnailUrl,
        size: tileArtSize,
      ),
      title: Text(
        asset.displayTitle,
        style: typo.bodyLarge.copyWith(
          color: isCurrent ? colors.primary : colors.textPrimary,
        ),
      ),
      subtitle: asset.displayDuration.isNotEmpty
          ? Text(asset.displayDuration)
          : null,
      trailing: isCurrent ? _trailing(context) : null,
    );
  }

  Widget? _trailing(BuildContext context) {
    final colors = context.colors;

    if (showLoadingTrailing && isLoading) {
      return AppLoading(
        size: LoadingSize.small,
        color: colors.primary,
      );
    }

    final showPause = showLoadingTrailing ? isPlaying : (isPlaying || isLoading);
    return Icon(
      showPause ? Design.icons.pause : Design.icons.play,
      color: colors.primary,
      size: Design.spacing.iconLarge,
    );
  }
}
