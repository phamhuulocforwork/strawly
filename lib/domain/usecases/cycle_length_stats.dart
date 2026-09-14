import '../../core/constants/app_constants.dart';

/// Shared cycle-length sampling for prediction and statistics.
abstract final class CycleLengthStats {
  static bool isPlausibleLength(int length) {
    return length >= AppConstants.minPlausibleCycleLength &&
        length <= AppConstants.maxPlausibleCycleLength;
  }

  static List<int> plausibleLengthsFromComplete(
    Iterable<int> cycleLengths,
  ) {
    return cycleLengths.where(isPlausibleLength).toList();
  }

  static double median(List<int> values) {
    if (values.isEmpty) {
      throw ArgumentError('median requires at least one value');
    }
    final sorted = List<int>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[mid].toDouble();
    }
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
