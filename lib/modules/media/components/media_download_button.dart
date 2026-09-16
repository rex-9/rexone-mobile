import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

/// Trailing control for per-item offline download state on playlist rows.
class MediaDownloadButton extends StatelessWidget {
  const MediaDownloadButton({
    super.key,
    required this.state,
    required this.progress,
    required this.onPressed,
  });

  final EMediaDownloadState state;
  final double progress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = Design.spacing.iconLarge;

    return Tooltip(
      message: _tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        padding: Design.spacing.padding(Design.spacing.xs),
        constraints: BoxConstraints.tightFor(width: size + Design.spacing.md),
        icon: _icon(context, size, colors.primary, colors.error),
      ),
    );
  }

  String get _tooltip {
    switch (state) {
      case EMediaDownloadState.none:
        return AppLocales.media.download.tr;
      case EMediaDownloadState.queued:
        return AppLocales.media.downloadQueued.tr;
      case EMediaDownloadState.downloading:
        final percent = (progress.clamp(0, 1) * 100).round();
        return AppLocales.media.downloadProgress.trParams({
          'percent': '$percent',
        });
      case EMediaDownloadState.processing:
        return AppLocales.media.processing.tr;
      case EMediaDownloadState.ready:
        return AppLocales.media.removeDownload.tr;
      case EMediaDownloadState.failed:
        return AppLocales.media.downloadFailed.tr;
    }
  }

  Widget _icon(
    BuildContext context,
    double size,
    Color primary,
    Color error,
  ) {
    switch (state) {
      case EMediaDownloadState.none:
        return Icon(Design.icons.download, color: primary, size: size);
      case EMediaDownloadState.queued:
        return SizedBox(
          width: size,
          height: size,
          child: AppLoading(size: LoadingSize.small, color: primary),
        );
      case EMediaDownloadState.downloading:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 2.5,
            color: primary,
          ),
        );
      case EMediaDownloadState.processing:
        return SizedBox(
          width: size,
          height: size,
          child: AppLoading(size: LoadingSize.small, color: primary),
        );
      case EMediaDownloadState.ready:
        return Icon(Design.icons.downloadDone, color: primary, size: size);
      case EMediaDownloadState.failed:
        return Icon(Design.icons.error, color: error, size: size);
    }
  }
}
