# Prediction & Statistics Algorithms

## Overview

The application uses statistical methods (not ML) to predict menstrual cycles and analyze patterns. All algorithms are implemented in `/lib/domain/usecases/`.

## Prediction Use Cases

### 1. Calculate Simple Average Cycle Length

**Class**: `CalculateAverageCycleLengthUseCase`
**Location**: `/lib/domain/usecases/prediction_usecases.dart`

```dart
Future<double> call({int? limit}) async {
  final cycles = await repository.getRecentCycles(
    limit: limit ?? AppConstants.cyclesToConsider,
  );

  final completeCycles = cycles.where((c) => c.isComplete).toList();

  if (completeCycles.isEmpty) {
    return AppConstants.defaultCycleLength.toDouble(); // 28 days
  }

  final sum = completeCycles.fold<int>(0, (sum, cycle) => sum + cycle.cycleLength!);
  return sum / completeCycles.length;
}
```

**Algorithm**: Simple arithmetic mean

- Considers only complete cycles
- Falls back to 28 days if no history
- Configurable number of cycles to consider

### 2. Calculate Weighted Average Cycle Length

**Class**: `CalculateWeightedAverageCycleLengthUseCase`

```dart
Future<double> call({int? limit}) async {
  final completeCycles = // get complete cycles

  double weightedSum = 0;
  double totalWeight = 0;

  for (int i = 0; i < completeCycles.length; i++) {
    final weight = completeCycles.length - i; // Linear weight
    weightedSum += completeCycles[i].cycleLength! * weight;
    totalWeight += weight;
  }

  return weightedSum / totalWeight;
}
```

**Algorithm**: Weighted moving average with linear weights

- Recent cycles weighted more heavily
- Weight formula: `weight = n - i` where n is total cycles, i is index
- More responsive to recent changes

**Example**:

- If 3 cycles: [28, 30, 29] days
- Weights: [3, 2, 1]
- Weighted average: (28×3 + 30×2 + 29×1) / (3+2+1) = 28.83 days

### 3. Predict Next Cycle Start Date

**Class**: `PredictNextCycleUseCase`

```dart
Future<DateTime?> call() async {
  final latestCycle = await repository.getLatestCycle();
  if (latestCycle == null) return null;

  final averageLength = await calculateAverage(); // Uses weighted average
  final predictedStartDate = DateTimeUtils.addDays(
    latestCycle.startDate,
    averageLength.round(),
  );

  return predictedStartDate;
}
```

**Algorithm**: Simple date addition

- Formula: `nextStart = lastStart + weightedAverage`
- Returns null if no history

### 4. Calculate Days Until Next Period

**Class**: `CalculateDaysUntilNextPeriodUseCase`

```dart
Future<int?> call() async {
  final predictedDate = await predictNextCycle();
  if (predictedDate == null) return null;

  final today = DateTimeUtils.dateOnly(DateTime.now());
  final daysUntil = DateTimeUtils.daysBetween(today, predictedDate);

  return daysUntil;
}
```

**Returns**:

- Positive number: days until next period
- Negative number: days overdue
- Null: insufficient data

## Statistics Use Cases

### 5. Calculate Standard Deviation

**Class**: `CalculateStandardDeviationUseCase`

```dart
Future<double> call({int? limit}) async {
  final completeCycles = // get complete cycles

  if (completeCycles.length < 2) return 0.0;

  final average = await calculateAverage(limit: limit);

  final variance = completeCycles.fold<double>(0.0, (sum, cycle) {
    final diff = cycle.cycleLength! - average;
    return sum + (diff * diff);
  }) / completeCycles.length;

  return sqrt(variance);
}
```

**Algorithm**: Population standard deviation

- Formula: `σ = √(Σ(x - μ)² / N)`
- Measures cycle length variability
- Lower value = more regular cycles

### 6. Check Cycle Regularity

**Class**: `CheckCycleRegularityUseCase`

```dart
Future<bool> call({int? limit}) async {
  final stdDev = await calculateStdDev(limit: limit);
  return stdDev <= AppConstants.regularCycleVariation; // 7 days
}
```

**Algorithm**: Threshold-based classification

- Regular if standard deviation ≤ 7 days
- Based on medical guidelines

### 7. Calculate Regularity Score

**Class**: `CalculateRegularityScoreUseCase`

```dart
Future<double> call({int? limit}) async {
  final stdDev = await calculateStdDev(limit: limit);

  if (stdDev == 0) return 100.0;

  // Exponential decay scoring
  final maxStdDev = AppConstants.regularCycleVariation.toDouble();
  final score = 100 * exp(-stdDev / maxStdDev);

  return score.clamp(0.0, 100.0);
}
```

**Algorithm**: Exponential decay function

- Formula: `score = 100 × e^(-σ/7)`
- Range: 0-100
- Perfect regularity (σ=0) → 100
- High variability → approaches 0

**Score Interpretation**:

- 90-100: Very regular
- 70-89: Regular
- 50-69: Somewhat irregular
- <50: Irregular

### 8. Get Comprehensive Statistics

**Class**: `GetCycleStatisticsUseCase`
**Location**: `/lib/domain/usecases/statistics_usecases.dart`

Aggregates all statistical metrics into `CycleStatistics` entity:

- Average cycle length
- Standard deviation
- Total/complete cycle counts
- Regularity status
- Predicted next start date
- Days until next period
- Regularity score (0-100)

## Constants Used

**Location**: `/lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  static const int defaultCycleLength = 28;
  static const int cyclesToConsider = 6;     // For averages
  static const int regularCycleVariation = 7; // Max std dev for regular
  // ... other constants
}
```

## Fertile Window Calculation

**Location**: `/lib/presentation/widgets/cycle_calendar_widget.dart`

```dart
// Ovulation typically 14 days before next period
final ovulationDay = nextStartDate.subtract(Duration(days: 14));

// Fertile window: 5 days before + ovulation day + 1 day after
final fertileStart = ovulationDay.subtract(Duration(days: 5));
final fertileEnd = ovulationDay.add(Duration(days: 1));
```

**Medical Basis**:

- Ovulation occurs ~14 days before next period
- Sperm survives up to 5 days
- Egg survives ~24 hours
- Fertile window: 7 days total

## Algorithm Characteristics

### Strengths

✅ Simple and transparent
✅ No training data required
✅ Fast computation
✅ Medically aligned
✅ Works with minimal history

### Limitations

⚠️ Assumes somewhat regular cycles
⚠️ Linear prediction only
⚠️ No consideration of external factors (stress, medication, etc.)
⚠️ Less accurate for highly irregular cycles

## Future Enhancements

Potential improvements without heavy ML:

1. **Exponential Smoothing**: More sophisticated weighting
2. **Seasonal Adjustment**: Account for seasonal patterns
3. **Outlier Detection**: Remove anomalous cycles
4. **Confidence Intervals**: Provide prediction ranges
5. **Multiple Predictions**: Best/worst case scenarios

## Usage Example

```dart
final predictNextCycle = ref.watch(predictNextCycleUseCaseProvider);
final nextDate = await predictNextCycle();

final stats = ref.watch(getCycleStatisticsUseCaseProvider);
final statistics = await stats();

print('Next period: $nextDate');
print('Regularity: ${statistics.regularityScore}%');
```
