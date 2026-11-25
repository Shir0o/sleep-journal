// UI/UX audit across viewport and text-scale variants.
//
// For each variant (and each of the app's primary destinations) the audit:
//   * pumps [MainScreen] at a fixed logical size and text scale,
//   * taps through every primary navigation destination and every visible
//     action, proving that none of them opens a dialog, bottom sheet or other
//     modal route today,
//   * asserts zero RenderFlex overflow,
//   * asserts every tap target meets the Android 48dp guideline,
//   * asserts rendered text contrast (host-dependent; see the note below).
//
// Token contrast is also verified deterministically in
// test/theme_contrast_test.dart, and that file remains the source of truth for
// colour regressions.
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
import 'package:sleep_journal/screens/dashboard_screen.dart';
import 'package:sleep_journal/screens/history_screen.dart';
import 'package:sleep_journal/screens/log_screen.dart';
import 'package:sleep_journal/screens/settings_screen.dart';
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

/// One primary destination of [MainScreen]'s bottom navigation bar.
class _Destination {
  const _Destination({
    required this.label,
    required this.slug,
    required this.index,
    required this.screen,
  });

  /// Label shown in the bottom navigation bar.
  final String label;

  /// Golden file suffix, for example `history`.
  final String slug;

  /// Position in the bottom navigation bar.
  final int index;

