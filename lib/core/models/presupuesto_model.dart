import 'package:hive/hive.dart';

part 'presupuesto_model.g.dart';

@HiveType(typeId: 1)
class PresupuestoModel extends HiveObject {
  @HiveField(0)
  double presupuestoGeneral;

  @HiveField(1)
  double saldoRestante;

  @HiveField(2)
  double ahorro; // Nuevo atributo para el ahorro

  PresupuestoModel({
    required this.presupuestoGeneral,
    required this.saldoRestante,
    required this.ahorro,
  });
}