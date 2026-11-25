// Widget tests for the evening habit log.
//
// The screen is the only interactive destination in the app, so these tests
// pin the full behaviour: editorial chrome, per-factor toggling, the inline save
// confirmation (no modal routes), confirmation reset on edit, both themes, and
// the 320dp / 1.6x text-scale budget that the UI/UX audit also exercises.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleep_journal/screens/log_screen.dart';
import 'package:sleep_journal/theme.dart';

/// One habit row and the values it cycles through.
class _Habit {
  const _Habit(this.label, this.values);

  final String label;
  final List<String> values;
}

const List<_Habit> _habits = <_Habit>[
  _Habit('Screen Time', <String>['< 1 h', '1-2 h', '2+ h']),
  _Habit('Magnesium', <String>['Taken', 'Skipped']),
  _Habit('Late Caffeine', <String>['None', 'After 2 PM']),
  _Habit('Dinner Timing', <String>['3+ h before bed', '< 3 h before bed']),
];

/// WCAG 2.x relative luminance for an sRGB [color].
double _relativeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

double _contrastRatio(Color a, Color b) {
  final double luminanceA = _relativeLuminance(a);
  final double luminanceB = _relativeLuminance(b);
  final double lighter = math.max(luminanceA, luminanceB);
  final double darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final Map<String, ThemeData> themes = <String, ThemeData>{
    'light': AppTheme.lightTheme,
    'dark': AppTheme.darkTheme,
  };

  setUp(() async {
    // Never hit the network for Google Fonts from a widget test, and register
    // metrics-compatible stand-ins so wrapping matches the real typefaces.
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadTestFonts(themes['light']!);
  });

  Future<List<FlutterErrorDetails>> pumpLog(
    WidgetTester tester, {
    required ThemeData theme,
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
    final FlutterExceptionHandler? previousOnError = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: const LogScreen()),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            );
          },
        ),
      );
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = previousOnError;
    }
    return errors;
  }

  for (final MapEntry<String, ThemeData> entry in themes.entries) {
    final String themeName = entry.key;
    final ThemeData theme = entry.value;

    testWidgets('$themeName: renders the editorial log chrome and defaults', (
      WidgetTester tester,
    ) async {
      await pumpLog(tester, theme: theme);

      expect(find.text('LOG'), findsOneWidget);
      expect(
        find.text(
          "Log tonight's evening habits to refine your sleep correlations.",
        ),
        findsOneWidget,
      );
      expect(find.text('EVENING HABITS'), findsOneWidget);

      for (final _Habit habit in _habits) {
        expect(
          find.text(habit.label),
          findsOneWidget,
          reason: 'Missing "${habit.label}" row.',
        );
        expect(
          find.text(habit.values.first),
          findsOneWidget,
          reason: '"${habit.label}" should start at "${habit.values.first}".',
        );
      }

      expect(find.text('Save Evening Log'), findsOneWidget);
      expect(find.text('Saved for tonight'), findsNothing);
      expect(find.text('Update Evening Log'), findsNothing);
    });

    testWidgets('$themeName: cycles every habit through its values', (
      WidgetTester tester,
    ) async {
      await pumpLog(tester, theme: theme);

      for (final _Habit habit in _habits) {
        for (final String value in habit.values.skip(1)) {
          await tester.tap(find.text(habit.label));
          await tester.pumpAndSettle();

          expect(
            find.text(value),
            findsOneWidget,
            reason: 'Tapping "${habit.label}" should reveal "$value".',
          );
        }

        // Cycling wraps back to the starting value.
        await tester.tap(find.text(habit.label));
        await tester.pumpAndSettle();
        expect(
          find.text(habit.values.first),
          findsOneWidget,
          reason:
              '"${habit.label}" should wrap back to "${habit.values.first}".',
        );
      }
    });

    testWidgets('$themeName: save shows inline confirmation, no modal', (
      WidgetTester tester,
    ) async {
      await pumpLog(tester, theme: theme);

      await tester.ensureVisible(find.text('Save Evening Log'));
      await tester.tap(find.text('Save Evening Log'));
      await tester.pumpAndSettle();

      expect(find.text('Saved for tonight'), findsOneWidget);
      expect(find.text('Update Evening Log'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
        reason: 'Saving must stay on the Log tab without pushing a route.',
      );
    });

    testWidgets('$themeName: editing after save resets the confirmation', (
      WidgetTester tester,
    ) async {
      await pumpLog(tester, theme: theme);

      await tester.ensureVisible(find.text('Save Evening Log'));
      await tester.tap(find.text('Save Evening Log'));
      await tester.pumpAndSettle();
      expect(find.text('Saved for tonight'), findsOneWidget);

      await tester.tap(find.text('Magnesium'));
      await tester.pumpAndSettle();

      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Saved for tonight'), findsNothing);
      expect(find.text('Update Evening Log'), findsNothing);
      expect(find.text('Save Evening Log'), findsOneWidget);
    });

    testWidgets('$themeName: primary action meets WCAG AA', (
      WidgetTester tester,
    ) async {
      await pumpLog(tester, theme: theme);

      final ColorScheme colors = theme.colorScheme;
      final double ratio = _contrastRatio(colors.onPrimary, colors.primary);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason:
            'onPrimary on primary in the $themeName theme is '
            '${ratio.toStringAsFixed(2)}:1.',
      );

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Evening Log'),
      );
      expect(button.style?.elevation?.resolve(<WidgetState>{}), 0);
    });
  }

  testWidgets('fits 320dp at 1.6x text with 48dp targets and no overflow', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      final List<FlutterErrorDetails> errors = await pumpLog(
        tester,
        theme: AppTheme.lightTheme,
        size: const Size(320, 568),
        textScale: 1.6,
      );

      expect(
        errors.where(
          (FlutterErrorDetails details) =>
              details.exceptionAsString().contains('overflowed'),
        ),
        isEmpty,
        reason: 'LogScreen must not overflow at 320dp and 1.6x text.',
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      // The action stays reachable and usable at the smallest layout.
      await tester.ensureVisible(find.text('Save Evening Log'));
      await tester.tap(find.text('Save Evening Log'));
      await tester.pumpAndSettle();
      expect(find.text('Saved for tonight'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('no surface in the log uses a shadow', (
    WidgetTester tester,
  ) async {
    await pumpLog(tester, theme: AppTheme.darkTheme);

    final Iterable<Container> containers = tester.widgetList<Container>(
      find.byType(Container),
    );
    for (final Container container in containers) {
      final Decoration? decoration = container.decoration;
      if (decoration is BoxDecoration) {
        expect(
          decoration.boxShadow,
          anyOf(isNull, isEmpty),
          reason: 'PROJECT.md forbids shadows on surfaces.',
        );
      }
    }

    final Iterable<Material> materials = tester.widgetList<Material>(
      find.byType(Material),
    );
    for (final Material material in materials) {
      expect(
        material.elevation,
        0,
        reason: 'PROJECT.md forbids elevation on surfaces.',
      );
    }
  });
}

/// Loads metrics-compatible stand-ins for the app's Google Fonts.
Future<void> _loadTestFonts(ThemeData theme) async {
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
  for (final String family in _fontFamilies(theme)) {
    final FontLoader loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(textBytes));
    await loader.load();
  }

  final File icons = File('${fonts.path}/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final FontLoader loader = FontLoader('MaterialIcons')
      ..addFont(
        Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())),
      );
    await loader.load();
  }
}

/// Every font family name [theme] can resolve to, plus the default.
Set<String> _fontFamilies(ThemeData theme) {
  final TextTheme textTheme = theme.textTheme;
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
    theme.bottomNavigationBarTheme.selectedLabelStyle,
    theme.bottomNavigationBarTheme.unselectedLabelStyle,
  ];

  final Set<String> families = <String>{'Roboto'};
  for (final TextStyle? style in styles) {
    final String? family = style?.fontFamily;
    if (family != null) {
      families.add(family);
    }
    families.addAll(style?.fontFamilyFallback ?? const <String>[]);
  }
  return families;
}

/// Locates the Flutter SDK the test is running against, if it can be found.
String? _flutterRoot() {
  final String? fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }
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
