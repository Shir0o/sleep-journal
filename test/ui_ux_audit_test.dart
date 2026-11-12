// UI/UX audit across viewport and text-scale variants.
//
// Each variant pumps the app's main screen at a fixed logical size with a fixed
// text scale, then asserts:
//   * no RenderFlex overflow,
//   * every tap target meets the Android 48dp guideline,
//   * text contrast meets WCAG AA,
//   * a secondary navigation tab can be tapped without regressing the above.
//
// Goldens are written only under `flutter test --update-goldens`
// (autoUpdateGoldenFiles) so a macOS raster stays local and Linux CI does not
// fail on font rasterization differences.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleep_journal/main.dart';
import 'package:sleep_journal/theme.dart';

/// One device/theme combination exercised by the audit.
class _AuditVariant {
  const _AuditVariant({
    required this.name,
    required this.size,
    required this.textScale,
    required this.theme,
  });

  /// Golden file name and test label.
  final String name;

  /// Logical viewport size.
  final Size size;

  /// MediaQuery text scale factor.
  final double textScale;

  final ThemeData theme;
}

final List<_AuditVariant> _variants = <_AuditVariant>[
  _AuditVariant(
    name: 'phone_light',
    size: const Size(390, 844),
    textScale: 1.0,
    theme: AppTheme.lightTheme,
  ),
  _AuditVariant(
    name: 'phone_dark',
    size: const Size(390, 844),
    textScale: 1.0,
    theme: AppTheme.darkTheme,
  ),
  _AuditVariant(
    name: 'small_large_font',
    size: const Size(320, 568),
    textScale: 1.6,
    theme: AppTheme.lightTheme,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fonts must be re-registered per test: the binding resets the font
  // collection between tests.
  setUp(() async {
    // Never hit the network for Google Fonts from a widget test.
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadTestFonts();
  });

  for (final _AuditVariant variant in _variants) {
    testWidgets(
      '${variant.name}: main screen has no overflow, reachable targets, '
      'and readable text',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        try {
          final List<FlutterErrorDetails> errors = await _pumpMainScreen(
            tester,
            variant,
          );

          _expectOverflows(errors, variant.name);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          // Opt-in golden capture: local only, never required in CI.
          if (autoUpdateGoldenFiles) {
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${variant.name}.png'),
            );
          }
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      '${variant.name}: tapping a secondary navigation tab keeps the audit green',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        try {
          await _pumpMainScreen(tester, variant);

          // No dialog exists in this app today; the tap audit still has to hold.
          final List<FlutterErrorDetails> errors = await _collectLayoutErrors(
            () async {
              await tester.tap(find.text('History'));
              await tester.pumpAndSettle();
            },
          );

          final BottomNavigationBar navigation = tester.widget(
            find.byType(BottomNavigationBar),
          );
          expect(
            navigation.currentIndex,
            2,
            reason: 'Tapping "History" should select the History destination',
          );

          _expectOverflows(errors, variant.name);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          // Opt-in golden capture: local only, never required in CI.
          if (autoUpdateGoldenFiles) {
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${variant.name}_interactive.png'),
            );
          }
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}

/// Loads metrics-compatible stand-ins for the app's Google Fonts.
///
/// Without this, flutter_test paints every glyph as a full em square, which
/// inflates text width and produces overflows the real fonts never hit.
/// Google Fonts resolves each style to a variant-specific family name (for
/// example `Newsreader_regular`), so every name the theme references is bound.
Future<void> _loadTestFonts() async {
  final String? root = _flutterRoot();
  if (root == null) {
    return;
  }
  final Directory fonts = Directory('$root/bin/cache/artifacts/material_fonts');
  final File roboto = File('${fonts.path}/Roboto-Regular.ttf');
  if (!roboto.existsSync()) {
    return;
  }
  final ByteData textBytes = ByteData.sublistView(roboto.readAsBytesSync());
  for (final String family in _fontFamiliesUsedByTheme()) {
    final FontLoader loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(textBytes));
    await loader.load();
  }

  // Material icons, so goldens show real glyphs instead of placeholder boxes.
  final File icons = File('${fonts.path}/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final FontLoader loader = FontLoader('MaterialIcons')
      ..addFont(
        Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())),
      );
    await loader.load();
  }
}

