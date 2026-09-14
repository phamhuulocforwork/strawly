import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/l10n/locale_support.dart';
import '../../core/services/reminder_service.dart';
import '../../core/utils/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../viewmodels/debug_mode_viewmodel.dart';
import '../viewmodels/live_island_settings_viewmodel.dart';
import '../viewmodels/reminder_settings_viewmodel.dart';
import '../viewmodels/locale_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/typical_cycle_length_viewmodel.dart';
import '../widgets/app_toast.dart';
import '../widgets/bento_tile.dart';
import '../widgets/typical_cycle_length_picker_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final localePreference = ref.watch(localePreferenceProvider);
    final liveIslandEnabled = ref.watch(liveIslandEnabledProvider);
    final reminderEnabled = ref.watch(reminderEnabledProvider);
    final reminderLeadDays = ref.watch(reminderLeadDaysProvider);
    final typicalCycleLength = ref.watch(typicalCycleLengthProvider);
    final debugMode = ref.watch(debugModeProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(BentoTokens.space16),
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              l10n.settings,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: BentoTokens.space16),
          _buildSectionHeader(context, l10n.appearance),
          BentoTile(
            label: l10n.themeMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.lightMode,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    const SizedBox(width: BentoTokens.space12),
                    Text(l10n.themeMode),
                  ],
                ),
                const SizedBox(height: BentoTokens.space12),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: BentoTokens.space12),
          BentoTile(
            label: l10n.language,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.language,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.language),
                    subtitle: Text(l10n.languageSubtitle),
                  ),
                  RadioListTile<LocalePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.languageSystem),
                    value: LocalePreference.system,
                    groupValue: localePreference,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(localePreferenceProvider.notifier)
                            .setPreference(value);
                      }
                    },
                  ),
                  RadioListTile<LocalePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.languageEnglish),
                    value: LocalePreference.en,
                    groupValue: localePreference,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(localePreferenceProvider.notifier)
                            .setPreference(value);
                      }
                    },
                  ),
                  RadioListTile<LocalePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.languageVietnamese),
                    value: LocalePreference.vi,
                    groupValue: localePreference,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(localePreferenceProvider.notifier)
                            .setPreference(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: BentoTokens.space12),
          BentoTile(
            label: l10n.liveIsland,
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  AppIcons.home,
                  color: BentoTokens.onSurfaceText(context),
                ),
                title: Text(l10n.liveIsland),
                value: liveIslandEnabled,
                onChanged: (value) {
                  ref
                      .read(liveIslandEnabledProvider.notifier)
                      .setEnabled(value);
                },
              ),
            ),
          ),
          const SizedBox(height: BentoTokens.space12),
          BentoTile(
            label: l10n.reminders,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      AppIcons.bell,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.reminders),
                    subtitle: Text(l10n.remindersSubtitle),
                    value: reminderEnabled,
                    onChanged: (value) =>
                        _toggleReminders(context, ref, l10n, value),
                  ),
                  if (reminderEnabled) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: BentoTokens.space12,
                      ),
                      child: SegmentedButton<int>(
                        segments: [
                          for (final days in const [0, 1, 2])
                            ButtonSegment(
                              value: days,
                              label: Text(l10n.remindLeadDays(days)),
                            ),
                        ],
                        selected: {reminderLeadDays},
                        onSelectionChanged: (selection) {
                          ref
                              .read(reminderLeadDaysProvider.notifier)
                              .setLeadDays(selection.first);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: BentoTokens.space12),
          BentoTile(
            label: l10n.cycleTracking,
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  AppIcons.calendar,
                  color: BentoTokens.onSurfaceText(context),
                ),
                title: Text(l10n.typicalCycleLength),
                subtitle: Text(
                  typicalCycleLength == null
                      ? l10n.typicalCycleLengthDefault(
                          AppConstants.defaultCycleLength,
                        )
                      : l10n.typicalCycleLengthDays(typicalCycleLength),
                ),
                trailing: const Icon(AppIcons.chevronRight),
                onTap: () => _pickTypicalCycleLength(
                  context,
                  ref,
                  l10n,
                  typicalCycleLength,
                ),
              ),
            ),
          ),
          const SizedBox(height: BentoTokens.space24),
          _buildSectionHeader(context, l10n.dataManagement),
          BentoTile(
            label: l10n.dataManagement,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.upload,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.exportData),
                    subtitle: Text(l10n.exportDataSubtitle),
                    trailing: const Icon(AppIcons.chevronRight),
                    onTap: () => _exportData(context, ref, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.download,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.importData),
                    subtitle: Text(l10n.importDataSubtitle),
                    trailing: const Icon(AppIcons.chevronRight),
                    onTap: () => _importData(context, ref, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      AppIcons.delete,
                      color: BentoTokens.danger,
                    ),
                    title: Text(
                      l10n.deleteAllData,
                      style: const TextStyle(color: BentoTokens.danger),
                    ),
                    subtitle: Text(l10n.deleteAllDataSubtitle),
                    trailing: const Icon(AppIcons.chevronRight),
                    onTap: () => _deleteAllData(context, ref, l10n),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: BentoTokens.space24),
          _buildSectionHeader(context, l10n.about),
          BentoTile(
            label: l10n.aboutStrawly,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final justEnabled = ref
                          .read(debugModeProvider.notifier)
                          .tapVersion();
                      if (justEnabled && context.mounted) {
                        AppToast.success(context, title: l10n.debugEnabled);
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.info,
                        color: BentoTokens.onSurfaceText(context),
                      ),
                      title: Text(l10n.version),
                      subtitle: Text(l10n.versionNumber),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.privacy,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.privacy),
                    subtitle: Text(l10n.privacySubtitle),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.lock,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.security),
                    subtitle: Text(l10n.securitySubtitle),
                  ),
                ],
              ),
            ),
          ),
          if (debugMode) ...[
            const SizedBox(height: BentoTokens.space24),
            _buildSectionHeader(context, l10n.debug),
            BentoTile(
              label: l10n.debug,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.bell,
                        color: BentoTokens.onSurfaceText(context),
                      ),
                      title: Text(l10n.debugPeriodReminder),
                      trailing: const Icon(AppIcons.chevronRight),
                      onTap: () =>
                          _sendPeriodReminderTest(context, ref, l10n),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.info,
                        color: BentoTokens.onSurfaceText(context),
                      ),
                      title: Text(l10n.debugPrintCycles),
                      trailing: const Icon(AppIcons.chevronRight),
                      onTap: () => _printCycles(ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.bellOff,
                        color: BentoTokens.onSurfaceText(context),
                      ),
                      title: Text(l10n.debugCancelReminder),
                      trailing: const Icon(AppIcons.chevronRight),
                      onTap: () => _cancelReminder(context, l10n),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        AppIcons.logOut,
                        color: BentoTokens.danger,
                      ),
                      title: Text(
                        l10n.debugExit,
                        style: const TextStyle(color: BentoTokens.danger),
                      ),
                      onTap: () => _exitDebugMode(context, ref, l10n),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: BentoTokens.space32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: BentoTokens.space4,
        bottom: BentoTokens.space8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: BentoTokens.mutedText(context),
        ),
      ),
    );
  }

  Future<void> _pickTypicalCycleLength(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int? current,
  ) async {
    final outcome = await showTypicalCycleLengthPickerDialog(
      context,
      current: current,
    );

    if (outcome == null || !context.mounted) return;
    if (outcome.days == current) return;

    await ref.read(typicalCycleLengthProvider.notifier).setTypicalLength(
      outcome.days,
    );
    ref.read(cycleDataRevisionProvider.notifier).state++;
  }

  Future<void> _toggleReminders(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool value,
  ) async {
    var effective = value;
    if (value) {
      final granted = await ReminderService.requestPermission();
      if (!context.mounted) return;
      if (!granted) {
        effective = false;
        AppToast.error(context, title: l10n.reminderPermissionDenied);
      }
    }
    await ref.read(reminderEnabledProvider.notifier).setEnabled(effective);
  }

  Future<void> _sendPeriodReminderTest(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final granted = await ReminderService.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      AppToast.error(context, title: l10n.reminderPermissionDenied);
      return;
    }
    final predicted = await ref.read(predictedNextCycleDateProvider.future);
    if (!context.mounted) return;
    final (title, body) = ReminderService.periodReminderPayload(
      l10n,
      predicted ?? DateTime.now(),
      Localizations.localeOf(context).toString(),
    );
    await ReminderService.showNotification(title: title, body: body);
  }

  void _printCycles(WidgetRef ref) {
    final cycles = ref.read(cycleListProvider).cycles;
    debugPrint('Strawly debug: ${cycles.length} cycles');
    for (final cycle in cycles) {
      debugPrint(
        '  ${cycle.id} start=${cycle.startDate.toIso8601String()} '
        'length=${cycle.cycleLength} period=${cycle.periodDuration}',
      );
    }
  }

  Future<void> _cancelReminder(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await ReminderService.cancelReminder();
    if (!context.mounted) return;
    AppToast.success(context, title: l10n.debugReminderCancelled);
  }

  void _exitDebugMode(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    ref.read(debugModeProvider.notifier).setEnabled(false);
    AppToast.success(context, title: l10n.debugDisabled);
  }

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final repository = await ref.read(cycleRepositoryProvider.future);
      final data = await repository.exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/strawly_backup_$stamp.json');
      await file.writeAsString(jsonString);

      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)], subject: 'Strawly backup');
      if (!context.mounted) return;

      AppToast.success(context, title: l10n.dataExported);
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: l10n.exportFailed(ErrorMessages.friendly(e, l10n)),
        );
      }
    }
  }

  Future<void> _importData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(dialogL10n.importDataTitle),
          content: Text(dialogL10n.importDataConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(dialogL10n.cancel),
            ),
            ShadButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(dialogL10n.continueButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final picked = result?.files.single;
    if (picked == null) return;

    try {
      final contents = picked.bytes != null
          ? utf8.decode(picked.bytes!)
          : await File(picked.path!).readAsString();
      final List<dynamic> decoded = jsonDecode(contents);
      final List<Map<String, dynamic>> cycles = decoded
          .cast<Map<String, dynamic>>();

      final repository = await ref.read(cycleRepositoryProvider.future);
      await repository.importFromJson(cycles);
      ref.invalidate(cycleListProvider);

      if (context.mounted) {
        AppToast.success(
          context,
          title: l10n.importedCycles(cycles.length),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: l10n.importFailed(ErrorMessages.friendly(e, l10n)),
        );
      }
    }
  }

  Future<void> _deleteAllData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(dialogL10n.deleteAllDataTitle),
          content: Text(dialogL10n.deleteAllDataConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(dialogL10n.cancel),
            ),
            ShadButton.destructive(
              onPressed: () => Navigator.pop(context, true),
              child: Text(dialogL10n.deleteAllButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final repository = await ref.read(cycleRepositoryProvider.future);
      await repository.deleteAllCycles();
      ref.invalidate(cycleListProvider);

      if (context.mounted) {
        AppToast.success(context, title: l10n.allDataDeleted);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
          context,
          title: l10n.deleteFailed(ErrorMessages.friendly(e, l10n)),
        );
      }
    }
  }
}
