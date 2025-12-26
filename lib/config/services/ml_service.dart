import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestor_de_gastos_jc/config/services/expense_firestore_service.dart';
import 'package:gestor_de_gastos_jc/config/services/budget_firestore_service.dart';
import 'package:gestor_de_gastos_jc/config/services/prediction_firestore_service.dart';
import 'package:gestor_de_gastos_jc/core/models/prediction_model.dart';

/// Servicio para Machine Learning
/// Este servicio preparará los datos para entrenar modelos y generar predicciones
/// En el futuro se integrará con Firebase ML Kit o TensorFlow Lite
class MLService {
  final ExpenseService _expenseService = ExpenseService();
  final BudgetFirestoreService _budgetService = BudgetFirestoreService();
  final PredictionFirestoreService _predictionService = PredictionFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  /// Exportar datos de entrenamiento
  /// Recopila datos históricos de gastos para entrenar el modelo
  Future<Map<String, dynamic>> exportTrainingData({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      // Obtener datos de gastos
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      List<Map<String, dynamic>> expenses = expensesSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // Obtener presupuestos
      final budgetsSnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> budgets = budgetsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // Calcular estadísticas
      Map<String, double> categoryTotals = {};
      double totalExpenses = 0;

      for (var expense in expenses) {
        String category = expense['category'] ?? 'Sin categoría';
        double amount = (expense['amount'] ?? 0).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        totalExpenses += amount;
      }

      return {
        'userId': userId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'expenses': expenses,
        'budgets': budgets,
        'statistics': {
          'totalExpenses': totalExpenses,
          'expenseCount': expenses.length,
          'categoryTotals': categoryTotals,
          'averageExpense': expenses.isEmpty ? 0 : totalExpenses / expenses.length,
        },
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error al exportar datos de entrenamiento: $e');
    }
  }

  /// Generar predicción simple basada en datos históricos
  /// Esto es una implementación básica que será reemplazada por un modelo ML real
  Future<PredictionModel> generateExpensePrediction({
    required String userId,
    required String category,
    int daysToPredict = 30,
  }) async {
    try {
      // Obtener gastos de los últimos 90 días
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 90));

      final expensesTotal = await _expenseService.getTotalExpensesByPeriod(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final categoryExpenses = await _expenseService.getExpensesByCategories(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calcular promedio diario para la categoría
      double categoryTotal = categoryExpenses[category] ?? 0;
      double dailyAverage = categoryTotal / 90;
      
      // Predicción simple: promedio diario * días a predecir
      double predictedValue = dailyAverage * daysToPredict;
      
      // Calcular confianza basada en la cantidad de datos
      double confidence = categoryTotal > 0 ? 0.7 : 0.3;

      // Crear predicción
      final prediction = PredictionModel(
        userId: userId,
        type: 'expense',
        predictedValue: predictedValue,
        category: category,
        predictionDate: DateTime.now().add(Duration(days: daysToPredict)),
        confidence: confidence,
        metadata: {
          'method': 'simple_average',
          'historicalDays': 90,
          'dailyAverage': dailyAverage,
          'totalHistorical': categoryTotal,
        },
      );

      // Guardar predicción
      await _predictionService.createPrediction(prediction);

      return prediction;
    } catch (e) {
      throw Exception('Error al generar predicción: $e');
    }
  }

  /// Analizar patrones de gasto
  Future<Map<String, dynamic>> analyzeSpendingPatterns({
    required String userId,
    int days = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final categoryExpenses = await _expenseService.getExpensesByCategories(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Encontrar categoría con más gastos
      String? topCategory;
      double maxAmount = 0;
      categoryExpenses.forEach((category, amount) {
        if (amount > maxAmount) {
          maxAmount = amount;
          topCategory = category;
        }
      });

      // Calcular total
      double total = categoryExpenses.values.fold(0, (sum, amount) => sum + amount);

      return {
        'period': {
          'days': days,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        'totalExpenses': total,
        'averageDaily': total / days,
        'topCategory': topCategory,
        'topCategoryAmount': maxAmount,
        'categoryBreakdown': categoryExpenses,
        'categoriesCount': categoryExpenses.length,
      };
    } catch (e) {
      throw Exception('Error al analizar patrones: $e');
    }
  }

  /// Generar recomendaciones de ahorro
  Future<Map<String, dynamic>> generateSavingsRecommendations({
    required String userId,
  }) async {
    try {
      final analysis = await analyzeSpendingPatterns(userId: userId);
      
      double totalExpenses = analysis['totalExpenses'];
      double averageDaily = analysis['averageDaily'];
      Map<String, double> categoryBreakdown = 
          Map<String, double>.from(analysis['categoryBreakdown']);

      List<Map<String, dynamic>> recommendations = [];

      // Regla 50/30/20: 20% para ahorros
      double recommendedSavings = totalExpenses * 0.20;
      recommendations.add({
        'type': 'savings_goal',
        'title': 'Regla 50/30/20',
        'description': 'Ahorra al menos el 20% de tus gastos',
        'suggestedAmount': recommendedSavings,
        'priority': 'high',
      });

      // Analizar categorías con gastos altos
      categoryBreakdown.forEach((category, amount) {
        double percentage = (amount / totalExpenses) * 100;
        if (percentage > 30) {
          recommendations.add({
            'type': 'reduce_spending',
            'title': 'Reducir gastos en $category',
            'description': 'Esta categoría representa ${percentage.toStringAsFixed(1)}% de tus gastos',
            'currentAmount': amount,
            'suggestedReduction': amount * 0.1, // 10% de reducción
            'priority': 'medium',
          });
        }
      });

      return {
        'userId': userId,
        'totalExpenses': totalExpenses,
        'recommendedMonthlySavings': recommendedSavings,
        'recommendations': recommendations,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error al generar recomendaciones: $e');
    }
  }

  /// Preparar datos para exportar a formato de entrenamiento ML
  /// Formato compatible con modelos de ML fuera de Firebase
  String exportToCSV(Map<String, dynamic> trainingData) {
    List<Map<String, dynamic>> expenses = 
        List<Map<String, dynamic>>.from(trainingData['expenses']);

    if (expenses.isEmpty) return '';

    // Encabezados
    String csv = 'date,amount,category,isRecurrent,dayOfWeek,month,year\n';

    // Datos
    for (var expense in expenses) {
      Timestamp timestamp = expense['date'];
      DateTime date = timestamp.toDate();
      
      csv += '${date.toIso8601String()},';
      csv += '${expense['amount']},';
      csv += '${expense['category']},';
      csv += '${expense['isRecurrent'] ?? false},';
      csv += '${date.weekday},';
      csv += '${date.month},';
      csv += '${date.year}\n';
    }

    return csv;
  }

  /// Exportar como JSON para modelos externos
  String exportToJSON(Map<String, dynamic> trainingData) {
    return jsonEncode(trainingData);
  }
}
