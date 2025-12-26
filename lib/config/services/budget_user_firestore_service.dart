import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Servicio para gestionar el presupuesto del usuario en Firestore
/// Guarda: presupuesto mensual, meta de ahorro, saldo restante, gastos totales y ahorro recomendado
class BudgetUserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  /// Guardar o actualizar el presupuesto del usuario
  Future<void> saveBudgetData({
    required String userId,
    required double presupuestoGeneral,
    required double saldoRestante,
    required double ahorro,
    required double metaAhorro,
    required int semanasMetaAhorro,
  }) async {
    try {
      print('💾 Guardando presupuesto en Firestore para usuario: $userId');
      
      // Calcular gastos totales
      final gastosTotales = presupuestoGeneral - saldoRestante;
      
      await _firestore.collection('users').doc(userId).collection('budget').doc('current').set({
        'presupuestoGeneral': presupuestoGeneral,
        'saldoRestante': saldoRestante,
        'gastosTotales': gastosTotales,
        'ahorroRecomendado': ahorro,
        'metaAhorro': metaAhorro,
        'semanasMetaAhorro': semanasMetaAhorro,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Presupuesto guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar presupuesto en Firestore: $e');
      rethrow;
    }
  }

  /// Obtener el presupuesto del usuario desde Firestore
  Future<Map<String, dynamic>?> getBudgetData(String userId) async {
    try {
      print('📥 Obteniendo presupuesto desde Firestore para usuario: $userId');
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budget')
          .doc('current')
          .get();
      
      if (doc.exists) {
        print('✅ Presupuesto obtenido desde Firestore');
        return doc.data();
      } else {
        print('⚠️ No hay presupuesto guardado en Firestore para este usuario');
        return null;
      }
    } catch (e) {
      print('❌ Error al obtener presupuesto desde Firestore: $e');
      return null;
    }
  }

  /// Actualizar solo el saldo restante y gastos totales
  Future<void> updateBalance({
    required String userId,
    required double saldoRestante,
    required double presupuestoGeneral,
  }) async {
    try {
      final gastosTotales = presupuestoGeneral - saldoRestante;
      
      await _firestore.collection('users').doc(userId).collection('budget').doc('current').update({
        'saldoRestante': saldoRestante,
        'gastosTotales': gastosTotales,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Saldo actualizado en Firestore');
    } catch (e) {
      print('❌ Error al actualizar saldo en Firestore: $e');
      rethrow;
    }
  }

  /// Sincronizar presupuesto desde Firestore a Hive (al iniciar la app)
  Future<void> syncBudgetFromFirestore(String userId) async {
    try {
      print('🔄 Sincronizando presupuesto desde Firestore...');
      final budgetData = await getBudgetData(userId);
      
      if (budgetData != null) {
        print('✅ Presupuesto sincronizado desde Firestore');
        // Los datos se retornan para que el ProviderHome los use
      } else {
        print('ℹ️ No hay datos de presupuesto para sincronizar');
      }
    } catch (e) {
      print('❌ Error al sincronizar presupuesto: $e');
    }
  }

  /// Eliminar el presupuesto del usuario
  Future<void> deleteBudgetData(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budget')
          .doc('current')
          .delete();
      
      print('✅ Presupuesto eliminado de Firestore');
    } catch (e) {
      print('❌ Error al eliminar presupuesto de Firestore: $e');
      rethrow;
    }
  }

  /// Obtener stream en tiempo real del presupuesto
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBudgetStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('current')
        .snapshots();
  }
}
