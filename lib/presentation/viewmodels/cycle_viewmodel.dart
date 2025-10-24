import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/cycle.dart';
import '../../domain/entities/cycle_statistics.dart';

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

  Future<void> loadCycles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = await ref.read(getCyclesUseCaseProvider.future);
      final cycles = await useCase();

      state = state.copyWith(cycles: cycles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addCycle(Cycle cycle) async {
    try {
      final useCase = await ref.read(addCycleUseCaseProvider.future);
      await useCase(cycle);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateCycle(Cycle cycle) async {
    try {
      final useCase = await ref.read(updateCycleUseCaseProvider.future);
      await useCase(cycle);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      final useCase = await ref.read(deleteCycleUseCaseProvider.future);
      await useCase(id);
      await loadCycles(); // Reload cycles
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end) async {
    try {
      final useCase = await ref.read(getCyclesInRangeUseCaseProvider.future);
      return await useCase(start, end);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }
}

final cycleListProvider =
    StateNotifierProvider<CycleListNotifier, CycleListState>((ref) {
      return CycleListNotifier(ref);
    });

final cycleStatisticsProvider = FutureProvider<CycleStatistics>((ref) async {
  // Watch cycle list to refresh when cycles change
  ref.watch(cycleListProvider);

  final useCase = await ref.watch(getStatisticsUseCaseProvider.future);
  return await useCase();
});

final predictedNextCycleDateProvider = FutureProvider<DateTime?>((ref) async {
  // Watch cycle list to refresh when cycles change
  ref.watch(cycleListProvider);

  final useCase = await ref.watch(predictNextCycleUseCaseProvider.future);
  return await useCase();
});
