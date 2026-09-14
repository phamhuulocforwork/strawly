import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../repositories/cycle_repository.dart';
import 'cycle_length_stats.dart';

class CalculateAverageCycleLengthUseCase {
  final CycleRepository repository;

  CalculateAverageCycleLengthUseCase(this.repository);

  Future<double> call({int? limit}) async {
    final cycles = await repository.getRecentCycles(
      limit: limit ?? AppConstants.cyclesToConsider,
    );

    final lengths = CycleLengthStats.plausibleLengthsFromComplete(
      cycles.where((c) => c.isComplete).map((c) => c.cycleLength!),
    );

    if (lengths.isEmpty) {
      return AppConstants.defaultCycleLength.toDouble();
    }

    final sum = lengths.fold<int>(0, (sum, length) => sum + length);
    return sum / lengths.length;
  }
}

class CalculateTypicalCycleLengthUseCase {
  final CycleRepository repository;
  final int Function() fallbackCycleLength;

  CalculateTypicalCycleLengthUseCase(
    this.repository, {
    required this.fallbackCycleLength,
  });

  Future<double> call({int? limit}) async {
    final cycles = await repository.getRecentCycles(
      limit: limit ?? AppConstants.cyclesToConsider,
    );

    final lengths = CycleLengthStats.plausibleLengthsFromComplete(
      cycles.where((c) => c.isComplete).map((c) => c.cycleLength!),
    );

    if (lengths.isEmpty) {
      return fallbackCycleLength().toDouble();
    }

    return CycleLengthStats.median(lengths);
  }
}

class PredictNextCycleUseCase {
  final CycleRepository repository;
  final CalculateTypicalCycleLengthUseCase calculateTypical;

  PredictNextCycleUseCase(this.repository, this.calculateTypical);

  Future<DateTime?> call() async {
    final dates = await PredictUpcomingCycleDatesUseCase(
      repository,
      calculateTypical,
    ).call(forecastCount: 1);
    return dates.isEmpty ? null : dates.first;
  }
}

class PredictUpcomingCycleDatesUseCase {
  final CycleRepository repository;
  final CalculateTypicalCycleLengthUseCase calculateTypical;

  PredictUpcomingCycleDatesUseCase(this.repository, this.calculateTypical);

  Future<List<DateTime>> call({int forecastCount = 3}) async {
    final latestCycle = await repository.getLatestCycle();

    if (latestCycle == null || forecastCount <= 0) {
      return const [];
    }

    final typicalLength = (await calculateTypical()).round();
    return List.generate(
      forecastCount,
      (index) => DateTimeUtils.addDays(
        latestCycle.startDate,
        typicalLength * (index + 1),
      ),
    );
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

    final lengths = CycleLengthStats.plausibleLengthsFromComplete(
      cycles.where((c) => c.isComplete).map((c) => c.cycleLength!),
    );

    if (lengths.length < 2) {
      return 0.0;
    }

    final average = await calculateAverage(limit: limit);

    final variance =
        lengths.fold<double>(0.0, (sum, length) {
          final diff = length - average;
          return sum + (diff * diff);
        }) /
        lengths.length;

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

/// Window half-width in days for prediction UI (±N days).
int predictionWindowDaysFromStatistics({
  required int completeCycles,
  required double standardDeviation,
}) {
  if (completeCycles < 2 || standardDeviation <= 0) {
    return 0;
  }
  return standardDeviation.round().clamp(0, 5);
}
