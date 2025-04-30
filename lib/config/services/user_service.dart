import 'package:hive_flutter/adapters.dart';

class UserService {
  static const String userBoxName = "userBox";
  static bool _isHiveInitialized = false;

  // Inicializar Hive
  Future<void> initHive() async {
    if (!_isHiveInitialized) {
      await Hive.initFlutter();

      // Abrir la caja de Hive
      await Hive.openBox(userBoxName);

      _isHiveInitialized = true;
      print("✅ Hive inicializado para UserService.");
    }
  }

  // Guardar datos del usuario
  Future<void> saveUserData(String key, dynamic value) async {
    final box = Hive.box(userBoxName);
    await box.put(key, value);
    print("✅ Dato guardado en Hive: $key = $value");
  }

  // Obtener datos del usuario
  dynamic getUserData(String key) {
    final box = Hive.box(userBoxName);
    
    return box.get(key);
  }

  // Eliminar un dato específico del usuario
  Future<void> deleteUserData(String key) async {
    final box = Hive.box(userBoxName);
    await box.delete(key);
    print("🗑 Dato eliminado de Hive: $key");
  }

  // Limpiar todos los datos del usuario
  Future<void> clearUserData() async {
    final box = Hive.box(userBoxName);
    await box.clear();
    print("🗑 Todos los datos del usuario han sido eliminados.");
  }

  // Verificar si una clave existe
  bool containsKey(String key) {
    final box = Hive.box(userBoxName);
    return box.containsKey(key);
  }
}