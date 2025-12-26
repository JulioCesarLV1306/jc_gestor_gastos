import 'package:hive_flutter/adapters.dart';
import 'package:gestor_de_gastos_jc/core/models/gasto_model.dart';

/// Clase de utilidad para acceder a las cajas de Hive de manera centralizada
class Boxes {
  /// Obtiene la caja de configuración general
  static Box<dynamic> get configBox => Hive.box('config');
  
  /// Obtiene la caja de gastos
  static Box<GastoModel> get gastoBox => Hive.box<GastoModel>('gastoBox');
  
  /// Obtiene la caja de usuarios
  static Box<dynamic> get userBox => Hive.box('userBox');
}
