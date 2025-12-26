import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestor_de_gastos_jc/core/models/prediction_model.dart';

class PredictionFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );
  final String _collection = 'predictions';

  // Crear nueva predicción
  Future<String> createPrediction(PredictionModel prediction) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(prediction.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear predicción: $e');
    }
  }

  // Obtener todas las predicciones de un usuario
  Stream<List<PredictionModel>> getPredictions(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener predicciones por tipo
  Stream<List<PredictionModel>> getPredictionsByType({
    required String userId,
    required String type,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy('predictionDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener predicciones futuras
  Stream<List<PredictionModel>> getFuturePredictions(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('predictionDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('predictionDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener predicciones por categoría
  Stream<List<PredictionModel>> getPredictionsByCategory({
    required String userId,
    required String category,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('predictionDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener predicción específica
  Future<PredictionModel?> getPredictionById(String predictionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(predictionId)
          .get();
      
      if (doc.exists) {
        return PredictionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener predicción: $e');
    }
  }

  // Obtener última predicción por tipo y categoría
  Future<PredictionModel?> getLatestPrediction({
    required String userId,
    required String type,
    String? category,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PredictionModel.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener última predicción: $e');
    }
  }

  // Actualizar predicción
  Future<void> updatePrediction(PredictionModel prediction) async {
    try {
      if (prediction.id == null) {
        throw Exception('ID de predicción no válido');
      }
      await _firestore
          .collection(_collection)
          .doc(prediction.id)
          .update(prediction.toMap());
    } catch (e) {
      throw Exception('Error al actualizar predicción: $e');
    }
  }

  // Eliminar predicción
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _firestore.collection(_collection).doc(predictionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar predicción: $e');
    }
  }

  // Eliminar predicciones antiguas
  Future<void> deleteOldPredictions({
    required String userId,
    required DateTime beforeDate,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(beforeDate))
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error al eliminar predicciones antiguas: $e');
    }
  }

  // Eliminar todas las predicciones de un usuario
  Future<void> deleteAllUserPredictions(String userId) async {
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
      throw Exception('Error al eliminar predicciones: $e');
    }
  }
}
