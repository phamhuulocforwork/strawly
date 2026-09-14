import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';

class TypicalCycleLengthNotifier extends StateNotifier<int?> {
  TypicalCycleLengthNotifier(this.settingsBox) : super(null) {
    _loadPreference();
  }

  final Box? settingsBox;

  void _loadPreference() {
    final box = settingsBox;
    if (box == null) return;

    final value = box.get(AppConstants.typicalCycleLengthKey);
    if (value is int &&
        value >= AppConstants.minCycleLength &&
        value <= AppConstants.maxCycleLength) {
      state = value;
    }
  }

  Future<void> setTypicalLength(int? days) async {
    state = days;
    if (days == null) {
      await settingsBox?.delete(AppConstants.typicalCycleLengthKey);
    } else {
      await settingsBox?.put(AppConstants.typicalCycleLengthKey, days);
    }
  }
}

final typicalCycleLengthProvider =
    StateNotifierProvider<TypicalCycleLengthNotifier, int?>((ref) {
      return TypicalCycleLengthNotifier(resolvedSettingsBox(ref));
    });
