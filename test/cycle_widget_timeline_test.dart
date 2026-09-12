import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/l10n/app_localizations.dart';
import 'package:strawly/presentation/viewmodels/cycle_widget_sync.dart';

void main() {
  final created = DateTime(2026, 1, 1);
  final en = lookupAppLocalizations(const Locale('en'));

  Cycle cycle({
    required String id,
    required DateTime startDate,
    int? cycleLength,
    int periodDuration = 5,
  }) {
    return Cycle(
      id: id,
      startDate: startDate,
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      createdAt: created,
      updatedAt: created,
    );
  }

  group('CycleWidgetTimeline.build', () {
    test('empty cycles yields placeholder entries', () {
      final entries = CycleWidgetTimeline.build(
        cycles: const [],
        predictedDate: null,
        l10n: en,
        now: DateTime(2026, 9, 7),
      );

      expect(entries, hasLength(CycleWidgetTimeline.horizonDays));
      expect(entries.first.date, DateTime(2026, 9, 7));
      expect(entries.first.phaseKey, 'none');
      expect(entries.first.phaseLabel, '');
      expect(entries.first.digit, '—');
    });

    test('period days carry day number and localized label', () {
      final entries = CycleWidgetTimeline.build(
        cycles: [cycle(id: '1', startDate: DateTime(2026, 9, 5))],
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 9, 7),
      );

      expect(entries.first.phaseKey, 'period');
      expect(entries.first.phaseLabel, 'Period');
      expect(entries.first.digit, '3');
    });

    test('counts down to predicted date then marks overdue', () {
      final cycles = [cycle(id: '1', startDate: DateTime(2026, 9, 5))];

      final fertileDay = CycleWidgetTimeline.build(
        cycles: cycles,
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 9, 20),
      );
      expect(fertileDay.first.phaseKey, 'fertile');
      expect(fertileDay.first.phaseLabel, 'Fertile window');
      expect(fertileDay.first.digit, '13');

      final overdueDay = CycleWidgetTimeline.build(
        cycles: cycles,
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 10, 4),
      );
      expect(overdueDay.first.digit, '!');
    });

    test('entries advance one day at a time from now', () {
      final entries = CycleWidgetTimeline.build(
        cycles: [cycle(id: '1', startDate: DateTime(2026, 9, 5))],
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 9, 7),
        days: 3,
      );

      expect(entries.map((e) => e.date).toList(), [
        DateTime(2026, 9, 7),
        DateTime(2026, 9, 8),
        DateTime(2026, 9, 9),
      ]);
      expect(entries.map((e) => e.digit).toList(), ['3', '4', '5']);
    });

    test('stats payload includes recent cycle lengths and avg label', () {
      final cycles = [
        cycle(id: '1', startDate: DateTime(2026, 6, 5), cycleLength: 28),
        cycle(id: '2', startDate: DateTime(2026, 7, 3), cycleLength: 30),
        cycle(id: '3', startDate: DateTime(2026, 8, 2), cycleLength: 27),
      ];
      final stats = CycleWidgetStats.build(cycles: cycles, l10n: en);

      expect(stats['lengths'], [28, 30, 27]);
      expect(stats['avgLabel'], isNotEmpty);
      expect(stats['avg'], closeTo(28.3, 0.1));
    });

    test('stats payload derives lengths from start dates when cycleLength is null', () {
      final cycles = [
        cycle(id: '1', startDate: DateTime(2026, 6, 5)),
        cycle(id: '2', startDate: DateTime(2026, 7, 3)),
        cycle(id: '3', startDate: DateTime(2026, 8, 2)),
      ];
      final stats = CycleWidgetStats.build(cycles: cycles, l10n: en);

      expect(stats['lengths'], [28, 30]);
      expect(stats['avgLabel'], isNotEmpty);
    });

    test('calendar payload marks period fertile and predicted days', () {
      final cycles = [cycle(id: '1', startDate: DateTime(2026, 9, 5))];
      final calendar = CycleWidgetCalendar.build(
        cycles: cycles,
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 9, 7),
      );

      expect(calendar['w'], isA<List<String>>());
      expect(calendar['months'], hasLength(2));
      final header = calendar['h'] as Map<String, dynamic>;
      expect(header['t'], en.widgetPhaseTitle);
      expect(header['k'], 'period');
      expect(header['l'], 'Period');
      expect(header['n'], isNot('3'));

      final september = (calendar['months'] as List).first as Map<String, dynamic>;
      expect(september['y'], 2026);
      expect(september['m'], 9);
      expect(september['o'], 1);

      final days = september['days'] as List<Map<String, dynamic>>;
      expect(days.firstWhere((day) => day['n'] == 5)['k'], 'period');
      expect(days.firstWhere((day) => day['n'] == 7)['k'], 'period');
      expect(days.firstWhere((day) => day['n'] == 15)['k'], 'fertile');
      expect(days.firstWhere((day) => day['n'] == 19)['p'], 1);

      final october = (calendar['months'] as List)[1] as Map<String, dynamic>;
      final octoberDays = october['days'] as List<Map<String, dynamic>>;
      expect(octoberDays.firstWhere((day) => day['n'] == 3)['k'], 'predicted');
    });

    test('toJson uses compact keys read by native widgets', () {
      final entries = CycleWidgetTimeline.build(
        cycles: [cycle(id: '1', startDate: DateTime(2026, 9, 5))],
        predictedDate: DateTime(2026, 10, 3),
        l10n: en,
        now: DateTime(2026, 9, 7),
        days: 1,
      );

      final decoded = jsonDecode(jsonEncode(entries.first.toJson()));
      expect(decoded['d'], DateTime(2026, 9, 7).millisecondsSinceEpoch);
      expect(decoded['k'], 'period');
      expect(decoded['l'], 'Period');
      expect(decoded['n'], '3');
    });
  });
}
