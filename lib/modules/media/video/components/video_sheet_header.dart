import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Title row for video bottom sheets (optional back action).
class VideoSheetHeader extends StatelessWidget {
  const VideoSheetHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final colors = context.colors;

    return Padding(
      padding: Design.spacing.paddingSymmetric(
        h: Design.spacing.lg,
        v: Design.spacing.md,
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: Icon(
                Design.icons.backArrow,
                color: colors.textSecondary,
              ),
              onPressed: onBack,
            )
          else
            SizedBox(width: Design.spacing.xxxl + Design.spacing.sm),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: typo.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: Design.spacing.xxxl + Design.spacing.sm),
        ],
      ),
    );
  }
}
