import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';

enum CalendarDayKind { none, period, fertile, predicted }

class DateSpan {
  const DateSpan({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    final normalized = DateTimeUtils.dateOnly(date);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }
}

/// Resolves period, fertile, and predicted spans for the home calendar.
class CycleCalendarLogic {
  CycleCalendarLogic._();

  static const fertileOffsetStart = 10;
  static const fertileOffsetEnd = 17;
  static const peakFertilityOffset = 14;

  static DateTime peakFertilityDay(Cycle cycle) {
    final start = DateTimeUtils.dateOnly(cycle.startDate);
    return DateTimeUtils.addDays(start, peakFertilityOffset);
  }

  static bool isPeakFertilityDay(
    DateTime date, {
    required List<Cycle> cycles,
  }) {
    final normalized = DateTimeUtils.dateOnly(date);

    for (final cycle in cycles) {
      if (!fertileRange(cycle).contains(normalized)) continue;
      if (DateTimeUtils.isSameDay(normalized, peakFertilityDay(cycle))) {
        return true;
      }
    }

    return false;
  }

  static DateSpan periodRange(Cycle cycle) {
    final start = DateTimeUtils.dateOnly(cycle.startDate);
    final duration = cycle.periodDuration ?? AppConstants.periodDuration;
    return DateSpan(
      start: start,
      end: DateTimeUtils.addDays(start, duration - 1),
    );
  }

  static DateSpan fertileRange(Cycle cycle) {
    final start = DateTimeUtils.dateOnly(cycle.startDate);
    return DateSpan(
      start: DateTimeUtils.addDays(start, fertileOffsetStart),
      end: DateTimeUtils.addDays(start, fertileOffsetEnd),
    );
  }

  static DateSpan predictedRange(DateTime predictedStart) {
    final start = DateTimeUtils.dateOnly(predictedStart);
    return DateSpan(
      start: start,
      end: DateTimeUtils.addDays(start, AppConstants.periodDuration - 1),
    );
  }

  static DateSpan? spanFor(
    DateTime date, {
    required List<Cycle> cycles,
    DateTime? predictedDate,
  }) {
    final normalized = DateTimeUtils.dateOnly(date);

    for (final cycle in cycles) {
      final period = periodRange(cycle);
      if (period.contains(normalized)) return period;
    }

    if (predictedDate != null) {
      final predicted = predictedRange(predictedDate);
      if (predicted.contains(normalized)) return predicted;
    }

    for (final cycle in cycles) {
      final fertile = fertileRange(cycle);
      if (fertile.contains(normalized)) return fertile;
    }

    return null;
  }

  static CalendarDayKind kindFor(
    DateTime date, {
    required List<Cycle> cycles,
    DateTime? predictedDate,
  }) {
    final normalized = DateTimeUtils.dateOnly(date);

    for (final cycle in cycles) {
      if (periodRange(cycle).contains(normalized)) {
        return CalendarDayKind.period;
      }
    }

    if (predictedDate != null &&
        predictedRange(predictedDate).contains(normalized)) {
      return CalendarDayKind.predicted;
    }

    for (final cycle in cycles) {
      if (fertileRange(cycle).contains(normalized)) {
        return CalendarDayKind.fertile;
      }
    }

    return CalendarDayKind.none;
  }

  static Cycle? latestCycle(List<Cycle> cycles) {
    if (cycles.isEmpty) return null;
    return cycles.reduce(
      (a, b) => a.startDate.isAfter(b.startDate) ? a : b,
    );
  }

  static CyclePhase? currentPhase({
    required List<Cycle> cycles,
    DateTime? onDate,
  }) {
    final cycle = latestCycle(cycles);
    if (cycle == null) return null;

    final date = DateTimeUtils.dateOnly(onDate ?? DateTime.now());

    if (periodRange(cycle).contains(date)) return CyclePhase.period;
    if (fertileRange(cycle).contains(date)) return CyclePhase.fertile;

    final periodEnd = periodRange(cycle).end;
    final fertileStart = fertileRange(cycle).start;
    if (date.isAfter(periodEnd) && date.isBefore(fertileStart)) {
      return CyclePhase.follicular;
    }

    return CyclePhase.luteal;
  }
}

enum CyclePhase { period, follicular, fertile, luteal }
