import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:strawly/core/l10n/locale_support.dart';
import 'package:strawly/core/theme/app_theme.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/l10n/app_localizations.dart';
import 'package:strawly/presentation/viewmodels/cycle_viewmodel.dart';
import 'package:strawly/presentation/widgets/app_toast.dart';
import 'package:strawly/presentation/widgets/cycle_actions.dart';

class _RecordingCycleListNotifier extends CycleListNotifier {
  _RecordingCycleListNotifier(super.ref, {this.initial = const []});

  final List<Cycle> initial;
  int deleteCalls = 0;
  int addCalls = 0;
  Cycle? lastAdded;

  @override
  Future<void> loadCycles() async {
    state = CycleListState(cycles: initial);
  }

  @override
  Future<void> deleteCycle(String id) async {
    deleteCalls++;
    state = CycleListState(
      cycles: initial.where((c) => c.id != id).toList(),
    );
  }

  @override
  Future<void> addCycle(Cycle cycle) async {
    addCalls++;
    lastAdded = cycle;
    state = CycleListState(cycles: [...state.cycles, cycle]);
  }
}

Widget _toastTestApp({
  required Widget home,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: ShadApp.custom(
      theme: AppTheme.lightTheme(),
      appBuilder: (context) {
        return MaterialApp(
          locale: LocaleSupport.materialLocaleFor(LocalePreference.en),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleSupport.supportedLocales,
          theme: AppTheme.getMaterialTheme(AppTheme.lightTheme()),
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: home,
        );
      },
    ),
  );
}

void main() {
  testWidgets('AppToast.success shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      _toastTestApp(
        home: Builder(
          builder: (context) {
            return ShadButton(
              onPressed: () => AppToast.success(context, title: 'Saved OK'),
              child: const Text('Show success'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Saved OK'), findsOneWidget);
  });

  testWidgets('AppToast.error shows destructive toast', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _toastTestApp(
        home: Builder(
          builder: (context) {
            return ShadButton(
              onPressed: () => AppToast.error(context, title: 'Failed badly'),
              child: const Text('Show error'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Failed badly'), findsOneWidget);
    expect(find.byType(ShadToast), findsOneWidget);
  });

  testWidgets('toast close button dismisses message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _toastTestApp(
        home: Builder(
          builder: (context) {
            return ShadButton(
              onPressed: () => AppToast.success(context, title: 'Dismiss me'),
              child: const Text('Show toast'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Dismiss me'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Dismiss me'), findsNothing);
  });

  testWidgets('deleteCycle undo restores cycle via toast action', (
    WidgetTester tester,
  ) async {
    final cycle = Cycle(
      id: 'c1',
      startDate: DateTime(2026, 3, 1),
      periodDuration: 5,
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );
    late _RecordingCycleListNotifier notifier;

    await tester.pumpWidget(
      _toastTestApp(
        overrides: [
          cycleListProvider.overrideWith((ref) {
            notifier = _RecordingCycleListNotifier(ref, initial: [cycle]);
            return notifier;
          }),
        ],
        home: Consumer(
          builder: (context, ref, _) {
            return ShadButton(
              onPressed: () => deleteCycle(context, ref, cycle),
              child: const Text('Delete cycle'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete cycle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(notifier.deleteCalls, 1);
    expect(find.text('Cycle deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(notifier.addCalls, 1);
    expect(notifier.lastAdded?.id, 'c1');
  });
}
