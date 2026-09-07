import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/di/providers.dart';
import '../../core/l10n/locale_support.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../viewmodels/live_island_settings_viewmodel.dart';
import '../viewmodels/locale_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../widgets/bento_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final localePreference = ref.watch(localePreferenceProvider);
    final liveIslandEnabled = ref.watch(liveIslandEnabledProvider);

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
            label: l10n.darkMode,
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? AppIcons.darkMode
                      : AppIcons.lightMode,
                  color: BentoTokens.onSurfaceText(context),
                ),
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.darkModeSubtitle),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
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
                subtitle: Text(l10n.liveIslandSubtitle),
                value: liveIslandEnabled,
                onChanged: (value) {
                  ref
                      .read(liveIslandEnabledProvider.notifier)
                      .setEnabled(value);
                },
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AppIcons.info,
                      color: BentoTokens.onSurfaceText(context),
                    ),
                    title: Text(l10n.version),
                    subtitle: Text(l10n.versionNumber),
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
          const SizedBox(height: BentoTokens.space24),
          BentoTile(
            label: l10n.strawlyBranding,
            variant: BentoTileVariant.primary,
            child: Column(
              children: [
                Icon(
                  AppIcons.heart,
                  color: BentoTokens.onSurfaceText(context),
                  size: 40,
                ),
                const SizedBox(height: BentoTokens.space8),
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: BentoTokens.space4),
                Text(
                  l10n.brandingSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BentoTokens.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
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

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final repository = await ref.read(cycleRepositoryProvider.future);
      final data = await repository.exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      if (!context.mounted) return;
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dataExported),
          backgroundColor: BentoTokens.success,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString())),
            backgroundColor: BentoTokens.danger,
          ),
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

    final controller = TextEditingController();
    final jsonData = await showDialog<String>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(dialogL10n.pasteBackupTitle),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: dialogL10n.pasteBackupHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogL10n.cancel),
            ),
            ShadButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(dialogL10n.importButton),
            ),
          ],
        );
      },
    );

    if (jsonData == null || jsonData.isEmpty) return;

    try {
      final List<dynamic> decoded = jsonDecode(jsonData);
      final List<Map<String, dynamic>> cycles = decoded
          .cast<Map<String, dynamic>>();

      final repository = await ref.read(cycleRepositoryProvider.future);
      await repository.importFromJson(cycles);
      ref.invalidate(cycleListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importedCycles(cycles.length)),
            backgroundColor: BentoTokens.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importFailed(e.toString())),
            backgroundColor: BentoTokens.danger,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allDataDeleted),
            backgroundColor: BentoTokens.warning,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteFailed(e.toString())),
            backgroundColor: BentoTokens.danger,
          ),
        );
      }
    }
  }
}
