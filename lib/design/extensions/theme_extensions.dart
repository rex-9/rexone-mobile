// lib/design/extensions/theme_extensions.dart
import 'package:flutter/material.dart';
import '../design.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension ThemeColors on BuildContext {
  AppThemeContextColors get colors => AppThemeContextColors(this);
}

class AppThemeContextColors {
  const AppThemeContextColors(this._context);
  final BuildContext _context;

  AppPalette get _palette =>
      _context.theme.brightness == Brightness.dark
          ? Design.colors.night
          : Design.colors.day;

  ColorScheme get colorScheme => _context.theme.colorScheme;

  Color get primary => _context.theme.colorScheme.primary;
  Color get secondary => _context.theme.colorScheme.secondary;
  Color get error => _context.theme.colorScheme.error;
  Color get background => _context.theme.scaffoldBackgroundColor;
  Color get surface => _context.theme.colorScheme.surface;
  Color get card =>
      _context.theme.cardTheme.color ?? _context.theme.colorScheme.surface;
  Color get cardLit => _palette.cardLit;
  Color get divider => _context.theme.dividerColor;
  Color get border => _context.theme.colorScheme.outline;
  Color get borderLit => _palette.borderLit;
  List<BoxShadow> get cardShadow => _palette.cardShadow;
  List<BoxShadow> get cardShadowLit => _palette.cardShadowLit;
  Color get textPrimary => _context.theme.colorScheme.onSurface;
  Color get textSecondary => _context.theme.colorScheme.onSurfaceVariant;
  Color get textMuted =>
      _context.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
  Color get textTertiary => textMuted;
  Color get onPrimary => _context.theme.colorScheme.onPrimary;
  Color get onError => _context.theme.colorScheme.onError;
  Color get onSecondary => _context.theme.colorScheme.onSecondary;
  Color get success => Design.colors.success;
  Color get onSuccess => Colors.white;
  Color get warning => Design.colors.warning;
  Color get onWarning => Colors.white;
  Color get info => Design.colors.info;
  Color get onInfo => Colors.white;
  Color get transparent => Design.colors.transparent;
}

extension ThemeTypography on BuildContext {
  AppThemeContextTypography get typo => AppThemeContextTypography(this);
}

class AppThemeContextTypography {
  const AppThemeContextTypography(this._context);
  final BuildContext _context;

  // Headlines
  TextStyle get headline1 => Design.typo.headline1.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  TextStyle get headline2 => Design.typo.headline2.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  TextStyle get headline3 => Design.typo.headline3.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  TextStyle get headline4 => Design.typo.headline4.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  // Body
  TextStyle get bodyLarge => Design.typo.bodyLarge.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  TextStyle get bodyMedium => Design.typo.bodyMedium.copyWith(
    color: _context.theme.colorScheme.onSurfaceVariant,
  );

  TextStyle get bodySmall => Design.typo.bodySmall.copyWith(
    color: _context.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
  );

  // Labels
  TextStyle get labelLarge => Design.typo.labelLarge.copyWith(
    color: _context.theme.colorScheme.onSurface,
  );

  TextStyle get labelMedium => Design.typo.labelMedium.copyWith(
    color: _context.theme.colorScheme.onSurfaceVariant,
  );

  // Buttons
  TextStyle get button =>
      Design.typo.button.copyWith(color: _context.theme.colorScheme.onSurface);

  // Caption & Helper
  TextStyle get caption => Design.typo.caption.copyWith(
    color: _context.theme.colorScheme.onSurfaceVariant,
  );

  TextStyle get helper => Design.typo.helper.copyWith(
    color: _context.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
  );

  TextStyle get link => Design.typo.link;
}
