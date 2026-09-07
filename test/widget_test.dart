import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:strawly/core/constants/app_constants.dart';
import 'package:strawly/core/l10n/locale_support.dart';
import 'package:strawly/core/theme/app_theme.dart';
import 'package:strawly/data/models/cycle_model.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/domain/entities/cycle_statistics.dart';
import 'package:strawly/l10n/app_localizations.dart';
import 'package:strawly/presentation/screens/add_cycle_screen.dart';
import 'package:strawly/presentation/screens/home_screen.dart';
import 'package:strawly/presentation/screens/statistics_screen.dart';
import 'package:strawly/presentation/shell/app_shell.dart';
import 'package:strawly/presentation/theme/bento_tokens.dart';
import 'package:strawly/presentation/viewmodels/cycle_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/locale_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/theme_viewmodel.dart';
import 'package:strawly/presentation/widgets/bento_grid.dart';
import 'package:strawly/presentation/widgets/bento_tile.dart';
import 'package:strawly/presentation/widgets/prediction_card_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class _TestCycleListNotifier extends CycleListNotifier {
  _TestCycleListNotifier(super.ref, {this.cycles = const []});

  final List<Cycle> cycles;

  @override
  Future<void> loadCycles() async {
    state = CycleListState(cycles: cycles);
  }
}

class _TestLocalePreferenceNotifier extends LocalePreferenceNotifier {
  _TestLocalePreferenceNotifier(Box settingsBox, LocalePreference initial)
      : super(settingsBox) {
    state = initial;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testHiveDir;
  late Box settingsBox;

  setUpAll(() async {
    testHiveDir = await Directory.systemTemp.createTemp('strawly_test_hive');
    Hive.init(testHiveDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CycleModelAdapter());
    }
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  });

  tearDownAll(() async {
    await Hive.close();
    if (testHiveDir.existsSync()) {
      await testHiveDir.delete(recursive: true);
    }
  });

