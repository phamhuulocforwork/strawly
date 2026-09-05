import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/bento_grid.dart';
import '../widgets/bento_tile.dart';
import '../widgets/cycle_calendar_widget.dart';
import '../widgets/prediction_card_widget.dart';
import 'add_cycle_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openEditCycle(BuildContext context, WidgetRef ref, Cycle cycle) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return AddCycleScreen(
              cycleToEdit: cycle,
              scrollController: scrollController,
              embeddedInSheet: true,
              onSaved: () {
                ref.read(cycleListProvider.notifier).loadCycles();
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final cycleListState = ref.watch(cycleListProvider);
    final predictedDate = ref.watch(predictedNextCycleDateProvider);
    final statisticsAsync = ref.watch(cycleStatisticsProvider);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: BentoTokens.space4),
                  Text(
                    l10n.homeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BentoTokens.mutedText(context),
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
                    data: (date) => PredictionCardWidget(
                      predictedDate: date,
                      cycles: cycleListState.cycles,
                      averageCycleLength: statisticsAsync.valueOrNull
                              ?.averageCycleLength
                              .round() ??
                          AppConstants.defaultCycleLength,
                    ),
                    loading: () => BentoTile(
                      label: l10n.loadingPrediction,
                      isLoading: true,
                      child: const SizedBox.shrink(),
                    ),
                    error: (error, _) => BentoTile(
                      label: l10n.predictionError,
                      isError: true,
                      errorMessage: error.toString(),
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
                          errorMessage: cycleListState.error,
                          child: const SizedBox.shrink(),
                        )
                      : CycleCalendarWidget(
                          cycles: cycleListState.cycles,
                          predictedDate: predictedDate.value,
                        ),
                ),
                if (cycleListState.cycles.isNotEmpty)
                  BentoGridItem(
                    columnSpan: 2,
                    minHeight: 0,
                    child: BentoTile(
                      label: l10n.recentCycles,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...cycleListState.cycles.take(5).map((cycle) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BentoTokens.tileRadius,
                                onTap: () =>
                                    _openEditCycle(context, ref, cycle),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: BentoTokens.space8,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: BentoTokens.primary
                                            .withValues(alpha: 0.35),
                                        child: Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: BentoTokens.onSurfaceText(
                                            context,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: BentoTokens.space12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateTimeUtils.formatDate(
                                                cycle.startDate,
                                                locale,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              cycle.isComplete
                                                  ? l10n.lengthDays(
                                                      cycle.cycleLength!,
                                                    )
                                                  : l10n.ongoing,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: BentoTokens.mutedText(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: BentoTokens.mutedText(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
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
