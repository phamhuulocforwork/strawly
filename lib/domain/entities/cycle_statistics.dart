import 'package:equatable/equatable.dart';

class CycleStatistics extends Equatable {
  final double averageCycleLength;
  final double standardDeviation;
  final int totalCycles;
  final int completeCycles;
  final bool isRegular;
  final DateTime? predictedNextStartDate;
  final int? daysUntilNextPeriod;
  final double? regularityScore; // 0-100, higher is more regular
  final double? averagePeriodDuration;
  final int? shortestCycleLength;
  final int? longestCycleLength;
  final int? currentCycleDay;

  const CycleStatistics({
    required this.averageCycleLength,
    required this.standardDeviation,
    required this.totalCycles,
    required this.completeCycles,
    required this.isRegular,
    this.predictedNextStartDate,
    this.daysUntilNextPeriod,
    this.regularityScore,
    this.averagePeriodDuration,
    this.shortestCycleLength,
    this.longestCycleLength,
    this.currentCycleDay,
  });

  @override
  List<Object?> get props => [
    averageCycleLength,
    standardDeviation,
    totalCycles,
    completeCycles,
    isRegular,
    predictedNextStartDate,
    daysUntilNextPeriod,
    regularityScore,
    averagePeriodDuration,
    shortestCycleLength,
    longestCycleLength,
    currentCycleDay,
  ];
}
