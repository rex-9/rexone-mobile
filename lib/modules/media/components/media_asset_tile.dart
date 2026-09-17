import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';

import 'media_download_button.dart';
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
    required this.downloadState,
    required this.downloadProgress,
    required this.onDownloadTap,
    this.onDownloadPauseTap,
    this.onDownloadLongPress,
    this.showLoadingTrailing = true,
  });

  final AssetModel asset;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;
  final EMediaDownloadState downloadState;
  final double downloadProgress;
  final VoidCallback onDownloadTap;
  final VoidCallback? onDownloadPauseTap;
  final VoidCallback? onDownloadLongPress;

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
      subtitle: _subtitle(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MediaDownloadButton(
            state: downloadState,
            progress: downloadProgress,
            onPressed: onDownloadTap,
            onPausePressed: onDownloadPauseTap,
            onLongPress: onDownloadLongPress,
          ),
          if (isCurrent) _playbackTrailing(context),
        ],
      ),
    );
  }

  Widget? _subtitle(BuildContext context) {
    final typo = context.typo;
    final colors = context.colors;
    final duration = asset.displayDuration;
    final statusLabel = _downloadStatusLabel();

    if (duration.isEmpty && statusLabel == null) return null;

    final parts = <String>[
      if (duration.isNotEmpty) duration,
      ?statusLabel,
    ];

    return Text(
      parts.join(' · '),
      style: typo.bodySmall.copyWith(color: colors.textSecondary),
    );
  }

  String? _downloadStatusLabel() {
    switch (downloadState) {
      case EMediaDownloadState.queued:
        return AppLocales.media.downloadQueued.tr;
      case EMediaDownloadState.downloading:
        final percent = (downloadProgress.clamp(0, 1) * 100).round();
        return AppLocales.media.downloadProgress.trParams({
          'percent': '$percent',
        });
      case EMediaDownloadState.paused:
        final percent = (downloadProgress.clamp(0, 1) * 100).round();
        return AppLocales.media.downloadPaused.trParams({
          'percent': '$percent',
        });
      case EMediaDownloadState.processing:
        return AppLocales.media.processing.tr;
      case EMediaDownloadState.failed:
        return AppLocales.media.downloadFailed.tr;
      case EMediaDownloadState.none:
      case EMediaDownloadState.ready:
        return null;
    }
  }

  Widget _playbackTrailing(BuildContext context) {
    final colors = context.colors;

    if (showLoadingTrailing && isLoading) {
      return AppLoading(
        size: LoadingSize.small,
        color: colors.primary,
      );
    }

    final showPause =
        showLoadingTrailing ? isPlaying : (isPlaying || isLoading);
    return Icon(
      showPause ? Design.icons.pause : Design.icons.play,
      color: colors.primary,
      size: Design.spacing.iconLarge,
    );
  }
}
