import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/domain/usecases/statistics_calculations.dart';

void main() {
  final created = DateTime(2026, 1, 1);

  group('StatisticsCalculations', () {
    test('recentCompleteCycles returns oldest-to-newest limited set', () {
      final cycles = List.generate(
        12,
        (index) => Cycle(
          id: '$index',
          startDate: DateTime(2026, 1, index + 1),
          cycleLength: 28 + index,
          createdAt: created,
          updatedAt: created,
        ),
      );

      final recent = StatisticsCalculations.recentCompleteCycles(cycles, limit: 10);

      expect(recent, hasLength(10));
      expect(recent.first.startDate, DateTime(2026, 1, 3));
      expect(recent.last.startDate, DateTime(2026, 1, 12));
    });

    test('averagePeriodDuration ignores cycles without duration', () {
      final average = StatisticsCalculations.averagePeriodDuration([
        Cycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          periodDuration: 4,
          createdAt: created,
          updatedAt: created,
        ),
        Cycle(
          id: '2',
          startDate: DateTime(2026, 2, 1),
          periodDuration: 6,
          createdAt: created,
          updatedAt: created,
        ),
        Cycle(
          id: '3',
          startDate: DateTime(2026, 3, 1),
          createdAt: created,
          updatedAt: created,
        ),
      ]);

      expect(average, 5);
    });

    test('shortest and longest cycle lengths use complete cycles only', () {
      final complete = [
        Cycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          cycleLength: 26,
          createdAt: created,
          updatedAt: created,
        ),
        Cycle(
          id: '2',
          startDate: DateTime(2026, 2, 1),
          cycleLength: 31,
          createdAt: created,
          updatedAt: created,
        ),
      ];

      expect(StatisticsCalculations.shortestCycleLength(complete), 26);
      expect(StatisticsCalculations.longestCycleLength(complete), 31);
    });

    test('currentCycleDay returns day count for ongoing cycle', () {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day)
          .subtract(const Duration(days: 4));

      final day = StatisticsCalculations.currentCycleDay(
        Cycle(
          id: '1',
          startDate: startDate,
          createdAt: created,
          updatedAt: created,
        ),
      );

      expect(day, 5);
    });

    test('currentCycleDay is null when latest cycle is complete', () {
      final day = StatisticsCalculations.currentCycleDay(
        Cycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          cycleLength: 28,
          createdAt: created,
          updatedAt: created,
        ),
      );

      expect(day, isNull);
    });

    test('deviationCategory follows regularity thresholds', () {
      expect(
        StatisticsCalculations.deviationCategory(2),
        ColorCategory.success,
      );
      expect(
        StatisticsCalculations.deviationCategory(-3),
        ColorCategory.success,
      );
      expect(
        StatisticsCalculations.deviationCategory(4),
        ColorCategory.warning,
      );
      expect(
        StatisticsCalculations.deviationCategory(-6),
        ColorCategory.danger,
      );
    });
  });
}
