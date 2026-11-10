import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark palette.
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E26);
  static const Color primary = Color(0xFF9FA8DA);
  static const Color secondary = Color(0xFFFFD54F);
  static const Color tertiary = Color(0xFF81D4FA);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceMuted = Color(0xFFC6C5D0);

  // Light palette. Every ink clears WCAG AA (4.5:1) on background and surface.
  static const Color lightBackground = Color(0xFFFAF8FC);
  static const Color lightSurface = Color(0xFFF1EFF6);
  static const Color lightPrimary = Color(0xFF3F51B5);
  static const Color lightSecondary = Color(0xFF8A5A00);
  static const Color lightTertiary = Color(0xFF00658A);
  static const Color lightOnSurface = Color(0xFF1A1B20);
  static const Color lightOnSurfaceMuted = Color(0xFF4C4C58);

  static TextTheme _textTheme({
    required Color onSurface,
    required Color onSurfaceMuted,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.ebGaramond(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 48,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.ebGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15 * 12,
        color: onSurfaceMuted,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      dividerColor: Colors.white.withValues(alpha: 0.05),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceMuted,
      ),
      textTheme: _textTheme(
        onSurface: onSurface,
        onSurfaceMuted: onSurfaceMuted,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      dividerColor: lightOnSurface.withValues(alpha: 0.08),
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightTertiary,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceMuted,
      ),
      textTheme: _textTheme(
        onSurface: lightOnSurface,
        onSurfaceMuted: lightOnSurfaceMuted,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightBackground,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightOnSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
