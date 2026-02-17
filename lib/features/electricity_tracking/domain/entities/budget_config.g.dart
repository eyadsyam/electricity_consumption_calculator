// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetConfigAdapter extends TypeAdapter<BudgetConfig> {
  @override
  final int typeId = 2;

  @override
  BudgetConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetConfig(
      id: fields[0] as String,
      userId: fields[11] as String?,
      budgetAmount: fields[1] as double,
      monthlyBudgetKwh: fields[12] as double?,
      enableBudgetAlerts: fields[2] as bool,
      alertThresholdPercentage: fields[3] as double,
      reminderDay: fields[4] as int,
      reminderTimeHour: fields[5] as int,
      reminderTimeMinute: fields[6] as int,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      supabaseId: fields[9] as String?,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetConfig obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.budgetAmount)
      ..writeByte(12)
      ..write(obj.monthlyBudgetKwh)
      ..writeByte(2)
      ..write(obj.enableBudgetAlerts)
      ..writeByte(3)
      ..write(obj.alertThresholdPercentage)
      ..writeByte(4)
      ..write(obj.reminderDay)
      ..writeByte(5)
      ..write(obj.reminderTimeHour)
      ..writeByte(6)
      ..write(obj.reminderTimeMinute)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.supabaseId)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
