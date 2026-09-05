import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import 'bento_tile.dart';
import 'range_day_style.dart';

enum PeriodRangeValidationError {
  missingStart,
  missingEnd,
  outOfRange,
  invalidDuration,
}

/// Maps period range selection to cycle fields.
class PeriodRangeLogic {
  PeriodRangeLogic._();

  static const minDuration = 1;
  static const maxDuration = 10;
  static const futureDaysAllowed = 30;
  static const pastYearsAllowed = 5;

  static DateTime firstSelectableDate([DateTime? now]) {
    final today = DateTimeUtils.dateOnly(now ?? DateTime.now());
    return DateTime(today.year - pastYearsAllowed, today.month, 1);
  }

  static DateTime lastSelectableDate([DateTime? now]) {
    final today = DateTimeUtils.dateOnly(now ?? DateTime.now());
    return DateTimeUtils.addDays(today, futureDaysAllowed);
  }

  static bool isDaySelectable(DateTime day, [DateTime? now]) {
    final normalized = DateTimeUtils.dateOnly(day);
    final first = firstSelectableDate(now);
    final last = lastSelectableDate(now);
    return !normalized.isBefore(first) && !normalized.isAfter(last);
  }

  static ShadDateTimeRange defaultRange() {
    final today = DateTimeUtils.dateOnly(DateTime.now());
    return ShadDateTimeRange(
      start: today,
      end: DateTimeUtils.addDays(today, AppConstants.periodDuration - 1),
    );
  }

  static ShadDateTimeRange fromCycle(DateTime startDate, int? periodDuration) {
    final start = DateTimeUtils.dateOnly(startDate);
    if (periodDuration == null || periodDuration < 1) {
      return ShadDateTimeRange(start: start, end: null);
    }
    return ShadDateTimeRange(
      start: start,
      end: DateTimeUtils.addDays(start, periodDuration - 1),
    );
  }

  static int? inclusiveDuration(ShadDateTimeRange? range) {
    if (range?.start == null || range?.end == null) return null;
    return DateTimeUtils.daysBetween(range!.start!, range.end!) + 1;
  }

  static PeriodRangeValidationError? validateError(ShadDateTimeRange? range) {
    if (range?.start == null) {
      return PeriodRangeValidationError.missingStart;
    }
    if (range?.end == null) {
      return PeriodRangeValidationError.missingEnd;
    }
    if (!isDaySelectable(range!.start!) || !isDaySelectable(range.end!)) {
      return PeriodRangeValidationError.outOfRange;
    }
    final duration = inclusiveDuration(range);
    if (duration == null ||
        duration < minDuration ||
        duration > maxDuration) {
      return PeriodRangeValidationError.invalidDuration;
    }
    return null;
  }

  static String localizedMessage(
    PeriodRangeValidationError error,
    AppLocalizations l10n,
  ) {
    return switch (error) {
      PeriodRangeValidationError.missingStart => l10n.periodSelectFirstDay,
      PeriodRangeValidationError.missingEnd => l10n.periodSelectLastDay,
      PeriodRangeValidationError.outOfRange => l10n.periodOutOfRange,
      PeriodRangeValidationError.invalidDuration => l10n.periodDurationRange(
        minDuration,
        maxDuration,
      ),
    };
  }

  @Deprecated('Use validateError with localizedMessage instead')
  static String? validate(ShadDateTimeRange? range) {
    final error = validateError(range);
    if (error == null) return null;
    return switch (error) {
      PeriodRangeValidationError.missingStart =>
        'Select the first day of your period.',
      PeriodRangeValidationError.missingEnd =>
        'Select the last day of your period.',
      PeriodRangeValidationError.outOfRange =>
        'Selected dates must be within the allowed range.',
      PeriodRangeValidationError.invalidDuration =>
        'Period should be between $minDuration–$maxDuration days.',
    };
  }

  static DateTime startDateFrom(ShadDateTimeRange range) {
    return DateTimeUtils.dateOnly(range.start!);
  }

  static int? periodDurationFrom(ShadDateTimeRange range) {
    return inclusiveDuration(range);
  }

  static ShadDateTimeRange? applyDayTap(
    ShadDateTimeRange? current,
    DateTime day,
  ) {
    final date = DateTimeUtils.dateOnly(day);
    if (!isDaySelectable(date)) return current;

    final start = current?.start != null
        ? DateTimeUtils.dateOnly(current!.start!)
        : null;
    final end = current?.end != null
        ? DateTimeUtils.dateOnly(current!.end!)
        : null;

    if (start == null || (start != null && end != null)) {
      return ShadDateTimeRange(start: date, end: null);
    }

    DateTime newStart;
    DateTime newEnd;
    if (date.isBefore(start)) {
      newStart = date;
      newEnd = start;
    } else {
      newStart = start;
      newEnd = date;
    }

    final duration = DateTimeUtils.daysBetween(newStart, newEnd) + 1;
    if (duration > maxDuration) {
      newEnd = DateTimeUtils.addDays(newStart, maxDuration - 1);
    }

    return ShadDateTimeRange(start: newStart, end: newEnd);
  }
}

