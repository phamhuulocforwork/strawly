import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/cycle_live_island_controller.dart';
import '../viewmodels/cycle_viewmodel.dart';
import '../viewmodels/live_island_settings_viewmodel.dart';
import '../viewmodels/locale_viewmodel.dart';

/// Keeps the OS island in sync while the Strawly process is alive.
class LiveIslandLifecycleHost extends ConsumerStatefulWidget {
  const LiveIslandLifecycleHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveIslandLifecycleHost> createState() =>
      _LiveIslandLifecycleHostState();
}

class _LiveIslandLifecycleHostState extends ConsumerState<LiveIslandLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncIsland();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncIsland();
    } else if (state == AppLifecycleState.detached) {
      ref.read(cycleLiveIslandControllerProvider).endActivity();
    }
  }

  void _syncIsland() {
    ref.read(cycleLiveIslandControllerProvider).syncFromAppState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cycleListProvider, (_, _) => _syncIsland());
    ref.listen(predictedNextCycleDateProvider, (_, _) => _syncIsland());
    ref.listen(liveIslandEnabledProvider, (previous, next) {
      if (next) {
        _syncIsland();
      } else {
        ref.read(cycleLiveIslandControllerProvider).endActivity();
      }
    });
    ref.listen(localePreferenceProvider, (_, _) => _syncIsland());

    return widget.child;
  }
}
