// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_reading.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeterReadingAdapter extends TypeAdapter<MeterReading> {
  @override
  final int typeId = 1;

  @override
  MeterReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeterReading(
      id: fields[0] as String,
      readingValue: fields[1] as double,
      readingDate: fields[2] as DateTime,
      consumptionKwh: fields[3] as double?,
      estimatedCost: fields[4] as double?,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      supabaseId: fields[7] as String?,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MeterReading obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.readingValue)
      ..writeByte(2)
      ..write(obj.readingDate)
      ..writeByte(3)
      ..write(obj.consumptionKwh)
      ..writeByte(4)
      ..write(obj.estimatedCost)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.supabaseId)
      ..writeByte(8)
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
