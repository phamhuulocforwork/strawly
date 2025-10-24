import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../entities/cycle.dart';
import '../repositories/cycle_repository.dart';

class AddCycleUseCase {
  final CycleRepository repository;

  AddCycleUseCase(this.repository);

  Future<void> call(Cycle cycle) async {
    // Validate cycle
    if (cycle.cycleLength != null) {
      if (cycle.cycleLength! < AppConstants.minCycleLength ||
          cycle.cycleLength! > AppConstants.maxCycleLength) {
        throw Exception('Invalid cycle length');
      }
    }

    // Check if cycle already exists for this date
    final hasExisting = await repository.hasCycleOnDate(cycle.startDate);
    if (hasExisting) {
      throw Exception('A cycle already exists for this date');
    }

    // If this is a new cycle, update the previous cycle's length
    final latestCycle = await repository.getLatestCycle();
    if (latestCycle != null && latestCycle.cycleLength == null) {
      final daysBetween = DateTimeUtils.daysBetween(
        latestCycle.startDate,
        cycle.startDate,
      );

      if (daysBetween > 0) {
        final updatedCycle = latestCycle.copyWith(
          cycleLength: daysBetween,
          updatedAt: DateTime.now(),
        );
        await repository.updateCycle(updatedCycle);
      }
    }

    await repository.addCycle(cycle);
  }
}

class UpdateCycleUseCase {
  final CycleRepository repository;

  UpdateCycleUseCase(this.repository);

  Future<void> call(Cycle cycle) async {
    if (cycle.cycleLength != null) {
      if (cycle.cycleLength! < AppConstants.minCycleLength ||
          cycle.cycleLength! > AppConstants.maxCycleLength) {
        throw Exception('Invalid cycle length');
      }
    }

    await repository.updateCycle(cycle);
  }
}

class DeleteCycleUseCase {
  final CycleRepository repository;

  DeleteCycleUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteCycle(id);
  }
}

class GetCyclesUseCase {
  final CycleRepository repository;

  GetCyclesUseCase(this.repository);

  Future<List<Cycle>> call() async {
    return await repository.getAllCycles();
  }
}

class GetCyclesInRangeUseCase {
  final CycleRepository repository;

  GetCyclesInRangeUseCase(this.repository);

  Future<List<Cycle>> call(DateTime start, DateTime end) async {
    return await repository.getCyclesInRange(start, end);
  }
}