class PeriodRangePicker extends StatelessWidget {
  const PeriodRangePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final ShadDateTimeRange? selected;
  final ValueChanged<ShadDateTimeRange?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final duration = PeriodRangeLogic.inclusiveDuration(selected);

    return BentoTile(
      label: l10n.periodDateRange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.periodDates,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BentoTokens.space8),
          Text(
            l10n.periodDatesHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BentoTokens.mutedText(context),
            ),
          ),
          const SizedBox(height: BentoTokens.space16),
          _InlineRangeCalendar(
            selected: selected,
            onChanged: onChanged,
          ),
          if (duration != null) ...[
            const SizedBox(height: BentoTokens.space12),
            Text(
              l10n.daysSelected(duration),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: BentoTokens.onSurfaceText(context),
              ),
            ),
            if (selected?.start != null && selected?.end != null)
              Text(
                l10n.dateRange(
                  DateTimeUtils.formatDate(selected!.start!, locale),
                  DateTimeUtils.formatDate(selected!.end!, locale),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BentoTokens.mutedText(context),
                ),
              ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: BentoTokens.space8),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BentoTokens.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineRangeCalendar extends StatefulWidget {
  const _InlineRangeCalendar({
    required this.selected,
    required this.onChanged,
  });

  final ShadDateTimeRange? selected;
  final ValueChanged<ShadDateTimeRange?> onChanged;

  @override
  State<_InlineRangeCalendar> createState() => _InlineRangeCalendarState();
}

class _InlineRangeCalendarState extends State<_InlineRangeCalendar> {
  late DateTime _visibleMonth;
  DateTime? _lastAnchoredStart;

  @override
  void initState() {
    super.initState();
    _visibleMonth = widget.selected?.start ?? DateTime.now();
    _lastAnchoredStart = widget.selected?.start != null
        ? DateTimeUtils.dateOnly(widget.selected!.start!)
        : null;
  }

  @override
  void didUpdateWidget(_InlineRangeCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final anchor = widget.selected?.start != null
        ? DateTimeUtils.dateOnly(widget.selected!.start!)
        : null;

    if (anchor != null && anchor != _lastAnchoredStart) {
      _lastAnchoredStart = anchor;
      _visibleMonth = DateTime(anchor.year, anchor.month);
    }
  }

  bool _canGoForward() {
    final last = PeriodRangeLogic.lastSelectableDate();
    final visibleEnd = DateTimeUtils.lastDayOfMonth(_visibleMonth);
    return visibleEnd.isBefore(last);
  }

  bool _canGoBack() {
    final first = PeriodRangeLogic.firstSelectableDate();
    final visibleStart = DateTimeUtils.firstDayOfMonth(_visibleMonth);
    return visibleStart.isAfter(first);
  }

  RangeDayRole _roleForDate(DateTime date) {
    return RangeDayStyle.roleForRange(
      date: date,
      rangeStart: widget.selected?.start,
      rangeEnd: widget.selected?.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final weekDays = DateTimeUtils.weekdayLabels(locale);
    final firstDayOfMonth = DateTimeUtils.firstDayOfMonth(_visibleMonth);
    final lastDayOfMonth = DateTimeUtils.lastDayOfMonth(_visibleMonth);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final gridStart = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _canGoBack()
                  ? () => setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month - 1,
                      );
                    })
                  : null,
            ),
            Text(
              DateTimeUtils.formatMonthYear(_visibleMonth, locale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _canGoForward()
                  ? () => setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month + 1,
                      );
                    })
                  : null,
            ),
          ],
        ),
        const SizedBox(height: BentoTokens.space8),
        Row(
          children: weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: BentoTokens.mutedText(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: BentoTokens.space4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final date = gridStart.add(Duration(days: index));
            final columnIndex = index % 7;
            final isCurrentMonth = date.month == _visibleMonth.month;
            final role = _roleForDate(date);
            final selectable = PeriodRangeLogic.isDaySelectable(date);
            final bg = RangeDayStyle.backgroundForRole(
              role,
              accentColor: BentoTokens.primary,
            );
            final isToday = DateTimeUtils.isToday(date);
            final radius = RangeDayStyle.radiusForCell(
              role: role,
              columnIndex: columnIndex,
              isToday: isToday,
            );

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectable
                    ? () {
                        widget.onChanged(
                          PeriodRangeLogic.applyDayTap(widget.selected, date),
                        );
                      }
                    : null,
                borderRadius: radius,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: radius,
                    border: isToday && bg == null
                        ? Border.all(color: BentoTokens.primary, width: 2)
                        : null,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: BentoTokens.font14,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: !selectable
                          ? BentoTokens.mutedText(context).withValues(
                              alpha: 0.4,
                            )
                          : !isCurrentMonth
                          ? BentoTokens.mutedText(context).withValues(
                              alpha: 0.55,
                            )
                          : RangeDayStyle.textColorForRole(role, context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
