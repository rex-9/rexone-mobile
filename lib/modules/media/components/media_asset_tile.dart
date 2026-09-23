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
    this.downloadEntry,
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
  final MediaDownloadEntry? downloadEntry;
  final VoidCallback onDownloadTap;
  final VoidCallback? onDownloadPauseTap;
  final VoidCallback? onDownloadLongPress;

  final bool showLoadingTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final tileArtSize = Design.spacing.xxxl + Design.spacing.lg;

    return AppListTile(
      onTap: onTap,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          TrackArtwork(
            url: asset.displayThumbnailUrl,
            size: tileArtSize,
          ),
          if (isCurrent)
            Container(
              width: tileArtSize,
              height: tileArtSize,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(Design.spacing.radiusSmall),
              ),
              child: Center(
                child: isLoading
                    ? AppLoading(size: LoadingSize.small, color: colors.onPrimary)
                    : Icon(
                        isPlaying ? Design.icons.pause : Design.icons.play,
                        color: colors.onPrimary,
                        size: Design.spacing.iconMedium,
                      ),
              ),
            ),
        ],
      ),
      title: Text(
        asset.displayTitle,
        style: typo.bodyLarge.copyWith(
          color: isCurrent ? colors.primary : colors.textPrimary,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: _subtitle(context),
      trailing: MediaDownloadButton(
        state: downloadState,
        progress: downloadProgress,
        sizeText: asset.displaySize,
        onPressed: onDownloadTap,
        onPausePressed: onDownloadPauseTap,
        onLongPress: onDownloadLongPress,
      ),
    );
  }

  String _typeLabel() {
    if (asset.isAudioMedia) return AppLocales.media.typeAudio.tr;
    if (asset.isVideoMedia) return AppLocales.media.typeVideo.tr;
    if (asset.isImageMedia) return AppLocales.media.typeImage.tr;
    if (asset.isAttachment) return AppLocales.media.typeAttachment.tr;
    return '';
  }

  Widget? _subtitle(BuildContext context) {
    final typo = context.typo;
    final colors = context.colors;
    final duration = asset.displayDuration;
    final size = downloadEntry?.formattedSize ?? asset.displaySize;
    final typeLabel = _typeLabel();

    String? text;
    switch (downloadState) {
      case EMediaDownloadState.none:
        final parts = [
          if (typeLabel.isNotEmpty) typeLabel,
          if (duration.isNotEmpty) duration,
          if (size.isNotEmpty) size,
        ];
        if (parts.isNotEmpty) text = parts.join(' · ');
      case EMediaDownloadState.queued:
        final parts = [
          if (typeLabel.isNotEmpty) typeLabel,
          if (duration.isNotEmpty) duration,
          if (size.isNotEmpty) size,
          AppLocales.media.downloadQueued.tr,
        ];
        text = parts.join(' · ');
      case EMediaDownloadState.downloading:
        final percent = (downloadProgress.clamp(0, 1) * 100).round();
        final progSize = downloadEntry?.formattedProgressSize;
        if (progSize != null && progSize.isNotEmpty) {
          text = '${AppLocales.media.downloading.tr} $progSize ($percent%)';
        } else {
          text = AppLocales.media.downloadProgress.trParams({'percent': '$percent'});
        }
      case EMediaDownloadState.paused:
        final percent = (downloadProgress.clamp(0, 1) * 100).round();
        final progSize = downloadEntry?.formattedProgressSize;
        if (progSize != null && progSize.isNotEmpty) {
          text = '${AppLocales.media.downloadPaused.trParams({'percent': '$percent'})} ($progSize)';
        } else {
          text = AppLocales.media.downloadPaused.trParams({'percent': '$percent'});
        }
      case EMediaDownloadState.processing:
        text = AppLocales.media.processing.tr;
      case EMediaDownloadState.ready:
        final parts = [
          if (typeLabel.isNotEmpty) typeLabel,
          if (duration.isNotEmpty) duration,
          if (size.isNotEmpty) size,
          AppLocales.media.downloaded.tr,
        ];
        text = parts.join(' · ');
      case EMediaDownloadState.failed:
        text = AppLocales.media.downloadFailed.tr;
    }

    if (text == null || text.isEmpty) return null;

    return Text(
      text,
      style: typo.bodySmall.copyWith(color: colors.textSecondary),
    );
  }
}
