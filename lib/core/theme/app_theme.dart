/// Premium theme system supporting both Dark and Light modes with glassmorphism accents,
/// custom theme accent palettes, and customizable session colors.
library;

import 'package:flutter/material.dart';

class ThemePalette {
  final String id;
  final String nameAr;
  final String nameEn;
  final Color primary;
  final Color accent;

  const ThemePalette({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.primary,
    required this.accent,
  });
}

class AppPalettes {
  AppPalettes._();

  static const List<ThemePalette> list = [
    ThemePalette(
      id: 'violet',
      nameAr: 'البنفسجي الملكي',
      nameEn: 'Royal Violet',
      primary: Color(0xFF6C63FF),
      accent: Color(0xFF00D9FF),
    ),
    ThemePalette(
      id: 'blue',
      nameAr: 'الأزرق الكلاسيكي',
      nameEn: 'Classic Blue',
      primary: Color(0xFF2563EB),
      accent: Color(0xFF38BDF8),
    ),
    ThemePalette(
      id: 'emerald',
      nameAr: 'الأخضر الزمردي',
      nameEn: 'Emerald Green',
      primary: Color(0xFF059669),
      accent: Color(0xFF34D399),
    ),
    ThemePalette(
      id: 'rose',
      nameAr: 'الوردي الأنيق',
      nameEn: 'Rose Pink',
      primary: Color(0xFFE11D48),
      accent: Color(0xFFFB7185),
    ),
    ThemePalette(
      id: 'amber',
      nameAr: 'البرتقالي الشمسي',
      nameEn: 'Sunset Amber',
      primary: Color(0xFFEA580C),
      accent: Color(0xFFFBBF24),
    ),
    ThemePalette(
      id: 'cyan',
      nameAr: 'السماوي المحيطي',
      nameEn: 'Ocean Cyan',
      primary: Color(0xFF0284C7),
      accent: Color(0xFF00E5A0),
    ),
  ];

  static const List<Color> sessionOptions = [
    Color(0xFF6C63FF), // Violet
    Color(0xFF2563EB), // Blue
    Color(0xFF0284C7), // Sky Cyan
    Color(0xFF059669), // Emerald
    Color(0xFF10B981), // Mint
    Color(0xFF0D9488), // Teal
    Color(0xFFEA580C), // Orange
    Color(0xFFD97706), // Amber
    Color(0xFFE11D48), // Rose
    Color(0xFFDC2626), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF00CEC9), // Neo Teal
  ];
}

class AppTheme {
  AppTheme._();

  // ── Primary Palette (HSL-curated deep blue → teal gradient) ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42DB);
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentAlt = Color(0xFF00E5A0);

  // ── Surface / Background (Dark Mode - Eye-Comfort Slate Palette) ──
  static const Color bgDark = Color(0xFF0F172A); // Smooth Slate 900
  static const Color bgCard = Color(0xFF1E293B); // Slate 800
  static const Color bgCardLight = Color(0xFF334155); // Slate 700
  static const Color bgSurface = Color(0xFF141E33); // Comfort Midnight Slate

  // ── Surface / Background (Light Mode) ──
  static const Color bgLight = Color(0xFFF6F8FC);
  static const Color bgCardLightSurface = Color(0xFFFFFFFF);
  static const Color bgCardElevatedLight = Color(0xFFEEF2F7);
  static const Color bgSurfaceLight = Color(0xFFFFFFFF);

  // ── Text (Dark Mode) ──
  static const Color textPrimary = Color(0xFFF8FAFC); // High legibility soft white
  static const Color textSecondary = Color(0xFF94A3B8); // Soft eye-friendly slate
  static const Color textHint = Color(0xFF64748B);

  // ── Text (Light Mode) ──
  static const Color textPrimaryLight = Color(0xFF191D31);
  static const Color textSecondaryLight = Color(0xFF5A627A);
  static const Color textHintLight = Color(0xFF94A3B8);

