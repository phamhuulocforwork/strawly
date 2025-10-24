import '../entities/cycle_statistics.dart';
import '../repositories/cycle_repository.dart';
import 'prediction_usecases.dart';

class GetCycleStatisticsUseCase {
  final CycleRepository repository;
  final CalculateAverageCycleLengthUseCase calculateAverage;
  final CalculateStandardDeviationUseCase calculateStdDev;
  final CheckCycleRegularityUseCase checkRegularity;
  final PredictNextCycleUseCase predictNextCycle;
  final CalculateDaysUntilNextPeriodUseCase calculateDaysUntil;
  final CalculateRegularityScoreUseCase calculateRegularityScore;

  GetCycleStatisticsUseCase({
    required this.repository,
    required this.calculateAverage,
    required this.calculateStdDev,
    required this.checkRegularity,
    required this.predictNextCycle,
    required this.calculateDaysUntil,
    required this.calculateRegularityScore,
  });

  Future<CycleStatistics> call() async {
    final totalCycles = await repository.getTotalCount();
    final completeCycles = await repository.getCompleteCycles();

    if (totalCycles == 0) {
      return CycleStatistics(
        averageCycleLength: 0,
        standardDeviation: 0,
        totalCycles: 0,
        completeCycles: 0,
        isRegular: false,
        predictedNextStartDate: null,
        daysUntilNextPeriod: null,
        regularityScore: 0,
      );
    }

    final averageLength = await calculateAverage();
    final stdDev = await calculateStdDev();
    final isRegular = await checkRegularity();
    final predictedDate = await predictNextCycle();
    final daysUntil = await calculateDaysUntil();
    final regularityScore = await calculateRegularityScore();

    return CycleStatistics(
      averageCycleLength: averageLength,
      standardDeviation: stdDev,
      totalCycles: totalCycles,
      completeCycles: completeCycles.length,
      isRegular: isRegular,
      predictedNextStartDate: predictedDate,
      daysUntilNextPeriod: daysUntil,
      regularityScore: regularityScore,
    );
  }
}
