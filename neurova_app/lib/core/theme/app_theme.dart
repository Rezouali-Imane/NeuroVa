import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Neurova color palette
  static const Color lilac = Color(0xFFC8A2C8);         // Lilac
  static const Color amethystSmoke = Color(0xFFB284BE); // Amethyst Smoke
  static const Color powderBlue = Color(0xFFA2ADD0);    // Powder Blue
  static const Color lemonChiffon = Color(0xFFECEBBD);  // Lemon Chiffon
  static const Color lightCaramel = Color(0xFFF8B878);  // Light Caramel

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Syne',
      colorScheme: const ColorScheme.light(
        primary: lilac,
        secondary: amethystSmoke,
        surface: powderBlue,
        error: Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: powderBlue,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w800,
          fontSize: 48,
          color: Color(0xFF243B53),
        ),
        displayMedium: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w700,
          fontSize: 36,
          color: Color(0xFF243B53),
        ),
        displaySmall: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
          fontSize: 28,
          color: Color(0xFF243B53),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Color(0xFF243B53),
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Color(0xFF243B53),
        ),
        titleLarge: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Color(0xFF243B53),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF243B53),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF243B53),
        ),
        labelLarge: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF243B53),
        ),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: powderBlue,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightCaramel,
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