  Widget buildTestApp(
    Widget child, {
    List<Cycle> cycles = const [],
    CycleStatistics statistics = const CycleStatistics(
      averageCycleLength: 0,
      standardDeviation: 0,
      totalCycles: 0,
      completeCycles: 0,
      isRegular: false,
    ),
    LocalePreference localePreference = LocalePreference.en,
    DateTime? predictedDate,
  }) {
    return ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeModeNotifier(settingsBox)),
        localePreferenceProvider.overrideWith(
          (ref) => _TestLocalePreferenceNotifier(settingsBox, localePreference),
        ),
        cycleListProvider.overrideWith(
          (ref) => _TestCycleListNotifier(ref, cycles: cycles),
        ),
        cycleStatisticsProvider.overrideWith((ref) => Future.value(statistics)),
        predictedNextCycleDateProvider.overrideWith(
          (ref) => Future.value(predictedDate),
        ),
      ],
      child: MaterialApp(
        locale: LocaleSupport.materialLocaleFor(localePreference),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleSupport.supportedLocales,
        localeListResolutionCallback: (locales, supportedLocales) {
          return LocaleSupport.resolveLocale(
            LocaleSupport.materialLocaleFor(localePreference),
            locales ?? const [Locale('en')],
          );
        },
        theme: AppTheme.getMaterialTheme(AppTheme.lightTheme()),
        home: child,
      ),
    );
  }

  Widget buildShadTestApp(
    Widget child, {
    List<Cycle> cycles = const [],
    DateTime? predictedDate,
  }) {
    return ShadApp.custom(
      theme: AppTheme.lightTheme(),
      appBuilder: (context) {
        return buildTestApp(
          child,
          cycles: cycles,
          predictedDate: predictedDate,
        );
      },
    );
  }

  testWidgets('AppShell shows home dashboard and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const AppShell()));
    await tester.pumpAndSettle();

    expect(find.text('Strawly'), findsOneWidget);
    expect(find.text('Your private cycle dashboard'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(FloatingActionButton)))
          .floatingActionButtonTheme
          .backgroundColor,
      BentoTokens.primaryButton,
    );
    expect(find.text('Log period today'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();

    expect(find.text('Statistics'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('AppShell shows Vietnamese copy when locale is vi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const AppShell(),
        localePreference: LocalePreference.vi,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đồng hành cùng em 💕'), findsOneWidget);

    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();

    expect(find.text('Chế độ tối'), findsOneWidget);
    expect(find.text('Ngôn ngữ'), findsAtLeastNWidgets(1));
  });

  testWidgets('BentoGrid lays out full-width prediction tile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Scaffold(
          body: BentoGrid(
            items: [
              BentoGridItem(
                columnSpan: 2,
                child: PredictionCardWidget(
                  predictedDate: DateTime(2026, 10, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Next expected period'), findsOneWidget);
    expect(find.text('Log period today'), findsOneWidget);
    expect(find.text('days'), findsOneWidget);
  });

  testWidgets('Statistics screen charts complete cycles without type error', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 7, 1);
    await tester.pumpWidget(
      buildTestApp(
        const StatisticsScreen(),
        cycles: [
          Cycle(
            id: '1',
            startDate: DateTime(2026, 7, 1),
            cycleLength: 28,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
        statistics: const CycleStatistics(
          averageCycleLength: 28,
          standardDeviation: 0,
          totalCycles: 1,
          completeCycles: 1,
          isRegular: true,
          regularityScore: 100,
          averagePeriodDuration: 5,
          shortestCycleLength: 28,
          longestCycleLength: 28,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Statistics'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Cycle length history'), findsOneWidget);
    expect(find.text('Last 1 cycles'), findsOneWidget);
    expect(find.text('Regularity score'), findsOneWidget);
    expect(find.text('Deviation from average'), findsOneWidget);
    expect(find.text('Avg period'), findsOneWidget);
    expect(find.text('Shortest / Longest'), findsOneWidget);
    expect(find.text('Enough data to predict: 1 cycles'), findsOneWidget);
  });

  testWidgets('Statistics screen shows chart empty state without complete cycles', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 7, 1);
    await tester.pumpWidget(
      buildTestApp(
        const StatisticsScreen(),
        cycles: [
          Cycle(
            id: '1',
            startDate: DateTime(2026, 7, 1),
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
        statistics: const CycleStatistics(
          averageCycleLength: 28,
          standardDeviation: 0,
          totalCycles: 1,
          completeCycles: 0,
          isRegular: false,
          regularityScore: 0,
          averagePeriodDuration: 5,
          currentCycleDay: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cycle length history'), findsOneWidget);
    expect(find.text('Regularity score'), findsOneWidget);
    expect(find.text('Not enough data to display chart.'), findsNWidgets(2));
    expect(find.text('Avg period'), findsOneWidget);
    expect(find.text('Current cycle day'), findsOneWidget);
    expect(find.text('Day 5'), findsOneWidget);
    expect(find.text('Enough data to predict: 0 cycles'), findsOneWidget);
  });

  testWidgets('recent cycle hover row includes tile padding', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 9, 6);
    await tester.pumpWidget(
      buildTestApp(
        const HomeScreen(),
        cycles: [
          Cycle(
            id: 'ongoing',
            startDate: created,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final rowLabel = find.text('Ongoing');
    expect(rowLabel, findsOneWidget);

    final tile = tester.widget<BentoTile>(
      find.ancestor(of: rowLabel, matching: find.byType(BentoTile)).first,
    );
    expect(tile.padding, EdgeInsets.zero);

    final inkWell = find.ancestor(
      of: rowLabel,
      matching: find.byType(InkWell),
    );
    final padding = tester.widget<Padding>(
      find.descendant(of: inkWell, matching: find.byType(Padding)).first,
    );
    final insets = padding.padding.resolve(TextDirection.ltr);
    expect(insets.left, BentoTokens.tilePadding);
    expect(insets.right, BentoTokens.tilePadding);
    expect(insets.top, greaterThanOrEqualTo(BentoTokens.space8));
    expect(insets.bottom, greaterThanOrEqualTo(BentoTokens.space8));
  });

  testWidgets('cycle length and notes fields have fill and outline', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 9, 6);
    await tester.pumpWidget(
      buildShadTestApp(
        AddCycleScreen(
          cycleToEdit: Cycle(
            id: 'edit',
            startDate: created,
            cycleLength: 28,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    TextField fieldWithHint(String hint) {
      return tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) => widget is TextField && widget.decoration?.hintText == hint,
        ),
      );
    }

    final cycleLengthField = fieldWithHint('e.g., 28');
    final notesField = fieldWithHint(
      'Add notes about symptoms, mood, etc.',
    );

    for (final field in [cycleLengthField, notesField]) {
      final decoration = field.decoration!;
      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, isNotNull);
      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      expect(decoration.focusedBorder, isA<OutlineInputBorder>());
    }
  });

  testWidgets('submit button uses a stronger primary fill', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 9, 6);
    await tester.pumpWidget(
      buildShadTestApp(
        AddCycleScreen(
          cycleToEdit: Cycle(
            id: 'edit',
            startDate: created,
            cycleLength: 28,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ShadButton>(
      find.widgetWithText(ShadButton, 'Update cycle'),
    );
    expect(button.backgroundColor, BentoTokens.primaryButton);
    expect(button.foregroundColor, Colors.white);
  });

  testWidgets('recent cycles list is capped at 5 rows', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 1, 1);
    final cycles = List<Cycle>.generate(6, (index) {
      return Cycle(
        id: 'cycle-$index',
        startDate: DateTime(2026, 1, 1 + index * 28),
        cycleLength: 28,
        periodDuration: 5,
        createdAt: created,
        updatedAt: created,
      );
    });

    await tester.pumpWidget(buildTestApp(const HomeScreen(), cycles: cycles));
    await tester.pumpAndSettle();

    expect(find.byType(Dismissible), findsNWidgets(5));
  });

  testWidgets('swiping a recent cycle left asks for delete confirmation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final created = DateTime(2026, 9, 6);
    await tester.pumpWidget(
      buildShadTestApp(
        const HomeScreen(),
        cycles: [
          Cycle(
            id: 'ongoing',
            startDate: created,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final ongoing = find.text('Ongoing');
    await tester.drag(ongoing, const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete this cycle?'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Delete this cycle?'), findsNothing);
  });

  testWidgets('tapping the countdown ring opens edit cycle', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 8, 26);
    await tester.pumpWidget(
      buildShadTestApp(
        const HomeScreen(),
        predictedDate: DateTime(2026, 10, 1),
        cycles: [
          Cycle(
            id: 'ongoing',
            startDate: created,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('prediction-countdown-ring')));
    await tester.pumpAndSettle();

    expect(find.text('Edit cycle'), findsOneWidget);
  });

  testWidgets('tapping a period day on the calendar opens edit cycle', (
    WidgetTester tester,
  ) async {
    final created = DateTime(2026, 9, 6);
    await tester.pumpWidget(
      buildShadTestApp(
        const HomeScreen(),
        cycles: [
          Cycle(
            id: 'ongoing',
            startDate: created,
            periodDuration: 5,
            createdAt: created,
            updatedAt: created,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(GridView), matching: find.text('6')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit cycle'), findsOneWidget);
  });
}
