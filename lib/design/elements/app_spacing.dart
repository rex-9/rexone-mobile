// lib/design/elements/app_spacing.dart

import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing();

  // Base unit: 4px
  double get xs => 4.0; // 4px
  double get sm => 8.0; // 8px
  double get md => 12.0; // 12px
  double get lg => 16.0; // 16px
  double get xl => 20.0; // 20px
  double get xxl => 24.0; // 24px
  double get xxxl => 32.0; // 32px

  // Screen padding
  double get screenPadding => 20.0;
  double get screenPaddingSmall => 16.0;

  // Card padding
  double get cardPadding => 16.0;
  double get cardPaddingSmall => 12.0;

  // Button padding
  double get buttonVertical => 12.0;
  double get buttonHorizontal => 24.0;
  double get buttonHeight => 48.0;
  double get buttonSmallHeight => 40.0;

  // Input padding
  double get inputVertical => 14.0;
  double get inputHorizontal => 16.0;

  // Border radius
  double get radiusSmall => 8.0;
  double get radiusMedium => 12.0;
  double get radiusLarge => 16.0;
  double get radiusXLarge => 24.0;

  // Icon sizes
  double get iconSmall => 16.0;
  double get iconMedium => 20.0;
  double get iconLarge => 24.0;
  double get iconXLarge => 32.0;

  // Avatar
  double get avatarRadius => 48.0;
  double get avatarBadgeRadius => 16.0;

  // ===== EDGE INSETS HELPERS =====

  /// Creates EdgeInsets with same value on all sides
  EdgeInsets padding(double value) => EdgeInsets.all(value);

  /// Creates EdgeInsets with horizontal and/or vertical values
  EdgeInsets paddingSymmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  /// Creates EdgeInsets with individual side values
  EdgeInsets paddingOnly({
    double l = 0,
    double t = 0,
    double r = 0,
    double b = 0,
  }) => EdgeInsets.only(left: l, top: t, right: r, bottom: b);

  /// Creates EdgeInsets.zero
  EdgeInsets get zero => EdgeInsets.zero;
}
