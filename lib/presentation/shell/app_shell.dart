import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/reminder_service.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../screens/add_cycle_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../viewmodels/reminder_settings_viewmodel.dart';

Future<void> _rescheduleReminders(
  WidgetRef ref,
  AppLocalizations l10n,
  String locale,
) async {
  if (!ref.read(reminderEnabledProvider)) {
    await ReminderService.cancelReminder();
    return;
  }
  final predicted = await ref.read(predictedNextCycleDateProvider.future);
  if (predicted == null) {
    await ReminderService.cancelReminder();
    return;
  }
  final (title, body) = ReminderService.periodReminderPayload(
    l10n,
    predicted,
    locale,
  );
  await ReminderService.scheduleReminder(
    predictedDate: predicted,
    leadDays: ref.read(reminderLeadDaysProvider),
    title: title,
    body: body,
  );
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  void _openAddCycleSheet() {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rescheduleReminders(
        ref,
        AppLocalizations.of(context),
        Localizations.localeOf(context).toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    ref.listen(
      cycleListProvider,
      (_, _) => _rescheduleReminders(ref, l10n, locale),
    );
    ref.listen(
      reminderEnabledProvider,
      (_, _) => _rescheduleReminders(ref, l10n, locale),
    );
    ref.listen(
      reminderLeadDaysProvider,
      (_, _) => _rescheduleReminders(ref, l10n, locale),
    );

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddCycleSheet,
              tooltip: l10n.addCycleTooltip,
              child: const Icon(AppIcons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(AppIcons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.stats),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
