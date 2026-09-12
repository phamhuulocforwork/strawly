import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_activities/live_activities.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cycle_live_island_snapshot.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/widgets/cycle_calendar_logic.dart';
import 'cycle_viewmodel.dart';
import 'cycle_widget_sync.dart';
import 'live_island_settings_viewmodel.dart';
import 'locale_viewmodel.dart';

final cycleLiveIslandControllerProvider =
    Provider<CycleLiveIslandController>((ref) {
      return CycleLiveIslandController(ref);
    });

class CycleLiveIslandController {
  CycleLiveIslandController(this._ref);

  final Ref _ref;
  final LiveActivities _liveActivities = LiveActivities();
  bool _initialized = false;
  bool _syncInFlight = false;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  Future<void> initialize() async {
    if (!_isSupportedPlatform || _initialized) return;

    await _liveActivities.init(
      appGroupId: AppConstants.liveIslandAppGroupId,
      urlScheme: AppConstants.liveIslandUrlScheme,
      requestAndroidNotificationPermission: true,
    );
    _initialized = true;
  }

  Future<void> syncFromAppState() async {
    if (!_isSupportedPlatform) return;

    if (_syncInFlight) return;
    _syncInFlight = true;

    try {
      final cycleState = _ref.read(cycleListProvider);
      final predictedDate = await _ref.read(
        predictedNextCycleDateProvider.future,
      );
      final locale = _ref.read(effectiveLocaleProvider);

      await CycleWidgetSync.sync(
        cycles: cycleState.cycles,
        predictedDate: predictedDate,
        locale: locale,
      );

      final enabled = _ref.read(liveIslandEnabledProvider);
      if (!enabled) {
        await endActivity();
        return;
      }

      if (!_initialized) {
        await initialize();
      }

      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycleState.cycles,
        predictedDate: predictedDate,
      );
      final phaseLabel = snapshot.phase?.label(
        lookupAppLocalizations(locale),
      ) ?? '';
      final data = snapshot.toActivityMap(phaseLabel: phaseLabel);

      await _liveActivities.createOrUpdateActivity(
        AppConstants.liveIslandActivityId,
        data,
        activityTag: AppConstants.liveIslandActivityId,
        removeWhenAppIsKilled: true,
        iOSEnableRemoteUpdates: false,
      );
    } catch (error, stack) {
      debugPrint('Live island sync failed: $error\n$stack');
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> endActivity() async {
    if (!_isSupportedPlatform || !_initialized) return;

    try {
      await _liveActivities.endActivity(AppConstants.liveIslandActivityId);
    } catch (_) {
      // Ignore end failures when activity was never created.
    }
  }
}
