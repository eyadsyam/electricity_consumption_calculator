// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_reading.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeterReadingAdapter extends TypeAdapter<MeterReading> {
  @override
  final int typeId = 5;

  @override
  MeterReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeterReading(
      id: fields[0] as String,
      userId: fields[1] as String,
      readingValue: fields[2] as double,
      readingDate: fields[3] as DateTime,
      consumptionKwh: fields[4] as double?,
      estimatedCost: fields[5] as double?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MeterReading obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.readingValue)
      ..writeByte(3)
      ..write(obj.readingDate)
      ..writeByte(4)
      ..write(obj.consumptionKwh)
      ..writeByte(5)
      ..write(obj.estimatedCost)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeterReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
