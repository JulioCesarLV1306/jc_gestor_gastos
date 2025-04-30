import 'package:hive_flutter/adapters.dart';
import '../../core/models/gasto_model.dart';

class GastoService {
  static const String gastoBoxName = "gastoBox";
  static bool _isHiveInitialized = false;

  // Inicializar Hive
  Future<void> initHive() async {
    if (!_isHiveInitialized) {
      await Hive.initFlutter();

      // Registrar adaptadores
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GastoModelAdapter());
      }

      // Abrir la caja de Hive
      await Hive.openBox<GastoModel>(gastoBoxName);

      _isHiveInitialized = true;
      print("✅ Hive inicializado y adaptadores registrados.");
    }
  }

  // Guardar un gasto en Hive
  Future<void> saveGasto(GastoModel gasto) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    await box.add(gasto); // Agregar el gasto a la caja
    print("✅ Gasto guardado en Hive: ${gasto.descripcion}");
  }

  // Obtener todos los gastos guardados
  List<GastoModel> getAllGastos() {
    final box = Hive.box<GastoModel>(gastoBoxName);
    return box.values.toList();
  }

  // Eliminar un gasto específico
  Future<void> deleteGasto(int id) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    final gastoKey = box.keys.firstWhere((key) => box.get(key)?.key == id, orElse: () => null);
    if (gastoKey != null) {
      await box.delete(gastoKey);
      print("🗑 Gasto eliminado de Hive con ID: $id");
    }
  }

  // Actualizar un gasto
  Future<void> updateGasto(int id, GastoModel updatedGasto) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    final gastoKey = box.keys.firstWhere((key) => box.get(key)?.key == id, orElse: () => null);
    if (gastoKey != null) {
      await box.put(gastoKey, updatedGasto);
      print("✅ Gasto actualizado con ID: $id");
    }
  }
}