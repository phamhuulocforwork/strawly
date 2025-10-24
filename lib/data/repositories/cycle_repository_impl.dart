import '../../domain/entities/cycle.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../datasources/cycle_local_datasource.dart';
import '../models/cycle_model.dart';

class CycleRepositoryImpl implements CycleRepository {
  final CycleLocalDataSource _localDataSource;

  CycleRepositoryImpl(this._localDataSource);

  @override
  Future<List<Cycle>> getAllCycles() async {
    final models = _localDataSource.getAllCycles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Cycle?> getCycleById(String id) async {
    try {
      final model = _localDataSource.getCycleById(id);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end) async {
    final models = _localDataSource.getCyclesInRange(start, end);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Cycle>> getRecentCycles({int limit = 6}) async {
    final models = _localDataSource.getRecentCycles(limit: limit);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Cycle>> getCompleteCycles() async {
    final models = _localDataSource.getCompleteCycles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCycle(Cycle cycle) async {
    final model = CycleModel.fromEntity(cycle);
    await _localDataSource.addCycle(model);
  }

  @override
  Future<void> updateCycle(Cycle cycle) async {
    final model = CycleModel.fromEntity(cycle);
    await _localDataSource.updateCycle(model);
  }

  @override
  Future<void> deleteCycle(String id) async {
    await _localDataSource.deleteCycle(id);
  }

  @override
  Future<void> deleteAllCycles() async {
    await _localDataSource.deleteAllCycles();
  }

  @override
  Future<Cycle?> getLatestCycle() async {
    final model = _localDataSource.getLatestCycle();
    return model?.toEntity();
  }

  @override
  Future<int> getTotalCount() async {
    return _localDataSource.getTotalCount();
  }

  @override
  Future<List<Map<String, dynamic>>> exportToJson() async {
    return _localDataSource.exportToJson();
  }

  @override
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {
    await _localDataSource.importFromJson(jsonList);
  }

  @override
  Future<bool> hasCycleOnDate(DateTime date) async {
    return _localDataSource.hasCycleOnDate(date);
  }
}