  // ── Semantic ──
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF00D9FF);

  // ── Session Type Colors (Dark Mode) ──
  static const Color lectureColor = Color(0xFF6C63FF);
  static const Color labColor = Color(0xFF00D9FF);
  static const Color sectionColor = Color(0xFF00E5A0);
  static const Color projectColor = Color(0xFFFF6B6B);
  static const Color restColor = Color(0xFF00CEC9);

  // ── Session Type Colors (Light Mode - Rich & High Contrast) ──
  static const Color lectureColorLight = Color(0xFF564AE3);
  static const Color labColorLight = Color(0xFF0284C7);
  static const Color sectionColorLight = Color(0xFF059669);
  static const Color projectColorLight = Color(0xFFDC2626);
  static const Color restColorLight = Color(0xFF0D9488);

  // ── Context-aware Helpers ──
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getScaffoldBg(BuildContext context) =>
      isDark(context) ? bgDark : bgLight;

  static Color getCardBg(BuildContext context) =>
      isDark(context) ? bgCard : bgCardLightSurface;

  static Color getCardSub(BuildContext context) =>
      isDark(context) ? bgCardLight : bgCardElevatedLight;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? bgSurface : bgSurfaceLight;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? textPrimary : textPrimaryLight;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? textSecondary : textSecondaryLight;

  static Color getTextHint(BuildContext context) =>
      isDark(context) ? textHint : textHintLight;

  static Color getBorder(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE2E8F0);

  static Color getSessionColor(String type, BuildContext context, [Map<String, int>? customColors]) =>
      sessionColor(type, isDark(context), customColors);

  static Color getRestColor([bool isDark = true, Color? customColor]) {
    if (customColor != null) return customColor;
    return isDark ? restColor : restColorLight;
  }

  /// Returns the session-type color for schedule cards with dark/light & custom colors awareness.
  static Color sessionColor(String type, [bool isDarkMode = true, Map<String, int>? customColors]) {
    if (customColors != null && customColors[type] != null) {
      return Color(customColors[type]!);
    }

    if (isDarkMode) {
      switch (type) {
        case 'lecture':
          return lectureColor;
        case 'lab':
          return labColor;
        case 'section':
          return sectionColor;
        case 'rest':
        case 'project':
          return restColor;
        default:
          return primary;
      }
    } else {
      switch (type) {
        case 'lecture':
          return lectureColorLight;
        case 'lab':
          return labColorLight;
        case 'section':
          return sectionColorLight;
        case 'rest':
        case 'project':
          return restColorLight;
        default:
          return primary;
      }
    }
  }

  // ── Glassmorphism ──
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: bgCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration glass(BuildContext context) {
    final dark = isDark(context);
    return BoxDecoration(
      color: dark ? bgCard.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: dark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE2E8F0),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: dark
              ? Colors.black.withValues(alpha: 0.3)
              : const Color(0xFF64748B).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration glassDecorationWithColor(Color color, [BuildContext? context]) {
    final dark = context == null ? true : isDark(context);
    return BoxDecoration(
      color: dark ? null : Colors.white,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: dark ? 0.15 : 0.09),
          dark ? color.withValues(alpha: 0.05) : Colors.white,
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withValues(alpha: dark ? 0.2 : 0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: dark
              ? color.withValues(alpha: 0.1)
              : const Color(0xFF64748B).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ── Dark ThemeData ──
  static ThemeData get darkTheme => getDarkTheme();

  static ThemeData getDarkTheme([Color primaryColor = primary]) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accent,
        surface: bgSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: textHint, fontFamily: 'Cairo'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCardLight,
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textSecondary),
        bodyLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textHint),
        labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textSecondary),
        labelSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textHint),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Light ThemeData ──
  static ThemeData get lightTheme => getLightTheme();

  static ThemeData getLightTheme([Color primaryColor = primary]) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFF0284C7),
        surface: bgCardLightSurface,
        error: const Color(0xFFDC2626),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryLight,
        ),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: bgCardLightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardElevatedLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: textHintLight, fontFamily: 'Cairo'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgSurfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHintLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCardLightSurface,
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: textPrimaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimaryLight),
        displayMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimaryLight),
        displaySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimaryLight),
        headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textPrimaryLight),
        titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textSecondaryLight),
        bodyLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textPrimaryLight),
        bodyMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textSecondaryLight),
        bodySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textHintLight),
        labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimaryLight),
        labelMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: textSecondaryLight),
        labelSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textHintLight),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
