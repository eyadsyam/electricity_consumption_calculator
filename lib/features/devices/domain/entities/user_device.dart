import 'package:hive/hive.dart';

part 'user_device.g.dart';

@HiveType(typeId: 0)
class UserDevice extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(10) // New
  String? userId;

  @HiveField(1)
  String deviceName;

  @HiveField(2)
  String category;

  @HiveField(3)
  double powerWatts;

  @HiveField(4)
  double usageHoursPerDay;

  @HiveField(5)
  String iconName;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(11) // New
  DateTime updatedAt;

  @HiveField(8)
  String? supabaseId;

  @HiveField(9)
  bool isSynced;

  @HiveField(12)
  int quantity;

  UserDevice({
    required this.id,
    this.userId,
    required this.deviceName,
    required this.category,
    required this.powerWatts,
    this.usageHoursPerDay = 0,
    this.quantity = 1,
    this.iconName = 'electrical_services',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.supabaseId,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Calculate daily consumption in kWh
  double get dailyConsumptionKwh =>
      (powerWatts * usageHoursPerDay * quantity) / 1000;

  // Calculate monthly consumption in kWh
  double get monthlyConsumptionKwh => dailyConsumptionKwh * 30;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'device_name': deviceName,
    'device_category': category,
    'power_watts': powerWatts,
    'usage_hours_per_day': usageHoursPerDay,
    'quantity': quantity,
    'icon_name': iconName,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory UserDevice.fromJson(Map<String, dynamic> json) => UserDevice(
    id: json['id'] ?? '',
    userId: json['user_id'],
    deviceName: json['device_name'] ?? '',
    category: json['device_category'] ?? '',
    powerWatts: (json['power_watts'] ?? 0).toDouble(),
    usageHoursPerDay: (json['usage_hours_per_day'] ?? 0).toDouble(),
    quantity: json['quantity'] ?? 1,
    iconName: json['icon_name'] ?? 'electrical_services',
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : DateTime.now(),
    supabaseId: json['id'],
    isSynced: true,
  );
}
