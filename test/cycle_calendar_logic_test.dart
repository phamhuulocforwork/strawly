import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/presentation/widgets/cycle_calendar_logic.dart';

void main() {
  final created = DateTime(2026, 8, 26);

  Cycle ongoingCycle() {
    return Cycle(
      id: 'ongoing',
      startDate: DateTime(2026, 8, 26),
      periodDuration: 5,
      createdAt: created,
      updatedAt: created,
    );
  }

  test('fertile window exists for an ongoing cycle without cycleLength', () {
    final range = CycleCalendarLogic.fertileRange(ongoingCycle());

    expect(range.start, DateTime(2026, 9, 5));
    expect(range.end, DateTime(2026, 9, 12));
  });

  test('kindFor marks fertile days on an ongoing cycle', () {
    final kind = CycleCalendarLogic.kindFor(
      DateTime(2026, 9, 8),
      cycles: [ongoingCycle()],
      predictedDate: DateTime(2026, 9, 23),
    );

    expect(kind, CalendarDayKind.fertile);
  });

  test('kindFor prefers predicted period over fertile', () {
    final kind = CycleCalendarLogic.kindFor(
      DateTime(2026, 9, 23),
      cycles: [ongoingCycle()],
      predictedDate: DateTime(2026, 9, 23),
    );

    expect(kind, CalendarDayKind.predicted);
  });

  test('cycleForDate returns the cycle covering a period day', () {
    final cycle = ongoingCycle();

    expect(
      CycleCalendarLogic.cycleForDate(
        DateTime(2026, 8, 26),
        cycles: [cycle],
      ),
      cycle,
    );
    expect(
      CycleCalendarLogic.cycleForDate(
        DateTime(2026, 8, 30),
        cycles: [cycle],
      ),
      cycle,
    );
  });

  test('cycleForDate returns the cycle covering a fertile day', () {
    final cycle = ongoingCycle();

    expect(
      CycleCalendarLogic.cycleForDate(
        DateTime(2026, 9, 8),
        cycles: [cycle],
      ),
      cycle,
    );
  });

  test('cycleForDate returns null when the day belongs to no cycle', () {
    expect(
      CycleCalendarLogic.cycleForDate(
        DateTime(2026, 7, 1),
        cycles: [ongoingCycle()],
      ),
      isNull,
    );
  });

  test('peak fertility is cycle day 14 from start', () {
    expect(
      CycleCalendarLogic.peakFertilityDay(ongoingCycle()),
      DateTime(2026, 9, 9),
    );
    expect(
      CycleCalendarLogic.isPeakFertilityDay(
        DateTime(2026, 9, 9),
        cycles: [ongoingCycle()],
      ),
      isTrue,
    );
    expect(
      CycleCalendarLogic.isPeakFertilityDay(
        DateTime(2026, 9, 8),
        cycles: [ongoingCycle()],
      ),
      isFalse,
    );
  });
}
