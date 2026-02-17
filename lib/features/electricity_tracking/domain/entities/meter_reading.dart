import 'package:hive/hive.dart';

part 'meter_reading.g.dart';

@HiveType(typeId: 5)
class MeterReading extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double readingValue;

  @HiveField(3)
  final DateTime readingDate;

  @HiveField(4)
  final double? consumptionKwh; // Calculated difference from prev reading

  @HiveField(5)
  final double? estimatedCost; // From BillCalculatorService

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  bool isSynced; // Local Sync Flag

  MeterReading({
    required this.id,
    required this.userId,
    required this.readingValue,
    required this.readingDate,
    this.consumptionKwh,
    this.estimatedCost,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Helper for JSON/Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reading_value': readingValue,
      'reading_date': readingDate.toIso8601String(),
      'consumption_kwh': consumptionKwh,
      'estimated_cost': estimatedCost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
      id: json['id'],
      userId: json['user_id'],
      readingValue: (json['reading_value'] as num).toDouble(),
      readingDate: DateTime.parse(json['reading_date']),
      consumptionKwh: (json['consumption_kwh'] as num?)?.toDouble(),
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: true, // From Server = Synced
    );
  }

  MeterReading copyWith({
    String? id,
    String? userId,
    double? readingValue,
    DateTime? readingDate,
    double? consumptionKwh,
    double? estimatedCost,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return MeterReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingValue: readingValue ?? this.readingValue,
      readingDate: readingDate ?? this.readingDate,
      consumptionKwh: consumptionKwh ?? this.consumptionKwh,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
