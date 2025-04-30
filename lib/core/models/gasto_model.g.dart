// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoModelAdapter extends TypeAdapter<GastoModel> {
  @override
  final int typeId = 0;

  @override
  GastoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GastoModel(
      descripcion: fields[0] as String,
      cantidad: fields[1] as double,
      categoria: fields[2] as String,
      fecha: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GastoModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.descripcion)
      ..writeByte(1)
      ..write(obj.cantidad)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
