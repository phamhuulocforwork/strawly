import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/cycle.dart';
import '../../domain/entities/cycle_statistics.dart';
import 'typical_cycle_length_viewmodel.dart';

class CycleListState {
  final List<Cycle> cycles;
  final bool isLoading;
  final String? error;

  const CycleListState({
    this.cycles = const [],
    this.isLoading = false,
    this.error,
  });

  CycleListState copyWith({
    List<Cycle>? cycles,
    bool? isLoading,
    String? error,
  }) {
    return CycleListState(
      cycles: cycles ?? this.cycles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CycleListNotifier extends StateNotifier<CycleListState> {
  final Ref ref;

  CycleListNotifier(this.ref) : super(const CycleListState()) {
    loadCycles();
  }

  String _logError(Object error) {
    debugPrint('Strawly error: $error');
    return error.toString();
  }

  Future<void> loadCycles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = await ref.read(getCyclesUseCaseProvider.future);
      final cycles = await useCase();

      state = state.copyWith(cycles: cycles, isLoading: false);
      ref.read(cycleDataRevisionProvider.notifier).state++;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _logError(e));
    }
  }

  Future<void> addCycle(Cycle cycle) async {
    try {
      final useCase = await ref.read(addCycleUseCaseProvider.future);
      await useCase(cycle);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: _logError(e));
      rethrow;
    }
  }

  Future<void> updateCycle(Cycle cycle) async {
    try {
      final useCase = await ref.read(updateCycleUseCaseProvider.future);
      await useCase(cycle);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: _logError(e));
      rethrow;
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      final useCase = await ref.read(deleteCycleUseCaseProvider.future);
      await useCase(id);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: _logError(e));
      rethrow;
    }
  }

  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end) async {
    try {
      final useCase = await ref.read(getCyclesInRangeUseCaseProvider.future);
      return await useCase(start, end);
    } catch (e) {
      state = state.copyWith(error: _logError(e));
      return [];
    }
  }
}

final cycleListProvider =
    StateNotifierProvider<CycleListNotifier, CycleListState>((ref) {
      return CycleListNotifier(ref);
    });

/// Bumped after each successful [CycleListNotifier.loadCycles].
/// Derived providers watch this instead of [cycleListProvider] to avoid
/// Riverpod circular dependencies when refreshing from the list notifier.
final cycleDataRevisionProvider = StateProvider<int>((ref) => 0);

final cycleStatisticsProvider = FutureProvider<CycleStatistics>((ref) async {
  ref.watch(cycleDataRevisionProvider);
  ref.watch(typicalCycleLengthProvider);

  final useCase = await ref.watch(getStatisticsUseCaseProvider.future);
  return await useCase();
});

final predictedCycleDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  ref.watch(cycleDataRevisionProvider);
  ref.watch(typicalCycleLengthProvider);

  final useCase = await ref.watch(predictUpcomingCycleDatesUseCaseProvider.future);
  return useCase();
});

final predictedNextCycleDateProvider = FutureProvider<DateTime?>((ref) async {
  final dates = await ref.watch(predictedCycleDatesProvider.future);
  return dates.isEmpty ? null : dates.first;
});
