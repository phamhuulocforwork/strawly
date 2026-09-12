import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../domain/entities/cycle_live_island_snapshot.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/cycle_calendar_logic.dart';

class CycleWidgetEntry {
  const CycleWidgetEntry({
    required this.date,
    required this.phaseKey,
    required this.phaseLabel,
    required this.digit,
  });

  final DateTime date;
  final String phaseKey;
  final String phaseLabel;
  final String digit;

  Map<String, dynamic> toJson() {
    return {
      'd': date.millisecondsSinceEpoch,
      'k': phaseKey,
      'l': phaseLabel,
      'n': digit,
    };
  }
}

/// Day-by-day snapshot so the OS widget can refresh itself after midnight
/// without the app being opened.
class CycleWidgetTimeline {
  CycleWidgetTimeline._();

  static const int horizonDays = 40;

  static List<CycleWidgetEntry> build({
    required List<Cycle> cycles,
    DateTime? predictedDate,
    required AppLocalizations l10n,
    DateTime? now,
    int days = horizonDays,
  }) {
    final start = DateTimeUtils.dateOnly(now ?? DateTime.now());
    return List.generate(days, (offset) {
      final date = DateTimeUtils.addDays(start, offset);
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycles,
        predictedDate: predictedDate,
        now: date,
      );
      return CycleWidgetEntry(
        date: date,
        phaseKey: snapshot.phase?.name ?? 'none',
        phaseLabel: snapshot.phase?.label(l10n) ?? '',
        digit: snapshot.compactDigit,
      );
    });
  }
}

/// Recent cycle lengths for the wide bar widget mini chart.
class CycleWidgetStats {
  CycleWidgetStats._();

  static const String statsKey = 'widget_stats';

  static Map<String, dynamic> build({
    required List<Cycle> cycles,
    required AppLocalizations l10n,
    int maxBars = 7,
  }) {
    final lengths = _cycleLengths(cycles);
    if (lengths.isEmpty) {
      return const {'avgLabel': '', 'lengths': <int>[]};
    }

    final recent = lengths.length <= maxBars
        ? lengths
        : lengths.sublist(lengths.length - maxBars);
    final average = recent.reduce((a, b) => a + b) / recent.length;

    return {
      'avg': average,
      'avgLabel': l10n.avgCycleDays(average.toStringAsFixed(0)),
      'lengths': recent,
    };
  }

  /// Uses stored [Cycle.cycleLength] when available, otherwise the gap
  /// between consecutive period start dates (same idea as the stats screen).
  static List<int> _cycleLengths(List<Cycle> cycles) {
    if (cycles.isEmpty) return const [];

    final sorted = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lengths = <int>[];

    for (var index = 0; index < sorted.length; index++) {
      final cycle = sorted[index];
      if (cycle.cycleLength != null) {
        lengths.add(cycle.cycleLength!);
        continue;
      }
      if (index + 1 >= sorted.length) continue;

      final gap = DateTimeUtils.daysBetween(
        cycle.startDate,
        sorted[index + 1].startDate,
      );
      if (gap > 0) {
        lengths.add(gap);
      }
    }

    return lengths;
  }
}

/// Current and next month calendar grid for the calendar home widget.
class CycleWidgetCalendar {
  CycleWidgetCalendar._();

  static const String calendarKey = 'widget_calendar';

  static Map<String, dynamic> build({
    required List<Cycle> cycles,
    DateTime? predictedDate,
    required AppLocalizations l10n,
    String? locale,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final currentMonth = DateTime(reference.year, reference.month);
    final nextMonth = DateTime(reference.year, reference.month + 1);
    final snapshot = CycleLiveIslandSnapshot.from(
      cycles: cycles,
      predictedDate: predictedDate,
      now: reference,
    );
    final daysUntil = snapshot.daysUntil;
    final daysUntilDigit = daysUntil == null
        ? CycleLiveIslandSnapshot.emptyDigit
        : daysUntil < 0
            ? CycleLiveIslandSnapshot.overdueDigit
            : '$daysUntil';

    return {
      'w': DateTimeUtils.weekdayLabels(locale),
      'h': {
        't': l10n.widgetPhaseTitle,
        'k': snapshot.phase?.name ?? 'none',
        'l': snapshot.phase?.label(l10n) ?? '',
        'n': daysUntilDigit,
      },
      'months': [
        _buildMonth(
          month: currentMonth,
          cycles: cycles,
          predictedDate: predictedDate,
        ),
        _buildMonth(
          month: nextMonth,
          cycles: cycles,
          predictedDate: predictedDate,
        ),
      ],
    };
  }

  static Map<String, dynamic> _buildMonth({
    required DateTime month,
    required List<Cycle> cycles,
    DateTime? predictedDate,
  }) {
    final firstDay = DateTimeUtils.firstDayOfMonth(month);
    final lastDay = DateTimeUtils.lastDayOfMonth(month);
    final offset = (firstDay.weekday - 1) % 7;
    final days = <Map<String, dynamic>>[];

    for (var day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final kind = CycleCalendarLogic.kindFor(
        date,
        cycles: cycles,
        predictedDate: predictedDate,
      );
      final peak = kind == CalendarDayKind.fertile &&
          CycleCalendarLogic.isPeakFertilityDay(date, cycles: cycles);
      final entry = <String, dynamic>{
        'n': day,
        'k': kind.name,
      };
      if (peak) {
        entry['p'] = 1;
      }
      days.add(entry);
    }

    return {
      'y': month.year,
      'm': month.month,
      'o': offset,
      'days': days,
    };
  }
}

/// Pushes the cycle timeline into home_widget storage and refreshes widgets.
class CycleWidgetSync {
  CycleWidgetSync._();

  static const String timelineKey = 'widget_timeline';
  static const String _iosWidgetKind = 'StrawlyHomeWidget';

  static const List<String> androidProviders = [
    'CycleWidgetBarProvider',
    'CycleWidget2x2Provider',
    'CycleWidget2x3Provider',
  ];

  static bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static Future<void> sync({
    required List<Cycle> cycles,
    DateTime? predictedDate,
    required Locale locale,
  }) async {
    if (!_isSupportedPlatform) return;

    try {
      final l10n = lookupAppLocalizations(locale);
      final timeline = CycleWidgetTimeline.build(
        cycles: cycles,
        predictedDate: predictedDate,
        l10n: l10n,
      );
      final timelinePayload = jsonEncode(
        timeline.map((entry) => entry.toJson()).toList(),
      );
      final calendarPayload = jsonEncode(
        CycleWidgetCalendar.build(
          cycles: cycles,
          predictedDate: predictedDate,
          l10n: l10n,
          locale: locale.toString(),
        ),
      );
      final statsPayload = jsonEncode(
        CycleWidgetStats.build(cycles: cycles, l10n: l10n),
      );

      await HomeWidget.setAppGroupId(AppConstants.liveIslandAppGroupId);
      await HomeWidget.saveWidgetData<String>(timelineKey, timelinePayload);
      await HomeWidget.saveWidgetData<String>(
        CycleWidgetCalendar.calendarKey,
        calendarPayload,
      );
      await HomeWidget.saveWidgetData<String>(
        CycleWidgetStats.statsKey,
        statsPayload,
      );

      if (Platform.isAndroid) {
        for (final provider in androidProviders) {
          await HomeWidget.updateWidget(
            qualifiedAndroidName: 'com.example.strawly.$provider',
          );
        }
      } else {
        await HomeWidget.updateWidget(iOSName: _iosWidgetKind);
      }
    } catch (error, stack) {
      debugPrint('Cycle widget sync failed: $error\n$stack');
    }
  }
}
