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
import 'package:strawly/presentation/screens/statistics_screen.dart';
import 'package:strawly/presentation/shell/app_shell.dart';
import 'package:strawly/presentation/viewmodels/cycle_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/locale_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/theme_viewmodel.dart';
import 'package:strawly/presentation/widgets/bento_grid.dart';
import 'package:strawly/presentation/widgets/prediction_card_widget.dart';

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
        predictedNextCycleDateProvider.overrideWith((ref) => Future.value(null)),
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

  testWidgets('AppShell shows home dashboard and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const AppShell()));
    await tester.pumpAndSettle();

    expect(find.text('Strawly'), findsOneWidget);
    expect(find.text('Your private cycle dashboard'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
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
}
