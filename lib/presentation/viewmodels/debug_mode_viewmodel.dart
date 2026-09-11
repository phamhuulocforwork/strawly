import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime-only debug flag. Toggled by tapping the app version 5 times
/// in Settings. Never persisted — a restart always leaves debug mode off.
class DebugModeNotifier extends StateNotifier<bool> {
  DebugModeNotifier() : super(false);

  final List<DateTime> _versionTaps = [];

  /// Records a tap on the version row. Returns true when this tap
  /// just enabled debug mode (5 taps within 2 seconds).
  bool tapVersion() {
    if (state) return false;
    final now = DateTime.now();
    _versionTaps.removeWhere(
      (tap) => now.difference(tap) > const Duration(seconds: 2),
    );
    _versionTaps.add(now);
    if (_versionTaps.length >= 5) {
      _versionTaps.clear();
      state = true;
      return true;
    }
    return false;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

final debugModeProvider =
    StateNotifierProvider<DebugModeNotifier, bool>((ref) {
      return DebugModeNotifier();
    });
