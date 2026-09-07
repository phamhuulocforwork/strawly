import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../presentation/widgets/cycle_calendar_logic.dart';
import 'cycle.dart';

/// Compact payload for OS Dynamic Island / Super Island (decorative only).
class CycleLiveIslandSnapshot {
  const CycleLiveIslandSnapshot({
    this.phase,
    required this.compactDigit,
    this.periodDay,
    this.daysUntil,
    this.predictedDate,
    this.hasData = false,
  });

  final CyclePhase? phase;

  /// Shown in compact trailing: day count, period day, `!` when overdue, or `—`.
  final String compactDigit;

  /// 1-based day within the current period, if applicable.
  final int? periodDay;

  /// Days until predicted next period; negative when overdue.
  final int? daysUntil;

  final DateTime? predictedDate;

  final bool hasData;

  static const emptyDigit = '—';
  static const overdueDigit = '!';

  factory CycleLiveIslandSnapshot.from({
    required List<Cycle> cycles,
    DateTime? predictedDate,
    DateTime? now,
  }) {
    final today = DateTimeUtils.dateOnly(now ?? DateTime.now());
    final phase = CycleCalendarLogic.currentPhase(
      cycles: cycles,
      onDate: today,
    );
    final latest = CycleCalendarLogic.latestCycle(cycles);

    if (latest == null) {
      return const CycleLiveIslandSnapshot(compactDigit: emptyDigit);
    }

    int? periodDay;
    if (phase == CyclePhase.period) {
      final range = CycleCalendarLogic.periodRange(latest);
      periodDay = DateTimeUtils.daysBetween(range.start, today) + 1;
    }

    int? daysUntil;
    if (predictedDate != null) {
      daysUntil = DateTimeUtils.daysBetween(today, predictedDate);
    }

    final compactDigit = _compactDigit(
      phase: phase,
      periodDay: periodDay,
      daysUntil: daysUntil,
    );

    return CycleLiveIslandSnapshot(
      phase: phase,
      compactDigit: compactDigit,
      periodDay: periodDay,
      daysUntil: daysUntil,
      predictedDate: predictedDate != null
          ? DateTimeUtils.dateOnly(predictedDate)
          : null,
      hasData: true,
    );
  }

  static String _compactDigit({
    required CyclePhase? phase,
    required int? periodDay,
    required int? daysUntil,
  }) {
    if (phase == CyclePhase.period && periodDay != null) {
      return '$periodDay';
    }
    if (daysUntil != null) {
      if (daysUntil < 0) return overdueDigit;
      return '$daysUntil';
    }
    return emptyDigit;
  }

  /// Keys consumed by native Live Activity / Android RemoteViews.
  Map<String, dynamic> toActivityMap({required String phaseLabel}) {
    return {
      'compactDigit': compactDigit,
      'phaseKey': phase?.name ?? 'none',
      'phaseLabel': phaseLabel,
      'periodDay': periodDay ?? -1,
      'daysUntil': daysUntil ?? -999,
      'predictedDateMs': predictedDate?.millisecondsSinceEpoch ?? 0,
      'hasData': hasData,
      'periodDuration': AppConstants.periodDuration,
    };
  }
}
