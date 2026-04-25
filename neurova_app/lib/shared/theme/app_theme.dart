import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color background = Color(0xFF13111A);
  static const Color cardBackground = Color(0xFF1C1A26);
  static const Color cardBackgroundLight = Color(0xFF1B1827);

  // Brand colors
  static const Color purple = Color(0xFFB284BE);
  static const Color periwinkle = Color(0xFFA2ADD0);
  static const Color amber = Color(0xFFF8B878);
  static const Color cream = Color(0xFFF3C57D);
  static const Color lilac = Color(0xFFC8A2C8);

  // Semantic colors
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF5576C);
  static const Color warning = Color(0xFFF8B878);
  static const Color info = Color(0xFFA2ADD0);

  // Text colors
  static const Color white = Colors.white;
  static final Color textPrimary = Colors.white.withOpacity(0.9);
  static final Color textSecondary = Colors.white.withOpacity(0.65);
  static final Color textTertiary = Colors.white.withOpacity(0.45);
  static final Color textMuted = Colors.white.withOpacity(0.35);

  // Glassmorphism backgrounds
  static final Color glassBackground = Colors.white.withOpacity(0.04);
  static final Color glassBackgroundHover = Colors.white.withOpacity(0.08);
  static final Color glassBorder = Colors.white.withOpacity(0.1);
  static final Color glassBorderLight = Colors.white.withOpacity(0.08);

  // Icon backgrounds
  static final Color iconBackground = Colors.white.withOpacity(0.05);
  static final Color iconBackgroundActive = Colors.white.withOpacity(0.12);

  // Gradient colors
  static const List<Color> purpleGradient = [Color(0xFFB284BE), Color(0xFFA2ADD0)];
  static const List<Color> heroGradient = [Color(0xFF6B3FA0), Color(0xFFB284BE), Color(0xFFA2ADD0)];
  static const List<Color> amberGradient = [Color(0xFFF8B878), Color(0xFFF3C57D)];
}

class AppGradients {
  static const LinearGradient purple = LinearGradient(
    colors: AppColors.purpleGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hero = LinearGradient(
    colors: AppColors.heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amber = LinearGradient(
    colors: AppColors.amberGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glass([Color? tint]) => LinearGradient(
    colors: [
      (tint ?? AppColors.purple).withOpacity(0.22),
      (tint ?? AppColors.periwinkle).withOpacity(0.09),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmer(Color color) => LinearGradient(
    colors: [
      color.withOpacity(0.3),
      color.withOpacity(0.5),
      color.withOpacity(0.3),
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}

class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double xxlarge = 24.0;
  static const double xxxlarge = 32.0;

  static BorderRadius get smallCircular => BorderRadius.circular(small);
  static BorderRadius get mediumCircular => BorderRadius.circular(medium);
  static BorderRadius get largeCircular => BorderRadius.circular(large);
  static BorderRadius get xlargeCircular => BorderRadius.circular(xlarge);
  static BorderRadius get xxlargeCircular => BorderRadius.circular(xxlarge);
  static BorderRadius get xxxlargeCircular => BorderRadius.circular(xxxlarge);
}

class AppTypography {
  static const String fontFamily = 'Syne';

  static TextStyle get headline1 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static TextStyle get headline2 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get headline3 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get title1 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get title2 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get body1 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get body2 => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle get caption => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle get label => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: Colors.white,
  );

  static TextStyle get button => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

class AppShadows {
  static BoxShadow get card => BoxShadow(
    color: Colors.black.withOpacity(0.4),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  static BoxShadow glow(Color color) => BoxShadow(
    color: color.withOpacity(0.4),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow get buttonGlow => BoxShadow(
    color: AppColors.purple.withOpacity(0.5),
    blurRadius: 20,
    spreadRadius: 4,
  );

  static BoxShadow get drawerShadow => BoxShadow(
    color: Colors.black.withOpacity(0.65),
    blurRadius: 48,
    offset: const Offset(8, 0),
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration shimmer = Duration(milliseconds: 2000);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.periwinkle,
        surface: AppColors.cardBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0
  ,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.largeCircular,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: Colors.white.withOpacity(0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

// Glassmorphism card decoration helper
BoxDecoration glassCard({Color? tint, double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.large),
    border: Border.all(color: AppColors.glassBorder),
  );
}

// Active nav item decoration
BoxDecoration activeNavItem(Color color) {
  return BoxDecoration(
    color: color.withOpacity(0.16),
    borderRadius: AppBorderRadius.largeCircular,
    border: Border.all(color: color.withOpacity(0.28)),
  );
}

// Icon container decoration
BoxDecoration iconContainer({Color? color, bool active = false}) {
  return BoxDecoration(
    color: active
        ? (color ?? AppColors.purple).withOpacity(0.24)
        : AppColors.iconBackground,
    borderRadius: AppBorderRadius.mediumCircular,
  );
}
