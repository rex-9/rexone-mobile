// lib/design/components/app_badge.dart
import 'package:flutter/material.dart';
import '../design.dart';

class AppBadge extends StatefulWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.type = EBadgeVariant.info,
    this.icon,
    this.onTap,
  });

  final String text;
  final EBadgeVariant type;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  State<AppBadge> createState() => _AppBadgeState();
}

class _AppBadgeState extends State<AppBadge> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadows;

    switch (widget.type) {
      case EBadgeVariant.neon:
        bg = _isPressed ? Design.colors.primary : Design.colors.glass.tagBg;
        fg = _isPressed ? Colors.white : Design.colors.glowWhite;
        border = Border.all(
          color: _isPressed ? Design.colors.primary : Design.colors.glass.tag,
        );
        shadows = _isPressed ? Design.colors.shadows.neon : null;
        break;
      case EBadgeVariant.primary:
        bg = _isPressed
            ? colors.primary
            : colors.primary.withValues(alpha: 0.15);
        fg = _isPressed ? Colors.white : colors.primary;
        border = Border.all(color: colors.primary.withValues(alpha: 0.3));
        shadows = _isPressed ? Design.colors.shadows.neon : null;
        break;
      case EBadgeVariant.secondary:
      case EBadgeVariant.defaultVariant:
        bg = _isPressed
            ? colors.secondary
            : colors.secondary.withValues(alpha: 0.18);
        fg = _isPressed ? Design.colors.primaryDark : colors.primary;
        border = Border.all(color: colors.secondary.withValues(alpha: 0.35));
        break;
      case EBadgeVariant.success:
        bg = Design.colors.success.withValues(alpha: 0.15);
        fg = Design.colors.success;
        break;
      case EBadgeVariant.warning:
        bg = Design.colors.warning.withValues(alpha: 0.15);
        fg = Design.colors.warning;
        break;
      case EBadgeVariant.error:
        bg = Design.colors.error.withValues(alpha: 0.15);
        fg = Design.colors.error;
        break;
      case EBadgeVariant.info:
        bg = colors.primary.withValues(alpha: 0.15);
        fg = colors.primary;
        break;
    }

    final badgeContent = AnimatedContainer(
      duration: Design.timers.short,
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: Design.spacing.md,
        vertical: Design.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        boxShadow: shadows,
        borderRadius: BorderRadius.circular(Design.spacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: AppFontSizes.bodyMedium, color: fg),
            SizedBox(width: Design.spacing.xs),
          ],
          Text(
            widget.text,
            style: Design.typo.caption.copyWith(
              color: fg,
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
        ],
      ),
    );

    if (widget.onTap == null) {
      return badgeContent;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: Design.timers.short,
      curve: Curves.easeOut,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (highlighted) {
          setState(() => _isPressed = highlighted);
        },
        borderRadius: BorderRadius.circular(Design.spacing.radiusSmall),
        child: badgeContent,
      ),
    );
  }
}
