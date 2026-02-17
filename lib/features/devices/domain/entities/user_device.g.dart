// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDeviceAdapter extends TypeAdapter<UserDevice> {
  @override
  final int typeId = 0;

  @override
  UserDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserDevice(
      id: fields[0] as String,
      userId: fields[10] as String?,
      deviceName: fields[1] as String,
      category: fields[2] as String,
      powerWatts: fields[3] as double,
      usageHoursPerDay: fields[4] as double,
      quantity: fields[12] as int,
      iconName: fields[5] as String,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      supabaseId: fields[8] as String?,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserDevice obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.powerWatts)
      ..writeByte(4)
      ..write(obj.usageHoursPerDay)
      ..writeByte(5)
      ..write(obj.iconName)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.supabaseId)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
