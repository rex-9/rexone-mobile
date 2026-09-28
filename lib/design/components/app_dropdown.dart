// lib/design/components/app_dropdown.dart
import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Represents a single selectable option in [AppDropdown].
class AppDropdownOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool disabled;

  const AppDropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

enum AppDropdownSize {
  small,
  medium,
  large,
}

/// Universal reusable dropdown component matching RexOne design system.
///
/// Mirrors Web's `Dropdown.tsx` with:
/// - Deterministic option selection
/// - Custom label, hint, error, prefix icon
/// - Configurable size (small, medium, large)
/// - Full-width or inline width modes
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.prefixIcon,
    this.size = AppDropdownSize.medium,
    this.fullWidth = true,
    this.enabled = true,
  });

  final List<AppDropdownOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final Widget? prefixIcon;
  final AppDropdownSize size;
  final bool fullWidth;
  final bool enabled;

  double get _height {
    switch (size) {
      case AppDropdownSize.small:
        return 36.0;
      case AppDropdownSize.medium:
        return 48.0;
      case AppDropdownSize.large:
        return 56.0;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppDropdownSize.small:
        return EdgeInsets.symmetric(
          horizontal: Design.spacing.sm,
          vertical: 2.0,
        );
      case AppDropdownSize.medium:
        return EdgeInsets.symmetric(
          horizontal: Design.spacing.md,
          vertical: Design.spacing.xs,
        );
      case AppDropdownSize.large:
        return EdgeInsets.symmetric(
          horizontal: Design.spacing.lg,
          vertical: Design.spacing.sm,
        );
    }
  }

  TextStyle _textStyle(BuildContext context) {
    switch (size) {
      case AppDropdownSize.small:
        return context.typo.bodySmall;
      case AppDropdownSize.medium:
        return context.typo.bodyMedium;
      case AppDropdownSize.large:
        return context.typo.bodyLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = error != null && error!.isNotEmpty;

    final dropdownWidget = Container(
      height: _height,
      padding: _padding,
      decoration: BoxDecoration(
        color: enabled ? colors.surface : colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
        border: Border.all(
          color: hasError ? colors.error : colors.border,
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: fullWidth,
          isDense: size == AppDropdownSize.small,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: size == AppDropdownSize.small ? 18 : 22,
            color: enabled ? colors.textMuted : colors.border,
          ),
          hint: hint != null
              ? Text(
                  hint!,
                  style: _textStyle(context).copyWith(color: colors.textMuted),
                )
              : null,
          dropdownColor: colors.surface,
          borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
          style: _textStyle(context).copyWith(
            color: enabled ? colors.textPrimary : colors.textMuted,
          ),
          items: options.map((opt) {
            return DropdownMenuItem<T>(
              value: opt.value,
              enabled: enabled && !opt.disabled,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (opt.icon != null) ...[
                    Icon(
                      opt.icon,
                      size: size == AppDropdownSize.small ? 16 : 18,
                      color: opt.disabled
                          ? colors.textMuted
                          : (value == opt.value ? colors.primary : colors.textPrimary),
                    ),
                    SizedBox(width: Design.spacing.xs),
                  ],
                  Text(
                    opt.label,
                    style: _textStyle(context).copyWith(
                      color: opt.disabled
                          ? colors.textMuted
                          : (value == opt.value ? colors.primary : colors.textPrimary),
                      fontWeight: value == opt.value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );

    if (label == null && error == null) {
      return fullWidth ? dropdownWidget : IntrinsicWidth(child: dropdownWidget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.typo.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          SizedBox(height: Design.spacing.xs),
        ],
        fullWidth ? dropdownWidget : IntrinsicWidth(child: dropdownWidget),
        if (hasError) ...[
          SizedBox(height: Design.spacing.xs),
          Text(
            error!,
            style: context.typo.caption.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
