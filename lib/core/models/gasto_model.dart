import 'package:hive/hive.dart';

part 'gasto_model.g.dart';

@HiveType(typeId: 0)
class GastoModel extends HiveObject {
  @HiveField(0)
  String descripcion;

  @HiveField(1)
  double cantidad;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  DateTime fecha;

  GastoModel({
    required this.descripcion,
    required this.cantidad,
    required this.categoria,
    required this.fecha,
  });
}