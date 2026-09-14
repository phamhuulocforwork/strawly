import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../widgets/cycle_actions.dart';
import '../widgets/cycle_list_tile.dart';

class CycleHistoryScreen extends ConsumerWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final state = ref.watch(cycleListProvider);
    final cycles = state.cycles;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cycleHistory)),
      body: state.isLoading && cycles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.all(BentoTokens.space16),
              decoration: BoxDecoration(
                color: BentoTokens.tileBackground(context),
                borderRadius: BentoTokens.tileRadius,
                border: Border.all(color: BentoTokens.tileBorder(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: cycles.length,
                itemBuilder: (context, index) {
                  final cycle = cycles[index];
                  return CycleListTile(
                    cycle: cycle,
                    locale: locale,
                    index: index,
                    total: cycles.length,
                    onTap: () => openCycleSheet(context, ref, cycle: cycle),
                    onConfirmDelete: () => confirmDeleteCycle(context, cycle),
                    onDeleted: () => deleteCycle(context, ref, cycle),
                  );
                },
              ),
            ),
    );
  }
}
