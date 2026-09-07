import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../domain/entities/cycle_statistics.dart';
import '../../domain/usecases/statistics_calculations.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/bento_tile.dart';
import '../widgets/stats_metrics_section.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statisticsAsync = ref.watch(cycleStatisticsProvider);
    final cycleListState = ref.watch(cycleListProvider);
    final completeCycles = StatisticsCalculations.recentCompleteCycles(
      cycleListState.cycles,
    );

    return SafeArea(
      child: statisticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(BentoTokens.space16),
            child: BentoTile(
              label: l10n.statisticsError,
              isError: true,
              errorMessage: error.toString(),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
        data: (statistics) {
          if (statistics.totalCycles == 0) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(BentoTokens.space16),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.statistics,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: BentoTokens.space24),
                  BentoTile(
                    label: l10n.noStatisticsYet,
                    variant: BentoTileVariant.primary,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.chartCombined,
                          size: 56,
                          color: BentoTokens.mutedText(context),
                        ),
                        const SizedBox(height: BentoTokens.space16),
                        Text(
                          l10n.noDataYet,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: BentoTokens.space8),
                        Text(
                          l10n.addCyclesForInsights,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: BentoTokens.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BentoTokens.space16,
                    BentoTokens.space16,
                    BentoTokens.space16,
                    BentoTokens.space8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.statistics,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BentoTokens.space16,
                    0,
                    BentoTokens.space16,
                    BentoTokens.space24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatsMetricsSection(statistics: statistics),
                      const SizedBox(height: BentoTokens.space16),
                      BentoTile(
                        label: l10n.cycleLengthHistory,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cycleLengthHistory,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: BentoTokens.space16),
                            _buildCycleLengthChart(
                              context,
                              completeCycles,
                              l10n,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: BentoTokens.gridGap),
                      _buildRegularityDeviationChart(
                        context,
                        completeCycles,
                        statistics,
                        l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCycleLengthChart(
    BuildContext context,
    List<Cycle> completeCycles,
    AppLocalizations l10n,
  ) {
    if (completeCycles.isEmpty) {
      return _buildChartEmptyState(context, l10n);
    }

    final locale = Localizations.localeOf(context).toString();
    final lengths = completeCycles.map((cycle) => cycle.cycleLength!).toList();
    final minLength = lengths.reduce((a, b) => a < b ? a : b).toDouble();
    final maxLength = lengths.reduce((a, b) => a > b ? a : b).toDouble();
    final yPadding = 2.0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: BentoTokens.mutedText(context).withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < completeCycles.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateTimeUtils.formatDateShort(
                              completeCycles[index].startDate,
                              locale,
                            ).substring(0, 5),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: minLength - yPadding,
              maxY: maxLength + yPadding,
              lineBarsData: [
                LineChartBarData(
                  spots: completeCycles
                      .asMap()
                      .entries
                      .map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.cycleLength!.toDouble(),
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: BentoTokens.secondary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: BentoTokens.secondary.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: BentoTokens.space8),
        Text(
          l10n.lastNCycles(completeCycles.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: BentoTokens.mutedText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularityDeviationChart(
    BuildContext context,
    List<Cycle> completeCycles,
    CycleStatistics statistics,
    AppLocalizations l10n,
  ) {
    final score = statistics.regularityScore ?? 0.0;
    final scoreColor = score >= 80
        ? BentoTokens.success
        : score >= 60
        ? BentoTokens.warning
        : BentoTokens.danger;

    return BentoTile(
      label: l10n.regularityScore,
      variant: statistics.isRegular
          ? BentoTileVariant.success
          : BentoTileVariant.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.regularityScore,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: BentoTokens.space4),
                    Text(
                      l10n.deviationFromAverage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BentoTokens.mutedText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BentoTokens.space12,
                  vertical: BentoTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BentoTokens.radiusSm),
                ),
                child: Text(
                  '${score.toStringAsFixed(0)}/100',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BentoTokens.space16),
          if (completeCycles.isEmpty)
            _buildChartEmptyState(context, l10n)
          else
            _buildRegularityBarChart(
              context,
              completeCycles,
              statistics,
              l10n,
            ),
          const SizedBox(height: BentoTokens.space12),
          Text(
            statistics.isRegular
                ? l10n.cyclesRegular
                : l10n.cyclesVariation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BentoTokens.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartEmptyState(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Center(
        child: Text(
          l10n.notEnoughChartData,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: BentoTokens.mutedText(context),
          ),
        ),
      ),
    );
  }

  Widget _buildRegularityBarChart(
    BuildContext context,
    List<Cycle> completeCycles,
    CycleStatistics statistics,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final average = statistics.averageCycleLength;

    final deltas = completeCycles
        .map((cycle) => cycle.cycleLength! - average)
        .toList();
    final maxAbsDelta = deltas
        .map((delta) => delta.abs())
        .reduce((a, b) => a > b ? a : b)
        .clamp(3.0, 10.0);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAbsDelta + 1,
          minY: -(maxAbsDelta + 1),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: value == 0
                    ? BentoTokens.mutedText(context).withValues(
                        alpha: 0.45,
                      )
                    : BentoTokens.mutedText(context).withValues(
                        alpha: 0.15,
                      ),
                strokeWidth: value == 0 ? 1.5 : 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: maxAbsDelta <= 4 ? 2 : 3,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return Text(
                      l10n.averageShort,
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  if (value == value.roundToDouble()) {
                    final prefix = value > 0 ? '+' : '';
                    return Text(
                      '$prefix${value.toInt()}',
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < completeCycles.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateTimeUtils.formatDateShort(
                          completeCycles[index].startDate,
                          locale,
                        ).substring(0, 5),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: completeCycles.asMap().entries.map((entry) {
            final delta = entry.value.cycleLength! - average;
            final color = _colorForDeviation(context, delta);

            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  fromY: delta >= 0 ? 0 : delta,
                  toY: delta >= 0 ? delta : 0,
                  color: color,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _colorForDeviation(BuildContext context, double delta) {
    return switch (StatisticsCalculations.deviationCategory(delta)) {
      ColorCategory.success => BentoTokens.success,
      ColorCategory.warning => BentoTokens.warning,
      ColorCategory.danger => BentoTokens.danger,
    };
  }
}
