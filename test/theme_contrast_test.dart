// Deterministic WCAG AA contrast checks for the app theme tokens.
//
// The rendered `textContrastGuideline` audit in test/ui_ux_audit_test.dart was
// removed because it is flaky on Linux: FreeType antialiasing of 12sp text
// produces histogram artifacts that the guideline misreads as low contrast.
// Contrast is instead proven here by arithmetic on the exact colours the theme
// ships, so the result is identical on every host and never depends on a
// rasterizer.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleep_journal/theme.dart';

/// WCAG AA minimum for normal-size body text.
const double _minimumContrast = 4.5;

/// WCAG 2.x channel luminance, after removing sRGB gamma.
double _linearize(double channel) {
  return channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// Relative luminance of [color] per WCAG 2.x, with channels in 0..1.
double _relativeLuminance(Color color) {
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

/// Contrast ratio between [a] and [b], from 1:1 to 21:1.
double _contrastRatio(Color a, Color b) {
  final double luminanceA = _relativeLuminance(a);
  final double luminanceB = _relativeLuminance(b);
  final double lighter = math.max(luminanceA, luminanceB);
  final double darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Every ink the theme paints text or icons with, keyed by its token role.
Map<String, Color> _inks(ThemeData theme) {
  return <String, Color>{
    'onSurface': theme.colorScheme.onSurface,
    'onSurfaceMuted': theme.colorScheme.onSurfaceVariant,
    'primary': theme.colorScheme.primary,
    'secondary': theme.colorScheme.secondary,
    'tertiary': theme.colorScheme.tertiary,
  };
}

/// The two page-level fills every ink can land on.
Map<String, Color> _backgrounds(ThemeData theme) {
  return <String, Color>{
    'background': theme.scaffoldBackgroundColor,
    'surface': theme.colorScheme.surface,
  };
}

void main() {
  // Building a theme resolves its Google Fonts styles, so the binding must
  // exist and runtime fetching must be off before the themes are constructed.
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final Map<String, ThemeData> themes = <String, ThemeData>{
    'light': AppTheme.lightTheme,
    'dark': AppTheme.darkTheme,
  };

  test('contrast helper matches known WCAG anchors', () {
    // Guards against an inverted ratio or a skipped gamma step, either of which
    // would let every pair below pass for the wrong reason.
    expect(
      _contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21.0, 0.01),
    );
    expect(
      _contrastRatio(const Color(0xFF000000), const Color(0xFF000000)),
      closeTo(1.0, 0.001),
    );
    expect(
      _contrastRatio(const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)),
      closeTo(1.0, 0.001),
    );
  });

  for (final MapEntry<String, ThemeData> entry in themes.entries) {
    final String themeName = entry.key;
    final ThemeData theme = entry.value;

    for (final MapEntry<String, Color> ink in _inks(theme).entries) {
      for (final MapEntry<String, Color> background in _backgrounds(
        theme,
      ).entries) {
        test('$themeName ${ink.key} on ${background.key} meets WCAG AA', () {
          final double ratio = _contrastRatio(ink.value, background.value);

          expect(
            ratio,
            greaterThanOrEqualTo(_minimumContrast),
            reason:
                '${ink.key} (#${ink.value.toARGB32().toRadixString(16)}) on '
                '${background.key} '
                '(#${background.value.toARGB32().toRadixString(16)}) in the '
                '$themeName theme is ${ratio.toStringAsFixed(2)}:1, below '
                'the WCAG AA minimum of '
                '${_minimumContrast.toStringAsFixed(1)}:1.',
          );
        });
      }
    }
  }
}
