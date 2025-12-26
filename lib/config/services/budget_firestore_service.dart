import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestor_de_gastos_jc/core/models/budget_model.dart';

class BudgetFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );
  final String _collection = 'budgets';

  // Crear nuevo presupuesto
  Future<String> createBudget(BudgetModel budget) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(budget.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear presupuesto: $e');
    }
  }

  // Obtener todos los presupuestos de un usuario
  Stream<List<BudgetModel>> getBudgets(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener presupuestos activos
  Stream<List<BudgetModel>> getActiveBudgets(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
              .where((budget) {
                // Filtrar presupuestos que no han expirado
                return budget.endDate == null || budget.endDate!.isAfter(now);
              })
              .toList();
        });
  }

  // Obtener presupuesto por categoría
  Future<BudgetModel?> getBudgetByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BudgetModel.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener presupuesto: $e');
    }
  }

  // Obtener un presupuesto específico
  Future<BudgetModel?> getBudgetById(String budgetId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(budgetId)
          .get();
      
      if (doc.exists) {
        return BudgetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener presupuesto: $e');
    }
  }

  // Actualizar presupuesto
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      if (budget.id == null) {
        throw Exception('ID de presupuesto no válido');
      }
      await _firestore
          .collection(_collection)
          .doc(budget.id)
          .update(budget.toMap());
    } catch (e) {
      throw Exception('Error al actualizar presupuesto: $e');
    }
  }

  // Eliminar presupuesto
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).delete();
    } catch (e) {
      throw Exception('Error al eliminar presupuesto: $e');
    }
  }

  // Obtener presupuesto total por período
  Future<double> getTotalBudgetByPeriod({
    required String userId,
    required String period,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('period', isEqualTo: period)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular presupuesto total: $e');
    }
  }

  // Verificar si existe presupuesto para una categoría
  Future<bool> hasBudgetForCategory({
    required String userId,
    required String category,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar presupuesto: $e');
    }
  }

  // Eliminar todos los presupuestos de un usuario
  Future<void> deleteAllUserBudgets(String userId) async {
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
      throw Exception('Error al eliminar presupuestos: $e');
    }
  }
}
