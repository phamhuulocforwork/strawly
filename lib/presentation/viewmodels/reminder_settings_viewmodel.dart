import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';

class ReminderEnabledNotifier extends StateNotifier<bool> {
  ReminderEnabledNotifier(this.settingsBox) : super(false) {
    _loadPreference();
  }

  final Box? settingsBox;

  void _loadPreference() {
    final box = settingsBox;
    if (box == null) return;

    final value = box.get(
      AppConstants.reminderEnabledKey,
      defaultValue: false,
    );
    state = value is bool ? value : false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await settingsBox?.put(AppConstants.reminderEnabledKey, enabled);
  }
}

class ReminderLeadDaysNotifier extends StateNotifier<int> {
  ReminderLeadDaysNotifier(this.settingsBox) : super(1) {
    _loadPreference();
  }

  final Box? settingsBox;

  void _loadPreference() {
    final box = settingsBox;
    if (box == null) return;

    final value = box.get(
      AppConstants.reminderLeadDaysKey,
      defaultValue: 1,
    );
    state = value is int ? value : 1;
  }

  Future<void> setLeadDays(int days) async {
    state = days;
    await settingsBox?.put(AppConstants.reminderLeadDaysKey, days);
  }
}

final reminderEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
      return ReminderEnabledNotifier(resolvedSettingsBox(ref));
    });

final reminderLeadDaysProvider =
    StateNotifierProvider<ReminderLeadDaysNotifier, int>((ref) {
      return ReminderLeadDaysNotifier(resolvedSettingsBox(ref));
    });
