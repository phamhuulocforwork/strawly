import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box settingsBox;

  ThemeModeNotifier(this.settingsBox) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final isDark =
        settingsBox.get(AppConstants.isDarkModeKey, defaultValue: false)
            as bool;

    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await settingsBox.put(AppConstants.isDarkModeKey, mode == ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final settingsBox = ref.watch(settingsBoxProvider).value;

  if (settingsBox == null) {
    return ThemeModeNotifier(Hive.box(AppConstants.settingsBoxName));
  }

  return ThemeModeNotifier(settingsBox);
});
