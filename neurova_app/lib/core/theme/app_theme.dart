import 'package:flutter/material.dart';

/// App theme configuration for dark and light modes
class AppTheme {
  AppTheme._();

  // ─── DARK MODE ────────────────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D14),
      fontFamily: 'Syne',
      useMaterial3: false,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFC8B8E8), // Lilac
        secondary: Color(0xFFBEB0D0), // Amethyst Smoke
        tertiary: Color(0xFFE8C898), // Light Caramel
        surface: Color(0xFF16161F),
        onPrimary: Color(0xFF3d2f6a),
        onSurface: Color(0xFFFFFFFF),
      ),
      cardColor: const Color(0xFF16161F),
      dividerColor: const Color(0x14FFFFFF),
      extensions: const [NeuropaColors.dark],
    );
  }

  // ─── LIGHT MODE ───────────────────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F2FA),
      fontFamily: 'Syne',
      useMaterial3: false,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFC8B8E8), // Lilac (same accent, different surfaces)
        secondary: Color(0xFFBEB0D0), // Amethyst Smoke
        tertiary: Color(0xFFE8C898), // Light Caramel
        surface: Color(0xFFFFFFFF),
        onPrimary: Color(0xFF3d2f6a),
        onSurface: Color(0xFF1A1030),
      ),
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0x18C8B8E8),
      extensions: const [NeuropaColors.light],
    );
  }
}

/// Semantic color extension for Neurova's intentional palette
class NeuropaColors extends ThemeExtension<NeuropaColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color lilacSurface;
  final Color amethystSurface;
  final Color blueSurface;
  final Color lemonSurface;
  final Color caramelSurface;

  const NeuropaColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.lilacSurface,
    required this.amethystSurface,
    required this.blueSurface,
    required this.lemonSurface,
    required this.caramelSurface,
  });

  // Dark mode colors
  static const dark = NeuropaColors(
    background: Color(0xFF0D0D14),
    surface: Color(0xFF16161F),
    surfaceElevated: Color(0xFF1E1E2C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8B0C8),
    textMuted: Color(0xFF6A6480),
    lilacSurface: Color(0xFFC8B8E8),
    amethystSurface: Color(0xFFBEB0D0),
    blueSurface: Color(0xFFB8D4E8),
    lemonSurface: Color(0xFFF5EFC0),
    caramelSurface: Color(0xFFE8C898),
  );

  // Light mode colors
  static const light = NeuropaColors(
    background: Color(0xFFF5F2FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0ECFA),
    textPrimary: Color(0xFF1A1030),
    textSecondary: Color(0xFF6A5888),
    textMuted: Color(0xFF9888B8),
    lilacSurface: Color(0xFFC8B8E8),
    amethystSurface: Color(0xFFBEB0D0),
    blueSurface: Color(0xFFB8D4E8),
    lemonSurface: Color(0xFFF5EFC0),
    caramelSurface: Color(0xFFE8C898),
  );

  @override
  ThemeExtension<NeuropaColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? lilacSurface,
    Color? amethystSurface,
    Color? blueSurface,
    Color? lemonSurface,
    Color? caramelSurface,
  }) {
    return NeuropaColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      lilacSurface: lilacSurface ?? this.lilacSurface,
      amethystSurface: amethystSurface ?? this.amethystSurface,
      blueSurface: blueSurface ?? this.blueSurface,
      lemonSurface: lemonSurface ?? this.lemonSurface,
      caramelSurface: caramelSurface ?? this.caramelSurface,
    );
  }

  @override
  ThemeExtension<NeuropaColors> lerp(ThemeExtension<NeuropaColors>? other, double t) {
    if (other is! NeuropaColors) return this;
    return NeuropaColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      lilacSurface: Color.lerp(lilacSurface, other.lilacSurface, t) ?? lilacSurface,
      amethystSurface: Color.lerp(amethystSurface, other.amethystSurface, t) ?? amethystSurface,
      blueSurface: Color.lerp(blueSurface, other.blueSurface, t) ?? blueSurface,
      lemonSurface: Color.lerp(lemonSurface, other.lemonSurface, t) ?? lemonSurface,
      caramelSurface: Color.lerp(caramelSurface, other.caramelSurface, t) ?? caramelSurface,
    );
  }
}