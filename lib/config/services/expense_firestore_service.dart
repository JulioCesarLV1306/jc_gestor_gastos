import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestor_de_gastos_jc/core/models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );
  final String _collection = 'expenses';

  // Crear nuevo gasto
  Future<String> createExpense(ExpenseModel expense) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(expense.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear gasto: $e');
    }
  }

  // Obtener todos los gastos de un usuario
  Stream<List<ExpenseModel>> getExpenses(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener gastos por rango de fechas
  Stream<List<ExpenseModel>> getExpensesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener gastos por categoría
  Stream<List<ExpenseModel>> getExpensesByCategory({
    required String userId,
    required String category,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener un gasto específico
  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(expenseId)
          .get();
      
      if (doc.exists) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener gasto: $e');
    }
  }

  // Actualizar gasto
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      if (expense.id == null) {
        throw Exception('ID de gasto no válido');
      }
      await _firestore
          .collection(_collection)
          .doc(expense.id)
          .update(expense.toMap());
    } catch (e) {
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  // Eliminar gasto
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(_collection).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  // Obtener total de gastos por período
  Future<double> getTotalExpensesByPeriod({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total: $e');
    }
  }

  // Obtener gastos por categoría en un período
  Future<Map<String, double>> getExpensesByCategories({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, double> categorySums = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'Sin categoría';
        double amount = (data['amount'] ?? 0).toDouble();
        categorySums[category] = (categorySums[category] ?? 0) + amount;
      }
      return categorySums;
    } catch (e) {
      throw Exception('Error al obtener gastos por categoría: $e');
    }
  }

  // Eliminar todos los gastos de un usuario
  Future<void> deleteAllUserExpenses(String userId) async {
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
      throw Exception('Error al eliminar gastos: $e');
    }
  }
}
