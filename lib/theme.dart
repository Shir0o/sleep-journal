import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E26);
  static const Color primary = Color(0xFF9FA8DA);
  static const Color secondary = Color(0xFFFFD54F);
  static const Color tertiary = Color(0xFF81D4FA);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceMuted = Color(0xFFC6C5D0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        onSurface: onSurface,
      ),
      textTheme: TextTheme(
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
}
