import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_activities/live_activities.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cycle_live_island_snapshot.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/widgets/cycle_calendar_logic.dart';
import 'cycle_viewmodel.dart';
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

    final enabled = _ref.read(liveIslandEnabledProvider);
    if (!enabled) {
      await endActivity();
      return;
    }

    if (_syncInFlight) return;
    _syncInFlight = true;

    try {
      if (!_initialized) {
        await initialize();
      }

      final cycleState = _ref.read(cycleListProvider);
      final predictedDate = await _ref.read(
        predictedNextCycleDateProvider.future,
      );
      final locale = _ref.read(effectiveLocaleProvider);
      final snapshot = CycleLiveIslandSnapshot.from(
        cycles: cycleState.cycles,
        predictedDate: predictedDate,
      );
      final phaseLabel = _phaseLabel(locale, snapshot.phase);
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

  String _phaseLabel(Locale locale, CyclePhase? phase) {
    final l10n = lookupAppLocalizations(locale);
    return switch (phase) {
      CyclePhase.period => l10n.phasePeriod,
      CyclePhase.follicular => l10n.phaseFollicular,
      CyclePhase.fertile => l10n.phaseFertile,
      CyclePhase.luteal => l10n.phaseLuteal,
      null => '',
    };
  }
}
