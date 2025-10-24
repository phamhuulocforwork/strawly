import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../repositories/cycle_repository.dart';

class CalculateAverageCycleLengthUseCase {
  final CycleRepository repository;

  CalculateAverageCycleLengthUseCase(this.repository);

  Future<double> call({int? limit}) async {
    final cycles = await repository.getRecentCycles(
      limit: limit ?? AppConstants.cyclesToConsider,
    );

    final completeCycles = cycles.where((c) => c.isComplete).toList();

    if (completeCycles.isEmpty) {
      return AppConstants.defaultCycleLength.toDouble();
    }

    final sum = completeCycles.fold<int>(
      0,
      (sum, cycle) => sum + cycle.cycleLength!,
    );

    return sum / completeCycles.length;
  }
}

class CalculateWeightedAverageCycleLengthUseCase {
  final CycleRepository repository;

  CalculateWeightedAverageCycleLengthUseCase(this.repository);

  Future<double> call({int? limit}) async {
    final cycles = await repository.getRecentCycles(
      limit: limit ?? AppConstants.cyclesToConsider,
    );

    final completeCycles = cycles.where((c) => c.isComplete).toList();

    if (completeCycles.isEmpty) {
      return AppConstants.defaultCycleLength.toDouble();
    }

    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 0; i < completeCycles.length; i++) {
      final weight = completeCycles.length - i; // Linear weight
      weightedSum += completeCycles[i].cycleLength! * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }
}

class PredictNextCycleUseCase {
  final CycleRepository repository;
  final CalculateWeightedAverageCycleLengthUseCase calculateAverage;

  PredictNextCycleUseCase(this.repository, this.calculateAverage);

  Future<DateTime?> call() async {
    final latestCycle = await repository.getLatestCycle();

    if (latestCycle == null) {
      return null;
    }

    final averageLength = await calculateAverage();
    final predictedStartDate = DateTimeUtils.addDays(
      latestCycle.startDate,
      averageLength.round(),
    );

    return predictedStartDate;
  }
}

class CalculateStandardDeviationUseCase {
  final CycleRepository repository;
  final CalculateAverageCycleLengthUseCase calculateAverage;

  CalculateStandardDeviationUseCase(this.repository, this.calculateAverage);

  Future<double> call({int? limit}) async {
    final cycles = await repository.getRecentCycles(
      limit: limit ?? AppConstants.cyclesToConsider,
    );

    final completeCycles = cycles.where((c) => c.isComplete).toList();

    if (completeCycles.length < 2) {
      return 0.0;
    }

    final average = await calculateAverage(limit: limit);

    final variance =
        completeCycles.fold<double>(0.0, (sum, cycle) {
          final diff = cycle.cycleLength! - average;
          return sum + (diff * diff);
        }) /
        completeCycles.length;

    return sqrt(variance);
  }
}

class CheckCycleRegularityUseCase {
  final CalculateStandardDeviationUseCase calculateStdDev;

  CheckCycleRegularityUseCase(this.calculateStdDev);

  Future<bool> call({int? limit}) async {
    final stdDev = await calculateStdDev(limit: limit);
    return stdDev <= AppConstants.regularCycleVariation;
  }
}

class CalculateDaysUntilNextPeriodUseCase {
  final PredictNextCycleUseCase predictNextCycle;

  CalculateDaysUntilNextPeriodUseCase(this.predictNextCycle);

  Future<int?> call() async {
    final predictedDate = await predictNextCycle();

    if (predictedDate == null) {
      return null;
    }

    final today = DateTimeUtils.dateOnly(DateTime.now());
    final daysUntil = DateTimeUtils.daysBetween(today, predictedDate);

    return daysUntil;
  }
}

class CalculateRegularityScoreUseCase {
  final CalculateStandardDeviationUseCase calculateStdDev;

  CalculateRegularityScoreUseCase(this.calculateStdDev);

  Future<double> call({int? limit}) async {
    final stdDev = await calculateStdDev(limit: limit);

    final score = max(0.0, 100.0 - (stdDev * 10));

    return score.clamp(0.0, 100.0).toDouble();
  }
}
