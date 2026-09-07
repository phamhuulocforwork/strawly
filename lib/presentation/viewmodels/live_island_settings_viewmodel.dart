import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/hive_service.dart';

class LiveIslandSettingsNotifier extends StateNotifier<bool> {
  LiveIslandSettingsNotifier(this.settingsBox) : super(true) {
    _loadPreference();
  }

  final Box? settingsBox;

  void _loadPreference() {
    final box = settingsBox;
    if (box == null) return;

    final value = box.get(
      AppConstants.liveIslandEnabledKey,
      defaultValue: true,
    );
    state = value is bool ? value : true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await settingsBox?.put(AppConstants.liveIslandEnabledKey, enabled);
  }
}

final liveIslandEnabledProvider =
    StateNotifierProvider<LiveIslandSettingsNotifier, bool>((ref) {
      return LiveIslandSettingsNotifier(resolvedSettingsBox(ref));
    });
