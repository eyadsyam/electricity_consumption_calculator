import 'package:hive/hive.dart';

part 'user_device.g.dart';

@HiveType(typeId: 0)
class UserDevice extends HiveObject {
  @HiveField(0)
  String id;

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

  @HiveField(8)
  String? supabaseId; // For syncing with Supabase

  @HiveField(9)
  bool isSynced; // Track if synced to cloud

  UserDevice({
    required this.id,
    required this.deviceName,
    required this.category,
    required this.powerWatts,
    this.usageHoursPerDay = 0,
    this.iconName = 'electrical_services',
    this.isActive = true,
    DateTime? createdAt,
    this.supabaseId,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate daily consumption in kWh
  double get dailyConsumptionKwh => (powerWatts * usageHoursPerDay) / 1000;

  // Calculate monthly consumption in kWh
  double get monthlyConsumptionKwh => dailyConsumptionKwh * 30;

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_name': deviceName,
    'device_category': category,
    'power_watts': powerWatts,
    'usage_hours_per_day': usageHoursPerDay,
    'icon_name': iconName,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserDevice.fromJson(Map<String, dynamic> json) => UserDevice(
    id: json['id'] ?? '',
    deviceName: json['device_name'] ?? '',
    category: json['device_category'] ?? '',
    powerWatts: (json['power_watts'] ?? 0).toDouble(),
    usageHoursPerDay: (json['usage_hours_per_day'] ?? 0).toDouble(),
    iconName: json['icon_name'] ?? 'electrical_services',
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    supabaseId: json['id'],
    isSynced: true,
  );
}
