import 'package:flutter/material.dart';
import '../../domain/entities/cycle_statistics.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';

class StatsMetricsSection extends StatelessWidget {
  const StatsMetricsSection({super.key, required this.statistics});

  final CycleStatistics statistics;

  static const _heroPadding = 14.0;
  static const _rowHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatsHeroCard(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.avgCycle,
                  value: l10n.avgCycleDays(
                    statistics.averageCycleLength.toStringAsFixed(1),
                  ),
                ),
              ),
              const SizedBox(width: BentoTokens.gridGap),
              Expanded(
                child: _StatsHeroCard(
                  icon: Icons.water_drop_outlined,
                  label: l10n.avgPeriod,
                  value: statistics.averagePeriodDuration != null
                      ? l10n.daysUnit(
                          statistics.averagePeriodDuration!
                              .toStringAsFixed(1),
                        )
                      : '—',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BentoTokens.gridGap),
        _StatsDetailCard(statistics: statistics),
        const SizedBox(height: BentoTokens.gridGap),
        _StatsPredictionStatus(count: statistics.completeCycles),
      ],
    );
  }
}

class _StatsHeroCard extends StatelessWidget {
  const _StatsHeroCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fg = BentoTokens.statCycleForeground(context);

    return Container(
      padding: const EdgeInsets.all(StatsMetricsSection._heroPadding),
      decoration: BoxDecoration(
        color: BentoTokens.statCycleBackground(context),
        borderRadius: BentoTokens.tileRadius,
        border: Border.all(color: BentoTokens.tileBorder(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(height: BentoTokens.space8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: fg.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: BentoTokens.space4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: BentoTokens.font20,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDetailCard extends StatelessWidget {
  const _StatsDetailCard({required this.statistics});

  final CycleStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <Widget>[
      _StatsDetailRow(
        icon: Icons.repeat,
        iconColor: BentoTokens.statBlue(context),
        label: l10n.totalCycles,
        value: statistics.totalCycles.toString(),
        showDivider: true,
      ),
      _StatsDetailRow(
        icon: Icons.show_chart_outlined,
        iconColor: BentoTokens.statPurple(context),
        label: l10n.stdDev,
        value: l10n.daysUnit(
          statistics.standardDeviation.toStringAsFixed(1),
        ),
        showDivider:
            (statistics.shortestCycleLength != null &&
                statistics.longestCycleLength != null) ||
            statistics.currentCycleDay != null,
      ),
      if (statistics.shortestCycleLength != null &&
          statistics.longestCycleLength != null)
        _StatsDetailRow(
          icon: Icons.swap_vert,
          iconColor: BentoTokens.statAmber(context),
          label: l10n.shortestLongest,
          value: l10n.cycleLengthRange(
            statistics.shortestCycleLength!,
            statistics.longestCycleLength!,
          ),
          showDivider: statistics.currentCycleDay != null,
        ),
      if (statistics.currentCycleDay != null)
        _StatsDetailRow(
          icon: Icons.event_outlined,
          iconColor: BentoTokens.mutedText(context),
          label: l10n.currentCycleDay,
          value: l10n.currentCycleDayValue(statistics.currentCycleDay!),
          showDivider: false,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: BentoTokens.tileBackground(context),
        borderRadius: BentoTokens.tileRadius,
        border: Border.all(color: BentoTokens.tileBorder(context), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class _StatsDetailRow extends StatelessWidget {
  const _StatsDetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: StatsMetricsSection._rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BentoTokens.space16),
            child: Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: BentoTokens.space12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: BentoTokens.mutedText(context),
                    ),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: BentoTokens.font14,
                    fontWeight: FontWeight.w500,
                    color: BentoTokens.onSurfaceText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: BentoTokens.tileBorder(context),
          ),
      ],
    );
  }
}

class _StatsPredictionStatus extends StatelessWidget {
  const _StatsPredictionStatus({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = BentoTokens.statSuccessForeground(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BentoTokens.space4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: color),
          const SizedBox(width: BentoTokens.space8),
          Expanded(
            child: Text(
              l10n.predictionReadyStatus(count),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: BentoTokens.font14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
