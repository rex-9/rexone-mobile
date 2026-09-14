import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Selectable row for video bottom sheets.
class VideoSheetOption extends StatelessWidget {
  const VideoSheetOption({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
    this.selected = false,
    this.showChevron = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool selected;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final colors = Design.colors.night;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: Design.spacing.paddingSymmetric(
            h: Design.spacing.lg,
            v: Design.spacing.md,
          ),
          child: Row(
            children: [
              if (selected)
                Padding(
                  padding: Design.spacing.paddingOnly(r: Design.spacing.md),
                  child: Icon(
                    Design.icons.listCheck,
                    color: colors.textPrimary,
                    size: Design.spacing.iconMedium,
                  ),
                )
              else if (!showChevron)
                SizedBox(width: Design.spacing.xl + Design.spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: typo.bodyMedium.copyWith(
                    color: selected ? colors.textPrimary : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: typo.bodyMedium.copyWith(color: colors.textMuted),
                ),
              if (showChevron)
                Icon(
                  Design.icons.rightArrow,
                  color: colors.textMuted,
                  size: Design.spacing.iconLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
