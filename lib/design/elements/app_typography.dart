// lib/design/elements/app_typography.dart
import 'package:flutter/material.dart';

/// Typography font sizes matching design system tokens.
class AppFontSizes {
  const AppFontSizes();

  static const double displayXL = 56.0;
  static const double displayL = 48.0;
  static const double displayM = 36.0;
  static const double h1 = 32.0;
  static const double h2 = 28.0;
  static const double h3 = 24.0;
  static const double h4 = 20.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;
  static const double button = 16.0;
  static const double caption = 12.0;
  static const double helper = 12.0;
  static const double link = 14.0;

  double get displayXlValue => displayXL;
  double get displayLValue => displayL;
  double get displayMValue => displayM;
  double get h1Value => h1;
  double get h2Value => h2;
  double get h3Value => h3;
  double get h4Value => h4;
  double get bodyLargeValue => bodyLarge;
  double get bodyMediumValue => bodyMedium;
  double get bodySmallValue => bodySmall;
  double get labelLargeValue => labelLarge;
  double get labelMediumValue => labelMedium;
  double get labelSmallValue => labelSmall;
  double get buttonValue => button;
  double get captionValue => caption;
  double get helperValue => helper;
  double get linkValue => link;
}

/// Typography font weights matching design system tokens.
class AppFontWeights {
  const AppFontWeights();

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  FontWeight get lightWeight => light;
  FontWeight get regularWeight => regular;
  FontWeight get mediumWeight => medium;
  FontWeight get semiBoldWeight => semiBold;
  FontWeight get boldWeight => bold;
}

/// Typography line heights matching design system tokens.
class AppLineHeights {
  const AppLineHeights();

  static const double tight = 1.2;
  static const double snug = 1.3;
  static const double normal = 1.4;
  static const double relaxed = 1.5;

  double get tightHeight => tight;
  double get snugHeight => snug;
  double get normalHeight => normal;
  double get relaxedHeight => relaxed;
}

/// Typography letter spacings matching design system tokens.
class AppLetterSpacings {
  const AppLetterSpacings();

  static const double tight = -0.5;
  static const double normal = 0.0;
  static const double wide = 0.5;
  static const double wider = 1.2;

  double get tightSpacing => tight;
  double get normalSpacing => normal;
  double get wideSpacing => wide;
  double get widerSpacing => wider;
}

/// Typography font family names.
abstract final class AppFontFamilies {
  static const String primary = 'Quicksand';
  static const String display = 'Clip';
  static const String handwritten = 'Storytime';
}

class AppTypography {
  const AppTypography();

  // Font family names
  String get primary => AppFontFamilies.primary;
  String get display => AppFontFamilies.display;
  String get handwritten => AppFontFamilies.handwritten;
  String get fontFamily => primary;

  // Constant token accessors
  AppFontSizes get sizes => const AppFontSizes();
  AppFontWeights get weights => const AppFontWeights();
  AppLineHeights get lineHeights => const AppLineHeights();
  AppLetterSpacings get letterSpacings => const AppLetterSpacings();

  // Headings
  TextStyle get headline1 => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.h1,
        fontWeight: AppFontWeights.bold,
        height: AppLineHeights.tight,
        letterSpacing: AppLetterSpacings.tight,
      );

  TextStyle get headline2 => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.h2,
        fontWeight: AppFontWeights.bold,
        height: AppLineHeights.tight,
        letterSpacing: AppLetterSpacings.tight,
      );

  TextStyle get headline3 => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.h3,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.snug,
      );

  TextStyle get headline4 => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.h4,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.snug,
      );

  // Body
  TextStyle get bodyLarge => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.bodyLarge,
        fontWeight: AppFontWeights.regular,
        height: AppLineHeights.relaxed,
      );

  TextStyle get bodyMedium => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.bodyMedium,
        fontWeight: AppFontWeights.regular,
        height: AppLineHeights.relaxed,
      );

  TextStyle get bodySmall => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.bodySmall,
        fontWeight: AppFontWeights.regular,
        height: AppLineHeights.relaxed,
      );

  // Labels
  TextStyle get labelLarge => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.labelLarge,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.normal,
      );

  TextStyle get labelMedium => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.labelMedium,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.normal,
      );

  TextStyle get labelSmall => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.labelSmall,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.normal,
      );

  // Action / Utility
  TextStyle get button => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.button,
        fontWeight: AppFontWeights.semiBold,
        height: AppLineHeights.tight,
        letterSpacing: AppLetterSpacings.wide,
      );

  TextStyle get caption => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.caption,
        fontWeight: AppFontWeights.regular,
        height: AppLineHeights.normal,
      );

  TextStyle get helper => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.helper,
        fontWeight: AppFontWeights.regular,
        height: AppLineHeights.snug,
      );

  TextStyle get link => const TextStyle(
        fontFamily: AppFontFamilies.primary,
        fontSize: AppFontSizes.link,
        fontWeight: AppFontWeights.medium,
        height: AppLineHeights.normal,
        decoration: TextDecoration.underline,
      );
}
