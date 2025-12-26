import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Servicio para entrenar modelos de Machine Learning con datos de múltiples usuarios
/// Utiliza datos agregados de 50+ usuarios para mejorar predicciones
class MLTrainingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  /// Recopilar datos de entrenamiento de todos los usuarios
  /// Esto recopila gastos, presupuestos y patrones de ahorro de múltiples usuarios
  Future<Map<String, dynamic>> collectTrainingDataFromAllUsers({
    int maxUsers = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📊 Iniciando recopilación de datos de entrenamiento...');
      print('👥 Usuarios a analizar: $maxUsers');
      
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      // 1. Obtener lista de usuarios
      final usersSnapshot = await _firestore
          .collection('users')
          .limit(maxUsers)
          .get();

      print('✅ Usuarios encontrados: ${usersSnapshot.docs.length}');

      List<Map<String, dynamic>> allExpenses = [];
      List<Map<String, dynamic>> allBudgets = [];
      Map<String, dynamic> userPatterns = {};
      
      int processedUsers = 0;
      int totalExpenses = 0;
      int totalBudgets = 0;

      // 2. Recopilar datos de cada usuario
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        print('🔄 Procesando usuario: $userId');

        try {
          // Obtener gastos del usuario
          final expensesSnapshot = await _firestore
              .collection('expenses')
              .where('userId', isEqualTo: userId)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate!))
              .get();

          // Obtener presupuesto del usuario
          final budgetSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('budget')
              .doc('current')
              .get();

          // Agregar datos de gastos
          for (var expense in expensesSnapshot.docs) {
            final data = expense.data();
            allExpenses.add({
              'userId': userId,
              'amount': data['amount'],
              'category': data['category'],
              'date': data['date'],
              'description': data['description'],
            });
          }

          // Agregar datos de presupuesto
          if (budgetSnapshot.exists) {
            final budgetData = budgetSnapshot.data();
            allBudgets.add({
              'userId': userId,
              'presupuestoGeneral': budgetData?['presupuestoGeneral'],
              'ahorroRecomendado': budgetData?['ahorroRecomendado'],
              'metaAhorro': budgetData?['metaAhorro'],
              'gastosTotales': budgetData?['gastosTotales'],
            });
          }

          // Calcular patrones del usuario
          userPatterns[userId] = await _calculateUserPatterns(
            userId,
            expensesSnapshot.docs,
            budgetSnapshot.exists ? budgetSnapshot.data() : null,
          );

          processedUsers++;
          totalExpenses += expensesSnapshot.docs.length;
          totalBudgets += budgetSnapshot.exists ? 1 : 0;

        } catch (e) {
          print('⚠️ Error procesando usuario $userId: $e');
          continue;
        }
      }

      print('═══════════════════════════════════════');
      print('✅ RECOPILACIÓN COMPLETADA');
      print('═══════════════════════════════════════');
      print('👥 Usuarios procesados: $processedUsers');
      print('💰 Total de gastos: $totalExpenses');
      print('💼 Presupuestos recopilados: $totalBudgets');
      print('═══════════════════════════════════════');

      // 3. Calcular estadísticas agregadas
      final aggregatedStats = _calculateAggregatedStatistics(
        allExpenses,
        allBudgets,
        userPatterns,
      );

      return {
        'metadata': {
          'usersProcessed': processedUsers,
          'totalExpenses': totalExpenses,
          'totalBudgets': totalBudgets,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'collectedAt': DateTime.now().toIso8601String(),
        },
        'rawData': {
          'expenses': allExpenses,
          'budgets': allBudgets,
        },
        'userPatterns': userPatterns,
        'aggregatedStatistics': aggregatedStats,
      };
    } catch (e) {
      print('❌ Error al recopilar datos de entrenamiento: $e');
      rethrow;
    }
  }

  /// Calcular patrones individuales de un usuario
  Future<Map<String, dynamic>> _calculateUserPatterns(
    String userId,
    List<QueryDocumentSnapshot> expenses,
    Map<String, dynamic>? budget,
  ) async {
    if (expenses.isEmpty) {
      return {'hasData': false};
    }

    // Calcular por categoría
    Map<String, double> categoryTotals = {};
    Map<String, int> categoryFrequency = {};
    double totalAmount = 0;

    for (var expense in expenses) {
      final data = expense.data() as Map<String, dynamic>;
      String category = data['category'] ?? 'Sin categoría';
      double amount = (data['amount'] ?? 0).toDouble();

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
      totalAmount += amount;
    }

    // Encontrar categoría dominante
    String? topCategory;
    double maxAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topCategory = category;
      }
    });

    // Calcular ratio de ahorro si hay presupuesto
    double? savingsRatio;
    if (budget != null && budget['presupuestoGeneral'] != null) {
      double presupuesto = (budget['presupuestoGeneral'] as num).toDouble();
      double ahorro = (budget['ahorroRecomendado'] as num?)?.toDouble() ?? 0;
      savingsRatio = presupuesto > 0 ? ahorro / presupuesto : 0;
    }

    return {
      'hasData': true,
      'totalExpenses': totalAmount,
      'expenseCount': expenses.length,
      'averageExpense': totalAmount / expenses.length,
      'categoryTotals': categoryTotals,
      'categoryFrequency': categoryFrequency,
      'topCategory': topCategory,
      'topCategoryAmount': maxAmount,
      'savingsRatio': savingsRatio,
      'budgetUtilization': budget != null && budget['presupuestoGeneral'] != null
          ? totalAmount / (budget['presupuestoGeneral'] as num).toDouble()
          : null,
    };
  }

  /// Calcular estadísticas agregadas de todos los usuarios
  Map<String, dynamic> _calculateAggregatedStatistics(
    List<Map<String, dynamic>> allExpenses,
    List<Map<String, dynamic>> allBudgets,
    Map<String, dynamic> userPatterns,
  ) {
    // Estadísticas de gastos
    Map<String, List<double>> categoryAmounts = {};
    Map<String, int> categoryFrequency = {};
    List<double> allAmounts = [];

    for (var expense in allExpenses) {
      String category = expense['category'] ?? 'Sin categoría';
      double amount = (expense['amount'] ?? 0).toDouble();

      categoryAmounts.putIfAbsent(category, () => []);
      categoryAmounts[category]!.add(amount);
      categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
      allAmounts.add(amount);
    }

    // Calcular promedios por categoría
    Map<String, double> categoryAverages = {};
    Map<String, double> categoryMedians = {};
    categoryAmounts.forEach((category, amounts) {
      categoryAverages[category] = amounts.reduce((a, b) => a + b) / amounts.length;
      amounts.sort();
      categoryMedians[category] = amounts[amounts.length ~/ 2];
    });

    // Estadísticas de presupuestos
    List<double> budgetAmounts = [];
    List<double> savingsRatios = [];
    for (var budget in allBudgets) {
      if (budget['presupuestoGeneral'] != null) {
        budgetAmounts.add((budget['presupuestoGeneral'] as num).toDouble());
      }
      if (budget['ahorroRecomendado'] != null && budget['presupuestoGeneral'] != null) {
        double ahorro = (budget['ahorroRecomendado'] as num).toDouble();
        double presupuesto = (budget['presupuestoGeneral'] as num).toDouble();
        savingsRatios.add(ahorro / presupuesto);
      }
    }

    // Calcular percentiles
    allAmounts.sort();
    double p25 = allAmounts.isNotEmpty ? allAmounts[allAmounts.length ~/ 4] : 0;
    double p50 = allAmounts.isNotEmpty ? allAmounts[allAmounts.length ~/ 2] : 0;
    double p75 = allAmounts.isNotEmpty ? allAmounts[(allAmounts.length * 3) ~/ 4] : 0;

    return {
      'expenses': {
        'total': allAmounts.fold<double>(0, (sum, amount) => sum + amount),
        'count': allAmounts.length,
        'average': allAmounts.isNotEmpty 
            ? allAmounts.reduce((a, b) => a + b) / allAmounts.length 
            : 0,
        'median': p50,
        'percentile25': p25,
        'percentile75': p75,
        'categoryAverages': categoryAverages,
        'categoryMedians': categoryMedians,
        'categoryFrequency': categoryFrequency,
      },
      'budgets': {
        'count': budgetAmounts.length,
        'averageBudget': budgetAmounts.isNotEmpty
            ? budgetAmounts.reduce((a, b) => a + b) / budgetAmounts.length
            : 0,
        'averageSavingsRatio': savingsRatios.isNotEmpty
            ? savingsRatios.reduce((a, b) => a + b) / savingsRatios.length
            : 0,
      },
      'patterns': {
        'usersWithData': userPatterns.values.where((p) => p['hasData'] == true).length,
        'mostCommonCategories': _getMostCommonCategories(categoryFrequency, 10),
      },
    };
  }

  /// Obtener las categorías más comunes
  List<Map<String, dynamic>> _getMostCommonCategories(
    Map<String, int> frequencies,
    int limit,
  ) {
    var sorted = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((entry) => {
      'category': entry.key,
      'frequency': entry.value,
    }).toList();
  }

  /// Exportar datos de entrenamiento a formato CSV
  String exportTrainingDataToCSV(Map<String, dynamic> trainingData) {
    print('📝 Exportando datos a CSV...');
    
    List<Map<String, dynamic>> expenses = 
        List<Map<String, dynamic>>.from(trainingData['rawData']['expenses']);

    if (expenses.isEmpty) {
      print('⚠️ No hay datos para exportar');
      return '';
    }

    StringBuffer csv = StringBuffer();
    
    // Encabezados
    csv.writeln('userId,date,amount,category,dayOfWeek,month,year,hour');

    // Datos
    for (var expense in expenses) {
      try {
        Timestamp timestamp = expense['date'];
        DateTime date = timestamp.toDate();
        
        csv.write('${expense['userId']},');
        csv.write('${date.toIso8601String()},');
        csv.write('${expense['amount']},');
        csv.write('"${expense['category']}",');
        csv.write('${date.weekday},');
        csv.write('${date.month},');
        csv.write('${date.year},');
        csv.writeln('${date.hour}');
      } catch (e) {
        print('⚠️ Error al procesar gasto: $e');
        continue;
      }
    }

    print('✅ CSV generado con ${expenses.length} registros');
    return csv.toString();
  }

  /// Exportar estadísticas agregadas a JSON
  String exportAggregatedStatsToJSON(Map<String, dynamic> trainingData) {
    print('📝 Exportando estadísticas a JSON...');
    
    final stats = {
      'metadata': trainingData['metadata'],
      'aggregatedStatistics': trainingData['aggregatedStatistics'],
      'exportedAt': DateTime.now().toIso8601String(),
    };

    return jsonEncode(stats);
  }

  /// Generar dataset de entrenamiento completo
  /// Incluye features engineered para ML
  Future<Map<String, dynamic>> generateMLDataset({
    int maxUsers = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('🤖 Generando dataset para Machine Learning...');
    
    // Recopilar datos
    final trainingData = await collectTrainingDataFromAllUsers(
      maxUsers: maxUsers,
      startDate: startDate,
      endDate: endDate,
    );

    // Feature engineering
    List<Map<String, dynamic>> features = [];
    List<Map<String, dynamic>> expenses = 
        List<Map<String, dynamic>>.from(trainingData['rawData']['expenses']);

    for (var expense in expenses) {
      try {
        Timestamp timestamp = expense['date'];
        DateTime date = timestamp.toDate();
        double amount = (expense['amount'] ?? 0).toDouble();
        
        // Crear features
        features.add({
          'userId': expense['userId'],
          'amount': amount,
          'amount_log': amount > 0 ? (amount + 1).toDouble() : 0, // log transformation
          'category': expense['category'],
          'dayOfWeek': date.weekday,
          'month': date.month,
          'year': date.year,
          'hour': date.hour,
          'isWeekend': date.weekday >= 6 ? 1 : 0,
          'isMonthStart': date.day <= 7 ? 1 : 0,
          'isMonthEnd': date.day >= 23 ? 1 : 0,
          'quarter': ((date.month - 1) ~/ 3) + 1,
        });
      } catch (e) {
        print('⚠️ Error al generar features: $e');
        continue;
      }
    }

    print('✅ Dataset generado con ${features.length} registros');

    return {
      'features': features,
      'statistics': trainingData['aggregatedStatistics'],
      'metadata': trainingData['metadata'],
    };
  }

  /// Guardar modelo entrenado en Firestore
  Future<void> saveTrainedModel({
    required String modelName,
    required Map<String, dynamic> modelMetadata,
    required Map<String, dynamic> trainingStats,
  }) async {
    try {
      await _firestore.collection('ml_models').doc(modelName).set({
        'modelName': modelName,
        'version': modelMetadata['version'] ?? '1.0.0',
        'metadata': modelMetadata,
        'trainingStats': trainingStats,
        'trainedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      print('✅ Modelo guardado en Firestore: $modelName');
    } catch (e) {
      print('❌ Error al guardar modelo: $e');
      rethrow;
    }
  }

  /// Obtener recomendaciones basadas en patrones agregados
  Future<Map<String, dynamic>> getPersonalizedRecommendations({
    required String userId,
  }) async {
    try {
      print('💡 Generando recomendaciones personalizadas para: $userId');
      
      // Obtener patrones del usuario
      final userExpenses = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      // Obtener modelo entrenado
      final modelDoc = await _firestore
          .collection('ml_models')
          .doc('expense_predictor')
          .get();

      if (!modelDoc.exists) {
        print('⚠️ No hay modelo entrenado disponible');
        return {'recommendations': [], 'hasModel': false};
      }

      final modelStats = modelDoc.data()?['trainingStats'];
      final categoryAverages = modelStats?['expenses']?['categoryAverages'] ?? {};

      // Generar recomendaciones
      List<Map<String, dynamic>> recommendations = [];

      // Comparar con promedios agregados
      Map<String, double> userCategoryTotals = {};
      for (var expense in userExpenses.docs) {
        final data = expense.data();
        String category = data['category'] ?? 'Sin categoría';
        double amount = (data['amount'] ?? 0).toDouble();
        userCategoryTotals[category] = (userCategoryTotals[category] ?? 0) + amount;
      }

      userCategoryTotals.forEach((category, userTotal) {
        double avgTotal = (categoryAverages[category] ?? 0).toDouble();
        if (avgTotal > 0 && userTotal > avgTotal * 1.5) {
          recommendations.add({
            'type': 'reduce_spending',
            'category': category,
            'userSpending': userTotal,
            'averageSpending': avgTotal,
            'message': 'Gastas ${((userTotal / avgTotal - 1) * 100).toStringAsFixed(0)}% más que el promedio en $category',
            'priority': 'high',
          });
        }
      });

      return {
        'userId': userId,
        'recommendations': recommendations,
        'hasModel': true,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error al generar recomendaciones: $e');
      return {'recommendations': [], 'error': e.toString()};
    }
  }
}
