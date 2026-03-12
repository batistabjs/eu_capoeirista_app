import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette — dark editorial style
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color accent = Color(0xFF2EA043);
  static const Color accentBlue = Color(0xFF388BFD);
  static const Color accentOrange = Color(0xFFDB6D28);
  static const Color accentPurple = Color(0xFF8957E5);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);
  static const Color danger = Color(0xFFF85149);
  static const Color warning = Color(0xFFD29922);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accent,
        surface: surface,
        error: danger,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontFamily: 'Georgia'),
        displayMedium: TextStyle(color: textPrimary, fontFamily: 'Georgia'),
        displaySmall: TextStyle(color: textPrimary, fontFamily: 'Georgia'),
        headlineLarge: TextStyle(color: textPrimary, fontFamily: 'Georgia', fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimary, fontFamily: 'Georgia', fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontFamily: 'Georgia', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(color: textPrimary, fontFamily: 'Georgia', fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontFamily: 'Georgia', fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textSecondary, fontFamily: 'Georgia'),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textMuted, fontSize: 11),
      ),
    );
  }
}
