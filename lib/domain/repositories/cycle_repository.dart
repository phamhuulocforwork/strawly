import '../../domain/entities/cycle.dart';

abstract class CycleRepository {
  /// Get all cycles
  Future<List<Cycle>> getAllCycles();

  /// Get cycle by ID
  Future<Cycle?> getCycleById(String id);

  /// Get cycles in date range
  Future<List<Cycle>> getCyclesInRange(DateTime start, DateTime end);

  /// Get recent cycles for prediction
  Future<List<Cycle>> getRecentCycles({int limit});

  /// Get complete cycles only
  Future<List<Cycle>> getCompleteCycles();

  /// Add a new cycle
  Future<void> addCycle(Cycle cycle);

  /// Update an existing cycle
  Future<void> updateCycle(Cycle cycle);

  /// Delete a cycle
  Future<void> deleteCycle(String id);

  /// Delete all cycles
  Future<void> deleteAllCycles();

  /// Get the latest cycle
  Future<Cycle?> getLatestCycle();

  /// Get total count
  Future<int> getTotalCount();

  /// Export cycles to JSON
  Future<List<Map<String, dynamic>>> exportToJson();

  /// Import cycles from JSON
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList);

  /// Check if a cycle exists for a given date
  Future<bool> hasCycleOnDate(DateTime date);
}
