// lib/design/components/app_card.dart
import 'package:flutter/material.dart';
import '../design.dart';

/// RexOne Design System Card Component
///
/// Features:
/// - Consistent crisp borders in both dark and light modes
/// - Elevation and depth shadows conforming to Apple HIG and Rex9 Cyber Aesthetic tokens
/// - Anti-aliased corner clipping
/// - [AppCard.grouped] factory to display item lists with automated dividers
/// - [AppSectionCard] for section header + grouped card pattern
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.isLit = false,
  });

  /// Factory constructor for grouped cards (e.g. settings sections, form rows)
  /// Automatically places a standard divider between each child.
  factory AppCard.grouped({
    Key? key,
    required List<Widget> children,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    bool isLit = false,
  }) {
    return AppCard(
      key: key,
      margin: margin,
      padding: EdgeInsets.zero,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      isLit: isLit,
      child: _GroupedCardBody(children: children),
    );
  }

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isLit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? Design.spacing.radiusLarge;
    final innerRadius = (radius - borderWidth).clamp(0.0, double.infinity);

    // Background color: elevated dark surface or crisp white day surface
    final defaultBg = isDark
        ? (isLit ? const Color(0xF228121E) : colors.surface)
        : colors.surface;

    // Border: crisp primary for lit, balanced border for dark/light
    final defaultBorder = isDark
        ? (isLit
            ? Design.colors.primary.withValues(alpha: 0.70)
            : colors.border)
        : (isLit
            ? Design.colors.primary.withValues(alpha: 0.85)
            : colors.border);

    // Box shadows for physical elevation and neon radiance
    final defaultShadow = boxShadow ??
        (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                if (isLit)
                  BoxShadow(
                    color: Design.colors.primary.withValues(alpha: 0.18),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
                if (isLit)
                  BoxShadow(
                    color: Design.colors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
              ]);

    final cardDecoration = BoxDecoration(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: borderWidth,
      ),
      boxShadow: defaultShadow,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        decoration: cardDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(innerRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? EdgeInsets.all(Design.spacing.lg),
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(Design.spacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class _GroupedCardBody extends StatelessWidget {
  const _GroupedCardBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: context.colors.divider,
            indent: Design.spacing.lg,
            endIndent: Design.spacing.lg,
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}

/// Reusable section component with header label and grouped card container
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    this.title,
    this.trailingAction,
    required this.children,
    this.margin,
  });

  final String? title;
  final Widget? trailingAction;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: Design.spacing.sm,
                right: Design.spacing.sm,
                bottom: Design.spacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title!.toUpperCase(),
                      style: context.typo.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingAction != null) trailingAction!,
                ],
              ),
            ),
          ],
          AppCard.grouped(children: children),
        ],
      ),
    );
  }
}
