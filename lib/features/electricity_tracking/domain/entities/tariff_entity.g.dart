// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TariffSlabAdapter extends TypeAdapter<TariffSlab> {
  @override
  final int typeId = 3;

  @override
  TariffSlab read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TariffSlab(
      startKwh: fields[0] as int,
      endKwh: fields[1] as int,
      pricePerKwh: fields[2] as double,
      slabOrder: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TariffSlab obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startKwh)
      ..writeByte(1)
      ..write(obj.endKwh)
      ..writeByte(2)
      ..write(obj.pricePerKwh)
      ..writeByte(3)
      ..write(obj.slabOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TariffSlabAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TariffFeeAdapter extends TypeAdapter<TariffFee> {
  @override
  final int typeId = 4;

  @override
  TariffFee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TariffFee(
      name: fields[0] as String,
      amount: fields[1] as double,
      minKwh: fields[2] as int,
      maxKwh: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TariffFee obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.minKwh)
      ..writeByte(3)
      ..write(obj.maxKwh);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TariffFeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
