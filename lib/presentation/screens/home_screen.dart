import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/bento_grid.dart';
import '../widgets/bento_tile.dart';
import '../widgets/cycle_calendar_logic.dart';
import '../widgets/cycle_calendar_widget.dart';
import '../widgets/prediction_card_widget.dart';
import 'add_cycle_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  BorderRadius _recentCycleRowRadius(int index, int total) {
    const radius = Radius.circular(BentoTokens.radiusMd);
    if (total == 1) {
      return const BorderRadius.all(radius);
    }
    if (index == 0) {
      return const BorderRadius.vertical(top: radius);
    }
    if (index == total - 1) {
      return const BorderRadius.vertical(bottom: radius);
    }
    return BorderRadius.zero;
  }

  Future<bool> _confirmDeleteCycle(BuildContext context, Cycle cycle) async {
    final locale = Localizations.localeOf(context).toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(dialogL10n.deleteCycleTitle),
          content: Text(
            dialogL10n.deleteCycleConfirm(
              DateTimeUtils.formatDate(cycle.startDate, locale),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(dialogL10n.cancel),
            ),
            ShadButton.destructive(
              onPressed: () => Navigator.pop(context, true),
              child: Text(dialogL10n.deleteCycleButton),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _deleteCycle(
    BuildContext context,
    WidgetRef ref,
    Cycle cycle,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(cycleListProvider.notifier).deleteCycle(cycle.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cycleDeleted),
          backgroundColor: BentoTokens.warning,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deleteFailed(e.toString())),
          backgroundColor: BentoTokens.danger,
        ),
      );
    }
  }

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
                      averageCycleLength:
                          statisticsAsync.valueOrNull?.averageCycleLength
                              .round() ??
                          AppConstants.defaultCycleLength,
                      onCurrentCycleTap: latestCycle == null
                          ? null
                          : () => _openEditCycle(context, ref, latestCycle),
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
                          onCycleTap: (cycle) =>
                              _openEditCycle(context, ref, cycle),
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
                          for (final entry in recentCycles.asMap().entries)
                            Dismissible(
                              key: ValueKey(entry.value.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) =>
                                  _confirmDeleteCycle(context, entry.value),
                              onDismissed: (_) =>
                                  _deleteCycle(context, ref, entry.value),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BentoTokens.tilePadding,
                                ),
                                color: BentoTokens.danger,
                                child: const Icon(
                                  AppIcons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: _recentCycleRowRadius(
                                    entry.key,
                                    recentCycles.length,
                                  ),
                                  onTap: () =>
                                      _openEditCycle(context, ref, entry.value),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: BentoTokens.tilePadding,
                                      vertical: BentoTokens.space12,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: BentoTokens.primary
                                              .withValues(alpha: 0.35),
                                          child: Icon(
                                            AppIcons.calendar,
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
                                                  entry.value.startDate,
                                                  locale,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                entry.value.isComplete
                                                    ? l10n.lengthDays(
                                                        entry
                                                            .value
                                                            .cycleLength!,
                                                      )
                                                    : l10n.ongoing,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          BentoTokens.mutedText(
                                                            context,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          AppIcons.chevronRight,
                                          size: 20,
                                          color: BentoTokens.mutedText(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
