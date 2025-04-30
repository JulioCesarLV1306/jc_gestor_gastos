// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresupuestoModelAdapter extends TypeAdapter<PresupuestoModel> {
  @override
  final int typeId = 1;

  @override
  PresupuestoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresupuestoModel(
      presupuestoGeneral: fields[0] as double,
      saldoRestante: fields[1] as double,
      ahorro: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PresupuestoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.presupuestoGeneral)
      ..writeByte(1)
      ..write(obj.saldoRestante)
      ..writeByte(2)
      ..write(obj.ahorro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresupuestoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
