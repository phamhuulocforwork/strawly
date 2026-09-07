import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/domain/entities/cycle_live_island_snapshot.dart';
import 'package:strawly/presentation/widgets/cycle_calendar_logic.dart';

void main() {
  final created = DateTime(2026, 1, 1);

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

  group('CycleLiveIslandSnapshot.from', () {
    test('empty cycles yields decorative placeholder digit', () {
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: const [],
        predictedDate: null,
        now: DateTime(2026, 9, 7),
      );

      expect(snapshot.hasData, isFalse);
      expect(snapshot.compactDigit, CycleLiveIslandSnapshot.emptyDigit);
      expect(snapshot.phase, isNull);
    });

    test('during period shows period day in compact digit', () {
      final cycles = [cycle(id: '1', startDate: DateTime(2026, 9, 5))];
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycles,
        predictedDate: DateTime(2026, 10, 3),
        now: DateTime(2026, 9, 7),
      );

      expect(snapshot.phase, CyclePhase.period);
      expect(snapshot.periodDay, 3);
      expect(snapshot.compactDigit, '3');
    });

    test('follicular phase shows days until predicted period', () {
      final cycles = [cycle(id: '1', startDate: DateTime(2026, 9, 1))];
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycles,
        predictedDate: DateTime(2026, 9, 29),
        now: DateTime(2026, 9, 7),
      );

      expect(snapshot.phase, CyclePhase.follicular);
      expect(snapshot.daysUntil, 22);
      expect(snapshot.compactDigit, '22');
    });

    test('overdue prediction shows exclamation digit', () {
      final cycles = [cycle(id: '1', startDate: DateTime(2026, 8, 1))];
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycles,
        predictedDate: DateTime(2026, 9, 1),
        now: DateTime(2026, 9, 7),
      );

      expect(snapshot.daysUntil, lessThan(0));
      expect(snapshot.compactDigit, CycleLiveIslandSnapshot.overdueDigit);
    });

    test('toActivityMap includes phase label and digit', () {
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: [cycle(id: '1', startDate: DateTime(2026, 9, 5))],
        predictedDate: DateTime(2026, 10, 3),
        now: DateTime(2026, 9, 7),
      );

      final map = snapshot.toActivityMap(phaseLabel: 'Kỳ kinh');

      expect(map['compactDigit'], '3');
      expect(map['phaseKey'], 'period');
      expect(map['phaseLabel'], 'Kỳ kinh');
      expect(map['hasData'], isTrue);
    });
  });
}
