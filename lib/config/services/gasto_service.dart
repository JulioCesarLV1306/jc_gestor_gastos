import 'package:hive_flutter/adapters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/models/gasto_model.dart';

class GastoService {
  static const String gastoBoxName = "gastoBox";
  static bool _isHiveInitialized = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

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

  // Guardar un gasto en Hive y Firestore
  Future<void> saveGasto(GastoModel gasto) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    
    // Guardar en Hive primero (más rápido)
    await box.add(gasto);
    print("✅ Gasto guardado en Hive: ${gasto.descripcion}");
    
    // Guardar en Firestore en segundo plano (no bloquear la UI)
    if (gasto.userId != null) {
      _saveToFirestoreAsync(gasto, box.values.toList().indexOf(gasto));
    }
  }

  // Guardar en Firestore de forma asíncrona sin bloquear
  Future<void> _saveToFirestoreAsync(GastoModel gasto, int hiveIndex) async {
    try {
      print('💾 Iniciando guardado en Firestore...');
      print('   📍 Usuario ID: ${gasto.userId}');
      print('   📝 Descripción: ${gasto.descripcion}');
      print('   💰 Cantidad: ${gasto.cantidad}');
      
      final docRef = await _firestore
          .collection('users')
          .doc(gasto.userId)
          .collection('gastos')
          .add(gasto.toMap())
          .timeout(
            const Duration(seconds: 15), // Más tiempo para web
            onTimeout: () => throw Exception('Timeout guardando gasto en Firestore'),
          );
      
      print('✅ Gasto guardado en Firestore con ID: ${docRef.id}');
      
      // Actualizar el ID de Firestore en Hive
      final box = Hive.box<GastoModel>(gastoBoxName);
      if (hiveIndex >= 0 && hiveIndex < box.length) {
        gasto.firestoreId = docRef.id;
        await box.putAt(hiveIndex, gasto);
        print('✅ ID de Firestore actualizado en Hive');
      }
    } catch (e, stackTrace) {
      print('⚠️ Error al guardar en Firestore: $e');
      print('📍 Stack trace: $stackTrace');
      // El gasto ya está en Hive, así que no hay pérdida de datos
    }
  }

  // Obtener todos los gastos guardados
  List<GastoModel> getAllGastos() {
    final box = Hive.box<GastoModel>(gastoBoxName);
    return box.values.toList();
  }

  // Eliminar un gasto específico de Hive y Firestore
  Future<void> deleteGasto(int id) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    final gastoKey = box.keys.firstWhere((key) => box.get(key)?.key == id, orElse: () => null);
    if (gastoKey != null) {
      final gasto = box.get(gastoKey);
      
      // Eliminar de Firestore si tiene ID
      if (gasto?.firestoreId != null && gasto?.userId != null) {
        try {
          print('🗑 Eliminando gasto de Firestore...');
          await _firestore
              .collection('users')
              .doc(gasto!.userId)
              .collection('gastos')
              .doc(gasto.firestoreId)
              .delete()
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => throw Exception('Timeout eliminando gasto de Firestore'),
              );
          print('✅ Gasto eliminado de Firestore');
        } catch (e) {
          print('⚠️ Error al eliminar de Firestore: $e');
        }
      }
      
      // Eliminar de Hive
      await box.delete(gastoKey);
      print("🗑 Gasto eliminado de Hive con ID: $id");
    }
  }

  // Actualizar un gasto en Hive y Firestore
  Future<void> updateGasto(int id, GastoModel updatedGasto) async {
    final box = Hive.box<GastoModel>(gastoBoxName);
    final gastoKey = box.keys.firstWhere((key) => box.get(key)?.key == id, orElse: () => null);
    if (gastoKey != null) {
      // Actualizar en Firestore si tiene ID
      if (updatedGasto.firestoreId != null && updatedGasto.userId != null) {
        try {
          print('💾 Actualizando gasto en Firestore...');
          await _firestore
              .collection('users')
              .doc(updatedGasto.userId)
              .collection('gastos')
              .doc(updatedGasto.firestoreId)
              .update(updatedGasto.toMap())
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => throw Exception('Timeout actualizando gasto en Firestore'),
              );
          print('✅ Gasto actualizado en Firestore');
        } catch (e) {
          print('⚠️ Error al actualizar en Firestore: $e');
        }
      }
      
      // Actualizar en Hive
      await box.put(gastoKey, updatedGasto);
      print("✅ Gasto actualizado en Hive con ID: $id");
    }
  }
  
  // Sincronizar gastos desde Firestore a Hive
  Future<void> syncGastosFromFirestore(String userId) async {
    try {
      print('🔄 Sincronizando gastos desde Firestore...');
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gastos')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout sincronizando gastos'),
          );
      
      final box = Hive.box<GastoModel>(gastoBoxName);
      
      for (var doc in snapshot.docs) {
        final gasto = GastoModel.fromMap(doc.data(), doc.id);
        
        // Verificar si ya existe en Hive
        final exists = box.values.any((g) => g.firestoreId == doc.id);
        if (!exists) {
          await box.add(gasto);
          print('✅ Gasto sincronizado: ${gasto.descripcion}');
        }
      }
      
      print('✅ Sincronización de gastos completada');
    } catch (e) {
      print('⚠️ Error al sincronizar gastos: $e');
    }
  }
}