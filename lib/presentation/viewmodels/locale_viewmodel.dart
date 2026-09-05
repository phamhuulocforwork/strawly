import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';
import '../../core/l10n/locale_support.dart';

class LocalePreferenceNotifier extends StateNotifier<LocalePreference> {
  LocalePreferenceNotifier(this.settingsBox)
      : super(LocalePreference.system) {
    _loadPreference();
  }

  final Box settingsBox;

  void _loadPreference() {
    final value = settingsBox.get(AppConstants.localePreferenceKey) as String?;
    state = LocalePreference.fromStorage(value);
  }

  Future<void> setPreference(LocalePreference preference) async {
    state = preference;
    await settingsBox.put(AppConstants.localePreferenceKey, preference.name);
  }
}

final localePreferenceProvider =
    StateNotifierProvider<LocalePreferenceNotifier, LocalePreference>((ref) {
  final settingsBox = ref.watch(settingsBoxProvider).value;

  if (settingsBox == null) {
    return LocalePreferenceNotifier(Hive.box(AppConstants.settingsBoxName));
  }

  return LocalePreferenceNotifier(settingsBox);
});

/// Resolves the effective locale for formatting and lookups.
final effectiveLocaleProvider = Provider<Locale>((ref) {
  final preference = ref.watch(localePreferenceProvider);
  final appLocale = LocaleSupport.materialLocaleFor(preference);
  return LocaleSupport.resolveLocale(appLocale, WidgetsBinding.instance.platformDispatcher.locales);
});
