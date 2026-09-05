import '../../core/utils/date_time_utils.dart';
import '../entities/cycle.dart';

/// Pure helpers for extended cycle statistics.
class StatisticsCalculations {
  StatisticsCalculations._();

  static List<Cycle> recentCompleteCycles(
    List<Cycle> cycles, {
    int limit = 10,
  }) {
    final complete = cycles.where((cycle) => cycle.isComplete).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (complete.length <= limit) {
      return complete;
    }

    return complete.sublist(complete.length - limit);
  }

  static double? averagePeriodDuration(List<Cycle> cycles) {
    final durations = cycles
        .where((cycle) => cycle.periodDuration != null)
        .map((cycle) => cycle.periodDuration!)
        .toList();

    if (durations.isEmpty) {
      return null;
    }

    return durations.reduce((sum, value) => sum + value) / durations.length;
  }

  static int? shortestCycleLength(List<Cycle> completeCycles) {
    if (completeCycles.isEmpty) {
      return null;
    }

    return completeCycles
        .map((cycle) => cycle.cycleLength!)
        .reduce((min, value) => value < min ? value : min);
  }

  static int? longestCycleLength(List<Cycle> completeCycles) {
    if (completeCycles.isEmpty) {
      return null;
    }

    return completeCycles
        .map((cycle) => cycle.cycleLength!)
        .reduce((max, value) => value > max ? value : max);
  }

  static int? currentCycleDay(Cycle? latestCycle) {
    if (latestCycle == null || latestCycle.isComplete) {
      return null;
    }

    final today = DateTimeUtils.dateOnly(DateTime.now());
    return DateTimeUtils.daysBetween(latestCycle.startDate, today) + 1;
  }

  static ColorCategory deviationCategory(double delta) {
    final absDelta = delta.abs();
    if (absDelta <= 3) {
      return ColorCategory.success;
    }
    if (absDelta <= 5) {
      return ColorCategory.warning;
    }
    return ColorCategory.danger;
  }
}

enum ColorCategory { success, warning, danger }
