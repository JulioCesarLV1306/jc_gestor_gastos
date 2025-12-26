import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestor_de_gastos_jc/core/models/saving_model.dart';

class SavingFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );
  final String _collection = 'savings';

  // Crear nueva meta de ahorro
  Future<String> createSaving(SavingModel saving) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(saving.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear meta de ahorro: $e');
    }
  }

  // Obtener todas las metas de ahorro de un usuario
  Stream<List<SavingModel>> getSavings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener metas activas (no completadas)
  Stream<List<SavingModel>> getActiveSavings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingModel.fromMap(doc.data(), doc.id))
            .where((saving) => saving.currentAmount < saving.targetAmount)
            .toList());
  }

  // Obtener metas completadas
  Stream<List<SavingModel>> getCompletedSavings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingModel.fromMap(doc.data(), doc.id))
            .where((saving) => saving.currentAmount >= saving.targetAmount)
            .toList());
  }

  // Obtener una meta específica
  Future<SavingModel?> getSavingById(String savingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(savingId)
          .get();
      
      if (doc.exists) {
        return SavingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener meta de ahorro: $e');
    }
  }

  // Actualizar meta de ahorro
  Future<void> updateSaving(SavingModel saving) async {
    try {
      if (saving.id == null) {
        throw Exception('ID de ahorro no válido');
      }
      await _firestore
          .collection(_collection)
          .doc(saving.id)
          .update(saving.toMap());
    } catch (e) {
      throw Exception('Error al actualizar meta de ahorro: $e');
    }
  }

  // Agregar monto al ahorro
  Future<void> addAmountToSaving({
    required String savingId,
    required double amount,
  }) async {
    try {
      await _firestore.collection(_collection).doc(savingId).update({
        'currentAmount': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception('Error al agregar monto: $e');
    }
  }

  // Retirar monto del ahorro
  Future<void> subtractAmountFromSaving({
    required String savingId,
    required double amount,
  }) async {
    try {
      await _firestore.collection(_collection).doc(savingId).update({
        'currentAmount': FieldValue.increment(-amount),
      });
    } catch (e) {
      throw Exception('Error al retirar monto: $e');
    }
  }

  // Eliminar meta de ahorro
  Future<void> deleteSaving(String savingId) async {
    try {
      await _firestore.collection(_collection).doc(savingId).delete();
    } catch (e) {
      throw Exception('Error al eliminar meta de ahorro: $e');
    }
  }

  // Obtener total de ahorros del usuario
  Future<double> getTotalSavings(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['currentAmount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total de ahorros: $e');
    }
  }

  // Obtener progreso general de ahorros
  Future<double> getOverallProgress(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      double totalCurrent = 0;
      double totalTarget = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalCurrent += (data['currentAmount'] ?? 0).toDouble();
        totalTarget += (data['targetAmount'] ?? 0).toDouble();
      }

      if (totalTarget == 0) return 0;
      return (totalCurrent / totalTarget * 100).clamp(0, 100);
    } catch (e) {
      throw Exception('Error al calcular progreso: $e');
    }
  }

  // Eliminar todas las metas de ahorro de un usuario
  Future<void> deleteAllUserSavings(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error al eliminar metas de ahorro: $e');
    }
  }
}
