import 'package:hive/hive.dart';

part 'meter_reading.g.dart';

@HiveType(typeId: 1)
class MeterReading extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double readingValue;

  @HiveField(2)
  DateTime readingDate;

  @HiveField(3)
  double? consumptionKwh;

  @HiveField(4)
  double? estimatedCost;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? supabaseId;

  @HiveField(8)
  bool isSynced;

  MeterReading({
    required this.id,
    required this.readingValue,
    required this.readingDate,
    this.consumptionKwh,
    this.estimatedCost,
    this.notes,
    DateTime? createdAt,
    this.supabaseId,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'reading_value': readingValue,
    'reading_date': readingDate.toIso8601String().split('T')[0],
    'consumption_kwh': consumptionKwh,
    'estimated_cost': estimatedCost,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory MeterReading.fromJson(Map<String, dynamic> json) => MeterReading(
    id: json['id'] ?? '',
    readingValue: (json['reading_value'] ?? 0).toDouble(),
    readingDate: json['reading_date'] != null
        ? DateTime.parse(json['reading_date'])
        : DateTime.now(),
    consumptionKwh: json['consumption_kwh']?.toDouble(),
    estimatedCost: json['estimated_cost']?.toDouble(),
    notes: json['notes'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    supabaseId: json['id'],
    isSynced: true,
  );
}
