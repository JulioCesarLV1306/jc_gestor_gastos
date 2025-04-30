import 'package:gestor_de_gastos_jc/core/models/presupuesto_model.dart';
import 'package:hive/hive.dart';

class PresupuestoService {
  static const String presupuestoBoxName = "presupuestoBox";
  static bool _isHiveInitialized = false;

  // Inicializar Hive para el presupuesto
  Future<void> initHive() async {
    if (!_isHiveInitialized) { // Corregido: Verificar si Hive no está inicializado
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PresupuestoModelAdapter());
      }

      await Hive.openBox<PresupuestoModel>(presupuestoBoxName);
      _isHiveInitialized = true; // Marcar Hive como inicializado
      print("✅ Hive inicializado y adaptadores registrados para presupuesto.");
    }
  }

  // Obtener el presupuesto actual
  PresupuestoModel? getPresupuesto() {
    final box = Hive.box<PresupuestoModel>(presupuestoBoxName);
    return box.get('presupuesto');
  }

  // // Guardar o actualizar el presupuesto
   Future<void> savePresupuesto(PresupuestoModel presupuesto) async {
     final box = Hive.box<PresupuestoModel>(presupuestoBoxName);
     await box.put('presupuesto', presupuesto);
     print("✅ Presupuesto guardado/actualizado en Hive");
   }
    // Guardar un gasto en Hive
    /*
  Future<void> savePresupuesto(PresupuestoModel presupuesto) async {
    final box = Hive.box<PresupuestoModel>(presupuestoBoxName);
    await box.add(presupuesto); // Agregar el gasto a la caja
    print("✅ Gasto guardado en Hive: ${presupuesto.presupuestoGeneral}");
  }*/

  // Actualizar el saldo restante
  Future<void> actualizarSaldo(double nuevoSaldo) async {
    final box = Hive.box<PresupuestoModel>(presupuestoBoxName);
    final presupuestoActual = box.get('presupuesto');
    if (presupuestoActual != null) {
      presupuestoActual.saldoRestante = nuevoSaldo;
      await presupuestoActual.save();
      print("✅ Saldo restante actualizado: $nuevoSaldo");
    }
  }
}