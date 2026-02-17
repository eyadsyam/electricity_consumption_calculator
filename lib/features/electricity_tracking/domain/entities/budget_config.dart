import 'package:hive/hive.dart';

part 'budget_config.g.dart';

@HiveType(typeId: 2)
class BudgetConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(11) // New Field matching SQL
  String? userId;

  @HiveField(1)
  double budgetAmount; // Maps to monthly_budget_egp in SQL

  @HiveField(12) // New Field matching SQL
  double? monthlyBudgetKwh;

  @HiveField(2)
  bool enableBudgetAlerts;

  @HiveField(3)
  double alertThresholdPercentage;

  @HiveField(4)
  int reminderDay; // اليوم المختار (1-28)

  @HiveField(5)
  int reminderTimeHour; // الساعة (0-23)

  @HiveField(6)
  int reminderTimeMinute; // الدقيقة (0-59)

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  String? supabaseId;

  @HiveField(10)
  bool isSynced;

  BudgetConfig({
    required this.id,
    this.userId,
    required this.budgetAmount,
    this.monthlyBudgetKwh,
    this.enableBudgetAlerts = true,
    this.alertThresholdPercentage = 80.0,
    this.reminderDay = 13,
    this.reminderTimeHour = 15,
    this.reminderTimeMinute = 43,
    DateTime? createdAt,
    this.updatedAt,
    this.supabaseId,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'monthly_budget_egp': budgetAmount, // SQL Column Name
    'monthly_budget_kwh': monthlyBudgetKwh, // SQL Column Name
    'enable_budget_alerts': enableBudgetAlerts,
    'alert_threshold_percentage': alertThresholdPercentage,
    'reminder_day': reminderDay,
    'reminder_time_hour': reminderTimeHour,
    'reminder_time_minute': reminderTimeMinute,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory BudgetConfig.fromJson(Map<String, dynamic> json) => BudgetConfig(
    id: json['id'] ?? '',
    userId: json['user_id'],
    budgetAmount: (json['monthly_budget_egp'] ?? json['budget_amount'] ?? 0)
        .toDouble(), // Handle both old/new
    monthlyBudgetKwh: (json['monthly_budget_kwh'] as num?)?.toDouble(),
    enableBudgetAlerts: json['enable_budget_alerts'] ?? true,
    alertThresholdPercentage: (json['alert_threshold_percentage'] ?? 80.0)
        .toDouble(),
    reminderDay: json['reminder_day'] ?? 13,
    reminderTimeHour: json['reminder_time_hour'] ?? 15,
    reminderTimeMinute: json['reminder_time_minute'] ?? 43,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
    supabaseId: json['id'], // ID from Supabase IS the ID
    isSynced: true,
  );

  BudgetConfig copyWith({
    String? id,
    String? userId,
    double? budgetAmount,
    double? monthlyBudgetKwh,
    bool? enableBudgetAlerts,
    double? alertThresholdPercentage,
    int? reminderDay,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supabaseId,
    bool? isSynced,
  }) {
    return BudgetConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      monthlyBudgetKwh: monthlyBudgetKwh ?? this.monthlyBudgetKwh,
      enableBudgetAlerts: enableBudgetAlerts ?? this.enableBudgetAlerts,
      alertThresholdPercentage:
          alertThresholdPercentage ?? this.alertThresholdPercentage,
      reminderDay: reminderDay ?? this.reminderDay,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supabaseId: supabaseId ?? this.supabaseId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
