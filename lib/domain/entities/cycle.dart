import 'package:equatable/equatable.dart';

class Cycle extends Equatable {
  final String id;
  final DateTime startDate;
  final int? cycleLength; // Length in days, null if cycle is ongoing
  final int? periodDuration; // Duration of menstruation in days
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cycle({
    required this.id,
    required this.startDate,
    this.cycleLength,
    this.periodDuration,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isComplete => cycleLength != null;

  DateTime? get endDate {
    if (cycleLength == null) return null;
    return startDate.add(Duration(days: cycleLength!));
  }

  Cycle copyWith({
    String? id,
    DateTime? startDate,
    int? cycleLength,
    int? periodDuration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startDate,
    cycleLength,
    periodDuration,
    notes,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Cycle(id: $id, startDate: $startDate, cycleLength: $cycleLength, periodDuration: $periodDuration)';
  }
}
