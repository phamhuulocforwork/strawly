import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/core/di/providers.dart';
import 'package:strawly/core/utils/date_time_utils.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/domain/repositories/cycle_repository.dart';
import 'package:strawly/presentation/viewmodels/cycle_viewmodel.dart';
import 'package:strawly/presentation/viewmodels/typical_cycle_length_viewmodel.dart';

class _InMemoryCycleRepository implements CycleRepository {
  final Map<String, Cycle> _cycles = {};

  @override
  Future<void> addCycle(Cycle cycle) async {
    _cycles[cycle.id] = cycle;
  }

  @override
  Future<void> deleteCycle(String id) async {
    _cycles.remove(id);
  }

  @override
  Future<void> deleteAllCycles() async {
    _cycles.clear();
  }

  @override
  Future<List<Cycle>> getAllCycles() async {
    final list = _cycles.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  @override
  Future<Cycle?> getCycleById(String id) async => _cycles[id];

  @override
  Future<List<Cycle>> getCompleteCycles() async {
    return (await getAllCycles()).where((c) => c.isComplete).toList();
  }

  @override
  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end) async {
    return (await getAllCycles()).where((c) {
      return c.startDate.isAfter(start) && c.startDate.isBefore(end);
    }).toList();
  }

  @override
  Future<Cycle?> getLatestCycle() async {
    final all = await getAllCycles();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<List<Cycle>> getRecentCycles({int limit = 6}) async {
    final all = await getAllCycles();
    return all.take(limit).toList();
  }

  @override
  Future<int> getTotalCount() async => _cycles.length;

  @override
  Future<bool> hasCycleOnDate(DateTime date) async {
    final target = DateTimeUtils.dateOnly(date);
    return _cycles.values.any(
      (c) => DateTimeUtils.dateOnly(c.startDate) == target,
    );
  }

  @override
  Future<void> updateCycle(Cycle cycle) async {
    if (!_cycles.containsKey(cycle.id)) {
      throw Exception('Cycle not found');
    }
    _cycles[cycle.id] = cycle;
  }

  @override
  Future<List<Map<String, dynamic>>> exportToJson() async => [];

  @override
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {}
}

Future<void> _waitForCycleList(ProviderContainer container) async {
  for (var i = 0; i < 50; i++) {
    final state = container.read(cycleListProvider);
    if (!state.isLoading) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('cycleListProvider did not finish loading');
}

ProviderContainer _containerWithRepo(_InMemoryCycleRepository repo) {
  return ProviderContainer(
    overrides: [
      cycleRepositoryProvider.overrideWith((ref) async => repo),
      typicalCycleLengthProvider.overrideWith(
        (ref) => TypicalCycleLengthNotifier(null),
      ),
    ],
  );
}

void main() {
  test('deleting latest cycle refreshes prediction and statistics', () async {
    final repo = _InMemoryCycleRepository();
    final container = _containerWithRepo(repo);
    addTearDown(container.dispose);

    await _waitForCycleList(container);

    final older = Cycle(
      id: 'older',
      startDate: DateTime(2026, 1, 1),
      cycleLength: 28,
      periodDuration: 5,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final latest = Cycle(
      id: 'latest',
      startDate: DateTime(2026, 2, 1),
      periodDuration: 5,
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

    await container.read(cycleListProvider.notifier).addCycle(older);
    await container.read(cycleListProvider.notifier).addCycle(latest);
    await _waitForCycleList(container);

    expect(container.read(cycleListProvider).cycles, hasLength(2));

    final statsBefore = await container.read(cycleStatisticsProvider.future);
    final predictedBefore = await container.read(
      predictedNextCycleDateProvider.future,
    );

    expect(statsBefore.totalCycles, 2);
    expect(predictedBefore, DateTime(2026, 3, 1));

    await container.read(cycleListProvider.notifier).deleteCycle('latest');
    await _waitForCycleList(container);

    expect(container.read(cycleListProvider).cycles, hasLength(1));

    final statsAfter = await container.read(cycleStatisticsProvider.future);
    final predictedAfter = await container.read(
      predictedNextCycleDateProvider.future,
    );

    expect(statsAfter.totalCycles, 1);
    expect(predictedAfter, isNot(predictedBefore));
    expect(predictedAfter, DateTime(2026, 1, 29));
  });
}
