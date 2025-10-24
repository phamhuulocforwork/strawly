import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/cycle_model.dart';

class CycleLocalDataSource {
  final Box<CycleModel> _cycleBox;

  CycleLocalDataSource(this._cycleBox);

  List<CycleModel> getAllCycles() {
    final cycles = _cycleBox.values.toList();
    cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    return cycles;
  }

  CycleModel? getCycleById(String id) {
    return _cycleBox.values.firstWhere(
      (cycle) => cycle.id == id,
      orElse: () => throw Exception('Cycle not found'),
    );
  }

  List<CycleModel> getCyclesInRange(DateTime start, DateTime end) {
    final cycles = _cycleBox.values.where((cycle) {
      return cycle.startDate.isAfter(start) && cycle.startDate.isBefore(end);
    }).toList();

    cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    return cycles;
  }

  List<CycleModel> getRecentCycles({
    int limit = AppConstants.cyclesToConsider,
  }) {
    final cycles = getAllCycles();
    return cycles.take(limit).toList();
  }

  List<CycleModel> getCompleteCycles() {
    return _cycleBox.values.where((cycle) => cycle.cycleLength != null).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> addCycle(CycleModel cycle) async {
    await _cycleBox.put(cycle.id, cycle);
  }

  Future<void> updateCycle(CycleModel cycle) async {
    if (!_cycleBox.containsKey(cycle.id)) {
      throw Exception('Cycle not found');
    }
    await _cycleBox.put(cycle.id, cycle);
  }

  Future<void> deleteCycle(String id) async {
    await _cycleBox.delete(id);
  }

  Future<void> deleteAllCycles() async {
    await _cycleBox.clear();
  }

  CycleModel? getLatestCycle() {
    final cycles = getAllCycles();
    return cycles.isNotEmpty ? cycles.first : null;
  }

  int getTotalCount() {
    return _cycleBox.length;
  }

  List<Map<String, dynamic>> exportToJson() {
    return _cycleBox.values.map((cycle) => cycle.toJson()).toList();
  }

  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {
    await _cycleBox.clear();

    for (final json in jsonList) {
      final cycle = CycleModel.fromJson(json);
      await _cycleBox.put(cycle.id, cycle);
    }
  }

  bool hasCycleOnDate(DateTime date) {
    return _cycleBox.values.any((cycle) {
      final startDate = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return startDate.isAtSameMomentAs(targetDate);
    });
  }
}
