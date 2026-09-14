import 'package:flutter/material.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

/// Shared dark bottom sheet shell for video player settings.
class VideoBottomSheet {
  const VideoBottomSheet._();

  static Future<void> show(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Design.colors.night.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Design.spacing.radiusMedium),
        ),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height *
            MediaLayoutConstants.videoSheetMaxHeightFraction;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: child,
        );
      },
    );
  }
}
