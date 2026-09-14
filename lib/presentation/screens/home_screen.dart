import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/usecases/prediction_usecases.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/bento_grid.dart';
import '../widgets/bento_tile.dart';
import '../widgets/cycle_actions.dart';
import '../widgets/cycle_calendar_logic.dart';
import '../widgets/cycle_calendar_widget.dart';
import '../widgets/cycle_list_tile.dart';
import '../widgets/prediction_card_widget.dart';
import 'cycle_history_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final cycleListState = ref.watch(cycleListProvider);
    final predictedDate = ref.watch(predictedNextCycleDateProvider);
    final predictedDatesAsync = ref.watch(predictedCycleDatesProvider);
    final statisticsAsync = ref.watch(cycleStatisticsProvider);
    final statistics = statisticsAsync.valueOrNull;
    final predictionWindowDays = predictionWindowDaysFromStatistics(
      completeCycles: statistics?.completeCycles ?? 0,
      standardDeviation: statistics?.standardDeviation ?? 0,
    );
    final recentCycles = cycleListState.cycles
        .take(AppConstants.recentCyclesLimit)
        .toList();
    final latestCycle = CycleCalendarLogic.latestCycle(cycleListState.cycles);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                BentoTokens.space16,
                BentoTokens.space16,
                BentoTokens.space16,
                BentoTokens.space8,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/logo.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: BentoTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: BentoTokens.space4),
                        Text(
                          l10n.homeSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BentoTokens.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BentoGrid(
              padding: const EdgeInsets.fromLTRB(
                BentoTokens.space16,
                0,
                BentoTokens.space16,
                BentoTokens.space96,
              ),
              items: [
                BentoGridItem(
                  columnSpan: 2,
                  minHeight: 80,
                  child: predictedDate.when(
                    skipLoadingOnReload: true,
                    data: (date) => PredictionCardWidget(
                      predictedDate: date,
                      predictionWindowDays: predictionWindowDays,
                      cycles: cycleListState.cycles,
                      averageCycleLength:
                          statistics?.averageCycleLength.round() ??
                          AppConstants.defaultCycleLength,
                      onCurrentCycleTap: latestCycle == null
                          ? null
                          : () => openCycleSheet(context, ref, cycle: latestCycle),
                    ),
                    loading: () => BentoTile(
                      label: l10n.loadingPrediction,
                      isLoading: true,
                      child: const SizedBox.shrink(),
                    ),
                    error: (error, _) => BentoTile(
                      label: l10n.predictionError,
                      isError: true,
                      errorMessage: l10n.somethingWentWrong,
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
                BentoGridItem(
                  columnSpan: 2,
                  minHeight: 360,
                  child: cycleListState.isLoading
                      ? BentoTile(
                          label: l10n.loadingCalendar,
                          isLoading: true,
                          child: const SizedBox.shrink(),
                        )
                      : cycleListState.error != null
                      ? BentoTile(
                          label: l10n.calendarError,
                          isError: true,
                          errorMessage: l10n.somethingWentWrong,
                          child: const SizedBox.shrink(),
                        )
                      : CycleCalendarWidget(
                          cycles: cycleListState.cycles,
                          predictedDates:
                              predictedDatesAsync.valueOrNull ?? const [],
                          onCycleTap: (cycle) =>
                              openCycleSheet(context, ref, cycle: cycle),
                          onDayTap: (date) =>
                              openCycleSheet(context, ref, initialDate: date),
                        ),
                ),
                if (cycleListState.cycles.isNotEmpty)
                  BentoGridItem(
                    columnSpan: 2,
                    minHeight: 0,
                    child: BentoTile(
                      label: l10n.recentCycles,
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cycleListState.cycles.length >
                              AppConstants.recentCyclesLimit)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                BentoTokens.tilePadding,
                                BentoTokens.space12,
                                BentoTokens.space8,
                                0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.recentCycles,
                                    style: Theme.of(context).textTheme.titleSmall
                                        ?.copyWith(
                                          color: BentoTokens.onSurfaceText(
                                            context,
                                          ),
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CycleHistoryScreen(),
                                      ),
                                    ),
                                    child: Text(l10n.seeAll),
                                  ),
                                ],
                              ),
                            ),
                          for (final entry in recentCycles.asMap().entries)
                            CycleListTile(
                              cycle: entry.value,
                              locale: locale,
                              index: entry.key,
                              total: recentCycles.length,
                              onTap: () =>
                                  openCycleSheet(context, ref, cycle: entry.value),
                              onConfirmDelete: () =>
                                  confirmDeleteCycle(context, entry.value),
                              onDeleted: () =>
                                  deleteCycle(context, ref, entry.value),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
