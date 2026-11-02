// lib/design/elements/app_colors.dart
import 'package:flutter/material.dart';

/// RexOne Design System Colors — Unified with Rex9 Design System.
/// Provides pure brand, semantic, day (light), night (dark), and glassmorphic tokens.
class AppColors {
  const AppColors();

  // ===== BRAND (Rex9 Neon Scarlet Red Palette - More Red, Less Pink) =====
  Color get primary => const Color(0xFFFF2238);
  Color get primaryLight => const Color(0xFFFF5263);
  Color get primaryDark => const Color(0xFFCC1125);
  Color get secondary => const Color(0xFFFF4D2E);
  Color get accent => const Color(0xFFFF0D2D);

  // ===== NEON GLOW COLORS =====
  Color get transparent => const Color(0x00000000);
  Color get glowWhite => const Color(0xFFFFF2F4);
  Color get glowRuby => const Color(0xFF5C0916);

  // ===== SEMANTIC (Unified across Light & Dark) =====
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error => const Color(0xFFEF4444);
  Color get info => const Color(0xFF38BDF8);

  // ===== DAY THEME (Light Mode) =====
  AppDayColors get day => const AppDayColors();

  // ===== NIGHT THEME (Dark Mode - Rex9 Cyber Aesthetic) =====
  AppNightColors get night => const AppNightColors();

  // ===== GLASSMORPHISM =====
  AppGlassColors get glass => const AppGlassColors();

  // ===== GRADIENTS & SHADOWS =====
  GradientColors get gradient => const GradientColors();
  Shadows get shadows => const Shadows();
}

/// 1:1 Theme Palette Contract — Every token in Day (`AppDayColors`) has an
/// exact 1:1 counterpart in Night (`AppNightColors`).
abstract class AppPalette {
  const AppPalette();

  Color get background;
  Color get surface;
  Color get card;
  Color get cardLit;
  Color get border;
  Color get borderLit;
  Color get divider;
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;
  List<BoxShadow> get cardShadow;
  List<BoxShadow> get cardShadowLit;
}

class AppDayColors extends AppPalette {
  const AppDayColors();

  @override
  Color get background => const Color(0xFFFAFAF8);
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get card => const Color(0xFFF5F5F3);
  @override
  Color get cardLit => const Color(0xFFF0F0EE);
  @override
  Color get border => const Color(0xFFE5E7EB);
  @override
  Color get borderLit => const Color(0xD9FF2238);
  @override
  Color get divider => const Color(0xFFF3F4F6);
  @override
  Color get textPrimary => const Color(0xFF111827);
  @override
  Color get textSecondary => const Color(0xFF4B5563);
  @override
  Color get textMuted => const Color(0xFF9CA3AF);
  @override
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
  @override
  List<BoxShadow> get cardShadowLit => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: const Color(0xFFFF2238).withValues(alpha: 0.15),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];
}

class AppNightColors extends AppPalette {
  const AppNightColors();

  @override
  Color get background => const Color(0xFF160B11);
  @override
  Color get surface => const Color(0xFF1F1018);
  @override
  Color get card => const Color(0xFF26131E);
  @override
  Color get cardLit => const Color(0xF228121E);
  @override
  Color get border => const Color(0xFF3D1B28);
  @override
  Color get borderLit => const Color(0xB3FF2238);
  @override
  Color get divider => const Color(0xFF2C111C);
  @override
  Color get textPrimary => const Color(0xFFFFFFFF);
  @override
  Color get textSecondary => const Color(0xFFE2D4D8);
  @override
  Color get textMuted => const Color(0xFFA39298);
  @override
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  @override
  List<BoxShadow> get cardShadowLit => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFFFF2238).withValues(alpha: 0.18),
      blurRadius: 20,
      spreadRadius: 1,
    ),
  ];
}

class AppGlassColors {
  const AppGlassColors();

  Color get nav => const Color(0xBF16070D);
  Color get card => const Color(0x61230C14);
  Color get cardHover => const Color(0x8C32101C);
  Color get form => const Color(0xA61C0810);
  Color get project => const Color(0x8C12060C);
  Color get border => const Color(0x38FF2238);
  Color get borderHover => const Color(0x8CFF2238);
  Color get tag => const Color(0xA6FF2238);
  Color get tagBg => const Color(0x14FF2238);
}

class GradientColors {
  const GradientColors();
  final AppColors _colors = const AppColors();

  LinearGradient get primary => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_colors.primary, _colors.secondary],
  );

  LinearGradient get success => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_colors.success, const Color(0xFF34D399)],
  );

  LinearGradient get error => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_colors.error, const Color(0xFFF87171)],
  );
}

class Shadows {
  const Shadows();

  List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  List<BoxShadow> get neon => const [
    BoxShadow(
      color: Color(0xFFFF2238),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0xFFCC1125),
      blurRadius: 25,
    ),
  ];

  List<BoxShadow> get neonLg => const [
    BoxShadow(
      color: Color(0xFFFF2238),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0xFFCC1125),
      blurRadius: 25,
    ),
    BoxShadow(
      color: Color(0xFF5C0916),
      blurRadius: 50,
    ),
  ];

  List<BoxShadow> get glassCard => const [
    BoxShadow(
      color: Color(0x59FF2238),
      blurRadius: 30,
      offset: Offset(0, 6),
    ),
  ];

  List<BoxShadow> get glassHover => const [
    BoxShadow(
      color: Color(0x73FF2238),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}
