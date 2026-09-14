import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/core/constants/app_constants.dart';
import 'package:strawly/domain/entities/cycle.dart';
import 'package:strawly/domain/repositories/cycle_repository.dart';
import 'package:strawly/domain/usecases/cycle_length_stats.dart';
import 'package:strawly/domain/usecases/cycle_usecases.dart';
import 'package:strawly/domain/usecases/prediction_usecases.dart';

class _MemoryRepo implements CycleRepository {
  final Map<String, Cycle> _cycles = {};

  void seed(Cycle cycle) => _cycles[cycle.id] = cycle;

  @override
  Future<void> addCycle(Cycle cycle) async {
    _cycles[cycle.id] = cycle;
  }

  @override
  Future<void> deleteCycle(String id) async => _cycles.remove(id);

  @override
  Future<void> deleteAllCycles() async => _cycles.clear();

  @override
  Future<List<Cycle>> getAllCycles() async {
    final list = _cycles.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  @override
  Future<Cycle?> getCycleById(String id) async => _cycles[id];

  @override
  Future<List<Cycle>> getCompleteCycles() async =>
      (await getAllCycles()).where((c) => c.isComplete).toList();

  @override
  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end) async =>
      [];

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
  Future<bool> hasCycleOnDate(DateTime date) async => false;

  @override
  Future<void> updateCycle(Cycle cycle) async {
    _cycles[cycle.id] = cycle;
  }

  @override
  Future<List<Map<String, dynamic>>> exportToJson() async => [];

  @override
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {}
}

void main() {
  group('CycleLengthStats', () {
    test('median odd count', () {
      expect(CycleLengthStats.median([28, 30, 26]), 28);
    });

    test('median even count', () {
      expect(CycleLengthStats.median([28, 30]), 29);
    });

    test('filters implausible lengths', () {
      expect(
        CycleLengthStats.plausibleLengthsFromComplete([28, 90, 30, 10]),
        [28, 30],
      );
    });
  });

  group('CalculateTypicalCycleLengthUseCase', () {
    test('uses median and ignores outliers', () async {
      final repo = _MemoryRepo()
        ..seed(
          Cycle(
            id: '1',
            startDate: DateTime(2026, 1, 1),
            cycleLength: 28,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        )
        ..seed(
          Cycle(
            id: '2',
            startDate: DateTime(2026, 2, 1),
            cycleLength: 90,
            createdAt: DateTime(2026, 2, 1),
            updatedAt: DateTime(2026, 2, 1),
          ),
        )
        ..seed(
          Cycle(
            id: '3',
            startDate: DateTime(2026, 3, 1),
            cycleLength: 30,
            createdAt: DateTime(2026, 3, 1),
            updatedAt: DateTime(2026, 3, 1),
          ),
        );

      final useCase = CalculateTypicalCycleLengthUseCase(
        repo,
        fallbackCycleLength: () => 28,
      );

      expect(await useCase(), 29);
    });

    test('falls back to typical length setting', () async {
      final repo = _MemoryRepo();
      final useCase = CalculateTypicalCycleLengthUseCase(
        repo,
        fallbackCycleLength: () => 32,
      );

      expect(await useCase(), 32);
    });
  });

  group('PredictUpcomingCycleDatesUseCase', () {
    test('returns three future dates from latest start', () async {
      final repo = _MemoryRepo()
        ..seed(
          Cycle(
            id: 'latest',
            startDate: DateTime(2026, 2, 1),
            cycleLength: 28,
            createdAt: DateTime(2026, 2, 1),
            updatedAt: DateTime(2026, 2, 1),
          ),
        );

      final typical = CalculateTypicalCycleLengthUseCase(
        repo,
        fallbackCycleLength: () => 28,
      );
      final useCase = PredictUpcomingCycleDatesUseCase(repo, typical);

      final dates = await useCase();
      expect(dates, hasLength(3));
      expect(dates[0], DateTime(2026, 3, 1));
      expect(dates[1], DateTime(2026, 3, 29));
      expect(dates[2], DateTime(2026, 4, 26));
    });
  });

  group('AddCycleUseCase outlier guard', () {
    test('does not infer cycle length for implausible gap', () async {
      final repo = _MemoryRepo()
        ..seed(
          Cycle(
            id: 'ongoing',
            startDate: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

      final add = AddCycleUseCase(repo);
      await add(
        Cycle(
          id: 'next',
          startDate: DateTime(2026, 4, 1),
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 1),
        ),
      );

      final ongoing = await repo.getCycleById('ongoing');
      expect(ongoing?.cycleLength, isNull);
    });
  });

  group('predictionWindowDaysFromStatistics', () {
    test('returns zero without enough history', () {
      expect(
        predictionWindowDaysFromStatistics(
          completeCycles: 1,
          standardDeviation: 4,
        ),
        0,
      );
    });

    test('clamps window to five days', () {
      expect(
        predictionWindowDaysFromStatistics(
          completeCycles: 5,
          standardDeviation: 9.2,
        ),
        5,
      );
    });
  });
}
