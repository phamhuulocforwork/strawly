import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/encryption_utils.dart';
import '../../data/datasources/cycle_local_datasource.dart';
import '../../data/models/cycle_model.dart';
import '../../data/repositories/cycle_repository_impl.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../domain/usecases/cycle_usecases.dart';
import '../../domain/usecases/prediction_usecases.dart';
import '../../domain/usecases/statistics_usecases.dart';
import 'hive_service.dart';

final encryptionKeyProvider = FutureProvider<List<int>>((ref) async {
  final settingsBox = await ref.watch(settingsBoxProvider.future);

  String? keyString = settingsBox.get(AppConstants.encryptionKeyKey);

  if (keyString == null) {
    final newKey = EncryptionUtils.generateSecureKey();
    keyString = EncryptionUtils.keyToString(newKey);
    await settingsBox.put(AppConstants.encryptionKeyKey, keyString);
    return newKey;
  }

  return EncryptionUtils.stringToKey(keyString);
});

final cycleBoxProvider = FutureProvider<Box<CycleModel>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  final encryptionKey = await ref.watch(encryptionKeyProvider.future);

  return await hiveService.openEncryptedBox<CycleModel>(
    AppConstants.cycleBoxName,
    encryptionKey,
  );
});

final cycleLocalDataSourceProvider = FutureProvider<CycleLocalDataSource>((
  ref,
) async {
  final cycleBox = await ref.watch(cycleBoxProvider.future);
  return CycleLocalDataSource(cycleBox);
});

final cycleRepositoryProvider = FutureProvider<CycleRepository>((ref) async {
  final dataSource = await ref.watch(cycleLocalDataSourceProvider.future);
  return CycleRepositoryImpl(dataSource);
});

// NOTE:Use Case Providers ===========================================================================

final addCycleUseCaseProvider = FutureProvider<AddCycleUseCase>((ref) async {
  final repository = await ref.watch(cycleRepositoryProvider.future);
  return AddCycleUseCase(repository);
});

final updateCycleUseCaseProvider = FutureProvider<UpdateCycleUseCase>((
  ref,
) async {
  final repository = await ref.watch(cycleRepositoryProvider.future);
  return UpdateCycleUseCase(repository);
});

final deleteCycleUseCaseProvider = FutureProvider<DeleteCycleUseCase>((
  ref,
) async {
  final repository = await ref.watch(cycleRepositoryProvider.future);
  return DeleteCycleUseCase(repository);
});

final getCyclesUseCaseProvider = FutureProvider<GetCyclesUseCase>((ref) async {
  final repository = await ref.watch(cycleRepositoryProvider.future);
  return GetCyclesUseCase(repository);
});

final getCyclesInRangeUseCaseProvider = FutureProvider<GetCyclesInRangeUseCase>(
  (ref) async {
    final repository = await ref.watch(cycleRepositoryProvider.future);
    return GetCyclesInRangeUseCase(repository);
  },
);

final calculateAverageUseCaseProvider =
    FutureProvider<CalculateAverageCycleLengthUseCase>((ref) async {
      final repository = await ref.watch(cycleRepositoryProvider.future);
      return CalculateAverageCycleLengthUseCase(repository);
    });

final calculateWeightedAverageUseCaseProvider =
    FutureProvider<CalculateWeightedAverageCycleLengthUseCase>((ref) async {
      final repository = await ref.watch(cycleRepositoryProvider.future);
      return CalculateWeightedAverageCycleLengthUseCase(repository);
    });

final predictNextCycleUseCaseProvider = FutureProvider<PredictNextCycleUseCase>(
  (ref) async {
    final repository = await ref.watch(cycleRepositoryProvider.future);
    final calculateAverage = await ref.watch(
      calculateWeightedAverageUseCaseProvider.future,
    );
    return PredictNextCycleUseCase(repository, calculateAverage);
  },
);

final calculateStdDevUseCaseProvider =
    FutureProvider<CalculateStandardDeviationUseCase>((ref) async {
      final repository = await ref.watch(cycleRepositoryProvider.future);
      final calculateAverage = await ref.watch(
        calculateAverageUseCaseProvider.future,
      );
      return CalculateStandardDeviationUseCase(repository, calculateAverage);
    });

final checkRegularityUseCaseProvider =
    FutureProvider<CheckCycleRegularityUseCase>((ref) async {
      final calculateStdDev = await ref.watch(
        calculateStdDevUseCaseProvider.future,
      );
      return CheckCycleRegularityUseCase(calculateStdDev);
    });

final calculateDaysUntilUseCaseProvider =
    FutureProvider<CalculateDaysUntilNextPeriodUseCase>((ref) async {
      final predictNextCycle = await ref.watch(
        predictNextCycleUseCaseProvider.future,
      );
      return CalculateDaysUntilNextPeriodUseCase(predictNextCycle);
    });

final calculateRegularityScoreUseCaseProvider =
    FutureProvider<CalculateRegularityScoreUseCase>((ref) async {
      final calculateStdDev = await ref.watch(
        calculateStdDevUseCaseProvider.future,
      );
      return CalculateRegularityScoreUseCase(calculateStdDev);
    });

final getStatisticsUseCaseProvider = FutureProvider<GetCycleStatisticsUseCase>((
  ref,
) async {
  final repository = await ref.watch(cycleRepositoryProvider.future);
  final calculateAverage = await ref.watch(
    calculateAverageUseCaseProvider.future,
  );
  final calculateStdDev = await ref.watch(
    calculateStdDevUseCaseProvider.future,
  );
  final checkRegularity = await ref.watch(
    checkRegularityUseCaseProvider.future,
  );
  final predictNextCycle = await ref.watch(
    predictNextCycleUseCaseProvider.future,
  );
  final calculateDaysUntil = await ref.watch(
    calculateDaysUntilUseCaseProvider.future,
  );
  final calculateRegularityScore = await ref.watch(
    calculateRegularityScoreUseCaseProvider.future,
  );

  return GetCycleStatisticsUseCase(
    repository: repository,
    calculateAverage: calculateAverage,
    calculateStdDev: calculateStdDev,
    checkRegularity: checkRegularity,
    predictNextCycle: predictNextCycle,
    calculateDaysUntil: calculateDaysUntil,
    calculateRegularityScore: calculateRegularityScore,
  );
});
