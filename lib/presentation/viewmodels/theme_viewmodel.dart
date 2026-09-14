import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box? settingsBox;

  ThemeModeNotifier(this.settingsBox) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const Map<String, ThemeMode> _names = {
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
  };

  void _loadThemeMode() {
    final box = settingsBox;
    if (box == null) return;

    final saved = box.get(AppConstants.themeModeKey) as String?;
    if (saved != null) {
      state = _names[saved] ?? ThemeMode.system;
      return;
    }

    // Migrate the legacy dark-mode boolean if it was set before.
    if (box.containsKey(AppConstants.isDarkModeKey)) {
      final isDark = box.get(AppConstants.isDarkModeKey) as bool;
      setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
      return;
    }

    state = ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await settingsBox?.put(
      AppConstants.themeModeKey,
      _names.entries.firstWhere((entry) => entry.value == mode).key,
    );
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(resolvedSettingsBox(ref));
});
