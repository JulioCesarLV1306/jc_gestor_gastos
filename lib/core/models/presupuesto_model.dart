import 'package:hive/hive.dart';

part 'presupuesto_model.g.dart';

@HiveType(typeId: 1)
class PresupuestoModel extends HiveObject {
  @HiveField(0)
  double presupuestoGeneral;

  @HiveField(1)
  double saldoRestante;

  @HiveField(2)
  double ahorro; // Ahorro recomendado (15% del presupuesto)

  @HiveField(3)
  double metaAhorro; // Meta de ahorro definida por el usuario

  @HiveField(4)
  int semanasMetaAhorro; // Semanas para alcanzar la meta de ahorro

  PresupuestoModel({
    required this.presupuestoGeneral,
    required this.saldoRestante,
    required this.ahorro,
    this.metaAhorro = 0.0,
    this.semanasMetaAhorro = 0,
  });
}