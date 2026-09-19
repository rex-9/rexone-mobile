import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

/// Trailing control for per-item offline download state on playlist rows.
///
/// Queued/downloading: progress ring with pause icon inside.
/// Paused: progress ring with download icon inside (tap to resume).
class MediaDownloadButton extends StatelessWidget {
  const MediaDownloadButton({
    super.key,
    required this.state,
    required this.progress,
    required this.onPressed,
    this.sizeText,
    this.onPausePressed,
    this.onLongPress,
  });

  final EMediaDownloadState state;
  final double progress;
  final String? sizeText;
  final VoidCallback onPressed;
  final VoidCallback? onPausePressed;
  final VoidCallback? onLongPress;

  bool get _showsProgressRing =>
      state == EMediaDownloadState.queued ||
      state == EMediaDownloadState.downloading ||
      state == EMediaDownloadState.paused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = Design.spacing.iconLarge;
    final innerIconSize = Design.spacing.iconSmall;
    final buttonConstraints = BoxConstraints.tightFor(
      width: size + Design.spacing.md,
      height: size + Design.spacing.md,
    );

    if (_showsProgressRing) {
      final isPaused = state == EMediaDownloadState.paused;
      return Tooltip(
        message: _tooltip,
        child: IconButton(
          onPressed: isPaused ? onPressed : (onPausePressed ?? onPressed),
          onLongPress: onLongPress,
          visualDensity: VisualDensity.compact,
          padding: Design.spacing.padding(Design.spacing.xs),
          constraints: buttonConstraints,
          icon: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (state == EMediaDownloadState.queued)
                  AppLoading(size: LoadingSize.small, color: colors.primary)
                else
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                Icon(
                  isPaused ? Design.icons.download : Design.icons.pause,
                  color: colors.primary,
                  size: innerIconSize,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: _tooltip,
      child: IconButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        visualDensity: VisualDensity.compact,
        padding: Design.spacing.padding(Design.spacing.xs),
        constraints: buttonConstraints,
        icon: _icon(context, size, colors.primary, colors.textSecondary, colors.error),
      ),
    );
  }

  String get _tooltip {
    switch (state) {
      case EMediaDownloadState.none:
        if (sizeText != null && sizeText!.isNotEmpty) {
          return AppLocales.media.downloadWithSize.trParams({'size': sizeText!});
        }
        return AppLocales.media.download.tr;
      case EMediaDownloadState.queued:
        return AppLocales.media.pauseDownload.tr;
      case EMediaDownloadState.downloading:
        final percent = (progress.clamp(0, 1) * 100).round();
        return AppLocales.media.downloadProgress.trParams({
          'percent': '$percent',
        });
      case EMediaDownloadState.paused:
        return AppLocales.media.resumeDownload.tr;
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
    Color secondary,
    Color error,
  ) {
    switch (state) {
      case EMediaDownloadState.none:
        return Icon(Design.icons.download, color: primary, size: size);
      case EMediaDownloadState.queued:
      case EMediaDownloadState.downloading:
      case EMediaDownloadState.paused:
        return const SizedBox.shrink();
      case EMediaDownloadState.processing:
        return SizedBox(
          width: size,
          height: size,
          child: AppLoading(size: LoadingSize.small, color: primary),
        );
      case EMediaDownloadState.ready:
        return Icon(Design.icons.close, color: secondary, size: size);
      case EMediaDownloadState.failed:
        return Icon(Design.icons.refresh, color: error, size: size);
    }
  }
}