/// Every font family name the app theme can resolve to, plus the default.
Set<String> _fontFamiliesUsedByTheme() {
  // Reuse the cached theme from the variant list so google_fonts resolves each
  // style once per run instead of once per test.
  final TextTheme textTheme = _variants.first.theme.textTheme;
  final List<TextStyle?> styles = <TextStyle?>[
    textTheme.displayLarge,
    textTheme.displayMedium,
    textTheme.displaySmall,
    textTheme.headlineLarge,
    textTheme.headlineMedium,
    textTheme.headlineSmall,
    textTheme.titleLarge,
    textTheme.titleMedium,
    textTheme.titleSmall,
    textTheme.bodyLarge,
    textTheme.bodyMedium,
    textTheme.bodySmall,
    textTheme.labelLarge,
    textTheme.labelMedium,
    textTheme.labelSmall,
    _variants.first.theme.bottomNavigationBarTheme.selectedLabelStyle,
    _variants.first.theme.bottomNavigationBarTheme.unselectedLabelStyle,
  ];

  final Set<String> families = <String>{'Roboto'};
  for (final TextStyle? style in styles) {
    if (style == null) {
      continue;
    }
    final String? family = style.fontFamily;
    if (family != null) {
      families.add(family);
    }
    families.addAll(style.fontFamilyFallback ?? const <String>[]);
  }
  return families;
}

/// Locates the Flutter SDK the test is running against, if it can be found.
String? _flutterRoot() {
  final String? fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }
  // Tests run in .../bin/cache/artifacts/engine/<host>/flutter_tester.
  Directory cursor = File(Platform.resolvedExecutable).parent;
  for (int depth = 0; depth < 8; depth++) {
    if (Directory(
      '${cursor.path}/bin/cache/artifacts/material_fonts',
    ).existsSync()) {
      return cursor.path;
    }
    cursor = cursor.parent;
  }
  return null;
}

/// Pumps [MainScreen] at the variant's viewport and text scale.
///
/// [MainScreen] is mounted inside a [MaterialApp] built here so the audit can
/// inject an explicit theme and text scale without changing production wiring.
Future<List<FlutterErrorDetails>> _pumpMainScreen(
  WidgetTester tester,
  _AuditVariant variant,
) async {
  tester.view.physicalSize = variant.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  return _collectLayoutErrors(() async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Sleeplab Journal',
        theme: variant.theme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(variant.textScale)),
            child: child!,
          );
        },
      ),
    );
    await tester.pumpAndSettle();
  });
}

/// Runs [body] while collecting every error the framework reports.
///
/// Layout overflows are reported through [FlutterError.onError]; swallowing the
/// default handler keeps the audit from failing with an unlabelled exception so
/// the assertions below can name the variant and the offending diagnostics.
Future<List<FlutterErrorDetails>> _collectLayoutErrors(
  Future<void> Function() body,
) async {
  final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
  final FlutterExceptionHandler? previousOnError = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await body();
  } finally {
    FlutterError.onError = previousOnError;
  }
  return errors;
}

/// Fails with the offending diagnostics when any layout error is an overflow.
void _expectOverflows(List<FlutterErrorDetails> errors, String variantName) {
  final List<FlutterErrorDetails> overflows = errors
      .where(
        (FlutterErrorDetails details) =>
            details.exceptionAsString().contains('overflowed'),
      )
      .toList();

  expect(
    overflows,
    isEmpty,
    reason:
        'Expected zero RenderFlex overflows on "$variantName" but found '
        '${overflows.length}:\n'
        '${overflows.map((FlutterErrorDetails d) => d.exceptionAsString()).join('\n\n')}',
  );
}
