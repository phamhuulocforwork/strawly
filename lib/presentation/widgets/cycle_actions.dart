import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/error_messages.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../screens/add_cycle_screen.dart';
import '../viewmodels/cycle_viewmodel.dart';
import 'app_toast.dart';

Future<bool> confirmDeleteCycle(BuildContext context, Cycle cycle) async {
  final locale = Localizations.localeOf(context).toString();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(l10n.deleteCycleTitle),
        content: Text(
          l10n.deleteCycleConfirm(
            DateTimeUtils.formatDate(cycle.startDate, locale),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteCycleButton),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

Future<void> deleteCycle(
  BuildContext context,
  WidgetRef ref,
  Cycle cycle,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    await ref.read(cycleListProvider.notifier).deleteCycle(cycle.id);
    if (!context.mounted) return;
    AppToast.show(
      context,
      title: l10n.cycleDeleted,
      duration: AppToast.undoDuration,
      action: ShadButton.outline(
        onPressed: () {
          ref.read(cycleListProvider.notifier).addCycle(cycle);
          ShadToaster.of(context).hide();
        },
        child: Text(l10n.undo),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    AppToast.error(
      context,
      title: l10n.deleteFailed(ErrorMessages.friendly(e, l10n)),
    );
  }
}

void openCycleSheet(
  BuildContext context,
  WidgetRef ref, {
  Cycle? cycle,
  DateTime? initialDate,
}) {
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
            initialDate: initialDate,
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
