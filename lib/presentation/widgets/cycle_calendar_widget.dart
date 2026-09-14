import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import 'bento_tile.dart';
import 'cycle_calendar_logic.dart';
import 'dashed_cell_border.dart';
import 'period_range_picker.dart';
import 'range_day_style.dart';

class CycleCalendarWidget extends StatefulWidget {
  const CycleCalendarWidget({
    super.key,
    required this.cycles,
    this.predictedDates = const [],
    this.onCycleTap,
    this.onDayTap,
  });

  final List<Cycle> cycles;
  final List<DateTime> predictedDates;
  final ValueChanged<Cycle>? onCycleTap;
  final ValueChanged<DateTime>? onDayTap;

  @override
  State<CycleCalendarWidget> createState() => _CycleCalendarWidgetState();
}

class _CycleCalendarWidgetState extends State<CycleCalendarWidget> {
  static const double _periodFillAlpha = 0.4;
  static const double _predictedFillAlpha = 0.18;

  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return BentoTile(
      label: l10n.cycleCalendar,
      padding: const EdgeInsets.all(BentoTokens.space12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(AppIcons.chevronLeft),
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
                DateTimeUtils.formatMonthYear(selectedMonth, locale),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(AppIcons.chevronRight),
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
          const SizedBox(height: BentoTokens.space8),
          _buildCalendar(context, locale),
          const SizedBox(height: BentoTokens.space12),
          _buildLegend(context, l10n),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, String locale) {
    final weekDays = DateTimeUtils.weekdayLabels(locale);
    final firstDayOfMonth = DateTimeUtils.firstDayOfMonth(selectedMonth);
    final lastDayOfMonth = DateTimeUtils.lastDayOfMonth(selectedMonth);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;

    return Column(
      children: [
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
        const SizedBox(height: BentoTokens.space8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final date = DateTime(selectedMonth.year, selectedMonth.month, day);
            final columnIndex = index % 7;

            return _buildDayCell(context, date, columnIndex);
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, int columnIndex) {
    final isToday = DateTimeUtils.isToday(date);
    final kind = CycleCalendarLogic.kindFor(
      date,
      cycles: widget.cycles,
      predictedDates: widget.predictedDates,
    );
    final span = CycleCalendarLogic.spanFor(
      date,
      cycles: widget.cycles,
      predictedDates: widget.predictedDates,
    );

    RangeDayRole role = RangeDayRole.none;
    Color? bgColor;
    Color? textColor;
    var isPeakFertile = false;

    if (kind == CalendarDayKind.fertile) {
      textColor = _fertileTextColor(context);
      isPeakFertile = CycleCalendarLogic.isPeakFertilityDay(
        date,
        cycles: widget.cycles,
      );
    } else if (span != null &&
        (kind == CalendarDayKind.period || kind == CalendarDayKind.predicted)) {
      role = RangeDayStyle.roleForRange(
        date: date,
        rangeStart: span.start,
        rangeEnd: span.end,
      );
      final fillAlpha = kind == CalendarDayKind.period
          ? _periodFillAlpha
          : _predictedFillAlpha;
      bgColor = RangeDayStyle.backgroundForRole(
        role,
        accentColor: BentoTokens.primary,
        middleAlpha: fillAlpha,
        uniformFill: true,
      );
      textColor = RangeDayStyle.textColorForRole(role, context);
    }

    final radius = kind == CalendarDayKind.fertile
        ? BorderRadius.circular(BentoTokens.radiusMd)
        : RangeDayStyle.radiusForCell(
            role: role,
            columnIndex: columnIndex,
          );

    final isPeriodStart =
        kind == CalendarDayKind.period &&
        span != null &&
        DateTimeUtils.isSameDay(date, span.start);

    Widget cell = Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: isPeriodStart
          ? _pinnedDay(
              context,
              date.day.toString(),
              textColor,
              isToday,
              isToday || isPeakFertile,
            )
          : Text(
              date.day.toString(),
              style: TextStyle(
                color: textColor ?? BentoTokens.onSurfaceText(context),
                fontWeight: isToday || isPeakFertile
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: BentoTokens.font14,
                decoration: isToday ? TextDecoration.underline : TextDecoration.none,
                decorationColor: textColor ?? BentoTokens.onSurfaceText(context),
                decorationThickness: 1.5,
              ),
            ),
    );

    if (isPeakFertile) {
      cell = DashedCellBorder(
        color: _fertileTextColor(context),
        borderRadius: radius,
        child: cell,
      );
    }

    final cycle = CycleCalendarLogic.cycleForDate(date, cycles: widget.cycles);
    VoidCallback? onTap;
    if (cycle != null && widget.onCycleTap != null) {
      onTap = () => widget.onCycleTap!(cycle);
    } else if (cycle == null &&
        widget.onDayTap != null &&
        PeriodRangeLogic.isDaySelectable(date)) {
      onTap = () => widget.onDayTap!(date);
    }

    if (onTap == null) {
      return cell;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: cell,
      ),
    );
  }

  Widget _pinnedDay(
    BuildContext context,
    String dayText,
    Color? textColor,
    bool isToday,
    bool emphasize,
  ) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          left: -10,
          child: Transform.rotate(
            angle: -math.pi / 6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svgs/logo.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SvgPicture.asset(
                  'assets/svgs/logo.svg',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            dayText,
            style: TextStyle(
              color: textColor ?? BentoTokens.onSurfaceText(context),
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
              fontSize: BentoTokens.font14,
              decoration: isToday ? TextDecoration.underline : TextDecoration.none,
              decorationColor: textColor ?? BentoTokens.onSurfaceText(context),
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Color _fertileTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? BentoTokens.secondaryDark : const Color(0xFF4A9BB8);
  }

  Color _predictedLegendColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? BentoTokens.primaryDark.withValues(alpha: _predictedFillAlpha)
        : BentoTokens.primary.withValues(alpha: _predictedFillAlpha);
  }

  Widget _buildLegend(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: BentoTokens.space16,
      runSpacing: BentoTokens.space12,
      children: [
        _buildLegendItem(
          context,
          color: BentoTokens.primary,
          label: l10n.legendPeriod,
        ),
        _buildLegendItem(
          context,
          color: _fertileTextColor(context),
          label: l10n.legendFertile,
          dashed: true,
        ),
        _buildLegendItem(
          context,
          color: _predictedLegendColor(context),
          label: l10n.legendPredicted,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    bool dashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed)
          DashedCellBorder(
            color: color,
            borderRadius: BorderRadius.circular(BentoTokens.radiusSm),
            child: Container(
              width: 20,
              height: 8,
              alignment: Alignment.center,
              child: Container(width: 10, height: 2, color: color),
            ),
          )
        else
          Container(
            width: 20,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(BentoTokens.radiusSm),
            ),
          ),
        const SizedBox(width: BentoTokens.space4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