  /// Screen mounted for this destination inside the [IndexedStack].
  final Type screen;
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

/// Every destination in [MainScreen], in bottom-navigation order.
const List<_Destination> _destinations = <_Destination>[
  _Destination(
    label: 'Dashboard',
    slug: 'dashboard',
    index: 0,
    screen: DashboardScreen,
  ),
  _Destination(label: 'Log', slug: 'log', index: 1, screen: LogScreen),
  _Destination(
    label: 'History',
    slug: 'history',
    index: 2,
    screen: HistoryScreen,
  ),
  _Destination(
    label: 'Settings',
    slug: 'settings',
    index: 3,
    screen: SettingsScreen,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Themes below are built at first access, outside any test's zone; without
  // this, google_fonts tries to resolve an invoker and throws
  // "Bad state: There is no current invoker" while constructing AppTheme.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Fonts must be re-registered per test: the binding resets the font
  // collection between tests.
  setUp(() async {
    // Never hit the network for Google Fonts from a widget test.
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadTestFonts();
  });

  for (final _AuditVariant variant in _variants) {
    testWidgets('${variant.name}: dashboard passes the audit', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      try {
        final List<FlutterErrorDetails> errors = await _pumpMainScreen(
          tester,
          variant,
        );

        _expectOverflows(errors, variant, 'dashboard');
        await _expectGuidelines(tester, variant, 'dashboard');

        await _captureGolden(tester, '${variant.name}_dashboard');
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
      '${variant.name}: every primary tab passes the audit when tapped',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        try {
          final List<FlutterErrorDetails> initialErrors = await _pumpMainScreen(
            tester,
            variant,
          );
          _expectOverflows(initialErrors, variant, 'dashboard');

          // Tap every destination, then come back to Dashboard: forward
          // navigation must hold on every tab and the app must return home.
          final List<_Destination> taps = <_Destination>[
            ..._destinations.skip(1),
            _destinations.first,
          ];

          for (final _Destination destination in taps) {
            final List<FlutterErrorDetails> errors = await _collectLayoutErrors(
              () async {
                await tester.tap(_navTab(destination.label));
                await tester.pumpAndSettle();
              },
            );

            final BottomNavigationBar navigation = tester.widget(
              find.byType(BottomNavigationBar),
            );
            expect(
              navigation.currentIndex,
              destination.index,
              reason:
                  'Tapping "${destination.label}" should select the '
                  '"${destination.label}" destination.',
            );

            // The app has no dialogs, sheets or snack bars today; a tab tap
            // must not introduce one.
            _expectNoModalRoute(tester, destination.slug);

            _expectOverflows(errors, variant, destination.slug);
            await _expectGuidelines(tester, variant, destination.slug);

            // Dashboard was already captured by the test above.
            if (destination.slug != 'dashboard') {
              await _captureGolden(
                tester,
                '${variant.name}_${destination.slug}',
              );
            }
          }
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      '${variant.name}: every visible action opens no dialog or sheet',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        try {
          await _pumpMainScreen(tester, variant);

          // AppBar action (calendar).
          await _tapAndAudit(
            tester,
            variant,
            find.byTooltip('Calendar'),
            'app bar Calendar',
          );

          // Dashboard: "add correlation" action.
          await _tapAndAudit(
            tester,
            variant,
            find.byTooltip('Add correlation'),
            'dashboard Add correlation',
          );

          // Settings: connect rows and the plain Log Out button.
          await _tapAndAudit(
            tester,
            variant,
            _navTab('Settings'),
            'settings tab',
          );
          await _tapAndAudit(
            tester,
            variant,
            find.text('Log Out'),
            'settings Log Out',
          );

          // Log: an interactive habit row and the inline save action. The
          // save must confirm in place, with no dialog, sheet or snack bar.
          await _tapAndAudit(tester, variant, _navTab('Log'), 'log tab');
          await _tapAndAudit(
            tester,
            variant,
            find.descendant(
              of: find.byType(LogScreen),
              matching: find.text('Screen Time'),
            ),
            'log habit row',
          );
          await _tapAndAudit(
            tester,
            variant,
            find.text('Save Evening Log'),
            'log save',
          );
          expect(
            find.text('Saved for tonight'),
            findsOneWidget,
            reason: 'Saving on the Log tab should confirm inline.',
          );
          expect(
            find.text('Update Evening Log'),
            findsOneWidget,
            reason: 'The save action should switch to its update label.',
          );
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}

/// Matches the [Text] label of one bottom-navigation destination.
Finder _navTab(String label) {
  return find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  );
}

/// Fails with the offending diagnostics when any layout error is an overflow.
void _expectOverflows(
  List<FlutterErrorDetails> errors,
  _AuditVariant variant,
  String state,
) {
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
        'Expected zero RenderFlex overflows on "${variant.name}" / "$state" '
        '(${variant.size.width.toInt()}x${variant.size.height.toInt()} at '
        '${variant.textScale}x text) but found ${overflows.length}:\n'
        '${overflows.map((FlutterErrorDetails d) => d.exceptionAsString()).join('\n\n')}',
  );
}

/// Whether the rendered-contrast guideline can be trusted on this host.
///
/// [textContrastGuideline] samples antialiased glyph pixels. FreeType on Linux
/// antialiases 12sp text differently from CoreText on macOS, which makes the
/// histogram misread compliant colours as low contrast. Token-level contrast is
/// proven arithmetically in test/theme_contrast_test.dart on every host, so the
/// raster check is skipped on Linux to keep CI deterministic; it still runs on
/// macOS and Windows, where it catches real regressions (for example text
/// painted over a glow or a mismatched fill).
///
/// Set `SKIP_TEXT_CONTRAST=1` to disable it on any host.
bool get _runsRenderedContrastGuideline {
  if (Platform.environment['SKIP_TEXT_CONTRAST'] == '1') {
    return false;
  }
  return !Platform.isLinux;
}

/// Asserts the tap-target and (where supported) rendered-contrast guidelines.
Future<void> _expectGuidelines(
  WidgetTester tester,
  _AuditVariant variant,
  String state,
) async {
  await expectLater(
    tester,
    meetsGuideline(androidTapTargetGuideline),
    reason:
        'Expected every tap target on "${variant.name}" / "$state" to be at '
        'least 48x48dp.',
  );

  if (_runsRenderedContrastGuideline) {
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason:
          'Expected rendered text on "${variant.name}" / "$state" to meet '
          'WCAG AA.',
    );
  }
}

/// Taps [finder], then re-runs the audit for [state].
Future<void> _tapAndAudit(
  WidgetTester tester,
  _AuditVariant variant,
  Finder finder,
  String state,
) async {
  final List<FlutterErrorDetails> errors = await _collectLayoutErrors(() async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  });

  _expectNoModalRoute(tester, state);
  _expectOverflows(errors, variant, state);
  await _expectGuidelines(tester, variant, state);
}

/// Asserts that no dialog, sheet or snack bar is on screen.
///
/// Every action in this app is currently inert, so the audit pins that
/// behaviour: the day one of them opens a modal, this test points at the
/// offending interaction and the flow below has to be extended to cover it.
///
/// The `ModalBarrier` type is deliberately not asserted on: the page route
/// itself owns one. A pushed dialog or sheet is detected through
/// [NavigatorState.canPop] instead, since both push a route above `home`.
void _expectNoModalRoute(WidgetTester tester, String state) {
  expect(
    find.byType(Dialog),
    findsNothing,
    reason: 'Tapping "$state" unexpectedly opened a Dialog.',
  );
  expect(
    find.byType(AlertDialog),
    findsNothing,
    reason: 'Tapping "$state" unexpectedly opened an AlertDialog.',
  );
  expect(
    find.byType(BottomSheet),
    findsNothing,
    reason: 'Tapping "$state" unexpectedly opened a bottom sheet.',
  );
  expect(
    find.byType(SnackBar),
    findsNothing,
    reason: 'Tapping "$state" unexpectedly showed a snack bar.',
  );
  expect(
    tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
    isFalse,
    reason: 'Tapping "$state" unexpectedly pushed a modal route.',
  );
}

/// Writes a golden only when the run opted in with `--update-goldens`.
Future<void> _captureGolden(WidgetTester tester, String name) async {
  if (!autoUpdateGoldenFiles) {
    return;
  }
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
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
