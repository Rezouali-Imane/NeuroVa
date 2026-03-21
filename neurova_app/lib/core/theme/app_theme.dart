import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _brandPrimary = Color(0xFF0A4D68);
  static const Color _brandAccent = Color(0xFF05BFDB);
  static const Color _surface = Color(0xFFF6FBFD);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Text',
      colorScheme: const ColorScheme.light(
        primary: _brandPrimary,
        secondary: _brandAccent,
        surface: _surface,
      ),
      scaffoldBackgroundColor: _surface,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _surface,
        foregroundColor: Colors.black,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'SF Pro Text',
        displayColor: const Color(0xFF102A43),
        bodyColor: const Color(0xFF243B53),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
