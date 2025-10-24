import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';

class CycleCalendarWidget extends StatefulWidget {
  final List<Cycle> cycles;
  final DateTime? predictedDate;

  const CycleCalendarWidget({
    super.key,
    required this.cycles,
    this.predictedDate,
  });

  @override
  State<CycleCalendarWidget> createState() => _CycleCalendarWidgetState();
}

class _CycleCalendarWidgetState extends State<CycleCalendarWidget> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCalendar(context),

            const SizedBox(height: 16),

            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final firstDayOfMonth = DateTimeUtils.firstDayOfMonth(selectedMonth);
    final lastDayOfMonth = DateTimeUtils.lastDayOfMonth(selectedMonth);
    final daysInMonth = lastDayOfMonth.day;

    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {}

            final day = index - firstWeekday + 1;
            final date = DateTime(selectedMonth.year, selectedMonth.month, day);

            return _buildDayCell(context, date);
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isToday = DateTimeUtils.isToday(date);
    final cycleType = _getCycleTypeForDate(date);

    Color? bgColor;
    Color? textColor;

    switch (cycleType) {
      case _CycleType.period:
        bgColor = Theme.of(context).colorScheme.primary;
        textColor = Colors.white;
        break;
      case _CycleType.fertile:
        bgColor = Theme.of(
          context,
        ).colorScheme.secondary.withValues(alpha: 0.3);
        break;
      case _CycleType.predicted:
        bgColor = Colors.orange.withValues(alpha: 0.2);
        break;
      case _CycleType.none:
        break;
    }

    if (isToday && bgColor == null) {
      bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color:
                textColor ??
                (isToday ? Theme.of(context).colorScheme.primary : null),
            fontWeight: isToday ? FontWeight.bold : null,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  _CycleType _getCycleTypeForDate(DateTime date) {
    if (widget.predictedDate != null) {
      final predictedStart = DateTimeUtils.dateOnly(widget.predictedDate!);
      final predictedEnd = DateTimeUtils.addDays(
        predictedStart,
        AppConstants.periodDuration,
      );

      if (date.isAfter(predictedStart.subtract(const Duration(days: 1))) &&
          date.isBefore(predictedEnd.add(const Duration(days: 1)))) {
        return _CycleType.predicted;
      }
    }

    for (final cycle in widget.cycles) {
      final cycleStart = DateTimeUtils.dateOnly(cycle.startDate);
      final periodDuration =
          cycle.periodDuration ?? AppConstants.periodDuration;
      final periodEnd = DateTimeUtils.addDays(cycleStart, periodDuration);

      if (date.isAfter(cycleStart.subtract(const Duration(days: 1))) &&
          date.isBefore(periodEnd.add(const Duration(days: 1)))) {
        return _CycleType.period;
      }

      if (cycle.cycleLength != null) {
        final fertileStart = DateTimeUtils.addDays(cycleStart, 10);
        final fertileEnd = DateTimeUtils.addDays(cycleStart, 17);

        if (date.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
            date.isBefore(fertileEnd.add(const Duration(days: 1)))) {
          return _CycleType.fertile;
        }
      }
    }

    return _CycleType.none;
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          context,
          color: Theme.of(context).colorScheme.primary,
          label: 'Period',
        ),
        _buildLegendItem(
          context,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          label: 'Fertile',
        ),
        _buildLegendItem(
          context,
          color: Colors.orange.withValues(alpha: 0.2),
          label: 'Predicted',
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}

enum _CycleType { none, period, fertile, predicted }
