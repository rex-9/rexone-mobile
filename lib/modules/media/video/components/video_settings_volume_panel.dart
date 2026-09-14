import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

import 'video_sheet_header.dart';

/// Volume slider panel inside the settings sheet.
class VideoSettingsVolumePanel extends StatelessWidget {
  const VideoSettingsVolumePanel({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onBack,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final VoidCallback onBack;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Design.colors.night;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VideoSheetHeader(title: title, onBack: onBack),
        Padding(
          padding: Design.spacing.paddingSymmetric(
            h: Design.spacing.lg,
            v: Design.spacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: colors.textSecondary,
                size: Design.spacing.iconLarge,
              ),
              SizedBox(width: Design.spacing.md),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: colors.textPrimary,
                    inactiveTrackColor: colors.textMuted.withValues(alpha: 0.35),
                    thumbColor: colors.textPrimary,
                    overlayColor: colors.textMuted.withValues(alpha: 0.24),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
