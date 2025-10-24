import 'package:hive/hive.dart';
import '../../core/constants/hive_type_ids.dart';
import '../../domain/entities/cycle.dart';

part 'cycle_model.g.dart';

@HiveType(typeId: HiveTypeIds.cycle)
class CycleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  int? cycleLength;

  @HiveField(3)
  int? periodDuration;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  CycleModel({
    required this.id,
    required this.startDate,
    this.cycleLength,
    this.periodDuration,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Cycle toEntity() {
    return Cycle(
      id: id,
      startDate: startDate,
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CycleModel.fromEntity(Cycle cycle) {
    return CycleModel(
      id: cycle.id,
      startDate: cycle.startDate,
      cycleLength: cycle.cycleLength,
      periodDuration: cycle.periodDuration,
      notes: cycle.notes,
      createdAt: cycle.createdAt,
      updatedAt: cycle.updatedAt,
    );
  }

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      cycleLength: json['cycleLength'] as int?,
      periodDuration: json['periodDuration'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CycleModel copyWith({
    String? id,
    DateTime? startDate,
    int? cycleLength,
    int? periodDuration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
