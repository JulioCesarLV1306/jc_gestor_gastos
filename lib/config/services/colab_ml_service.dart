import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para conectar con Google Colab y hacer predicciones ML
/// Este servicio envía datos a un notebook de Colab que ejecuta el modelo
class ColabMLService {
  // URL del notebook de Colab (se debe actualizar después de desplegar)
  String? _colabApiUrl;
  
  // Constructor
  ColabMLService({String? colabApiUrl}) : _colabApiUrl = colabApiUrl;

  /// Configurar la URL de la API de Colab
  void setColabApiUrl(String url) {
    _colabApiUrl = url;
    print('✅ URL de Colab configurada: $url');
  }

  /// Verificar si la API está configurada
  bool get isConfigured => _colabApiUrl != null && _colabApiUrl!.isNotEmpty;

  /// Entrenar modelo en Colab con datos de usuarios
  Future<Map<String, dynamic>> trainModel({
    required List<Map<String, dynamic>> trainingData,
    Map<String, dynamic>? modelConfig,
  }) async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada. Usa setColabApiUrl() primero.');
    }

    try {
      print('🚀 Enviando datos de entrenamiento a Colab...');
      print('📊 Registros: ${trainingData.length}');

      final response = await http.post(
        Uri.parse('$_colabApiUrl/train'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'training_data': trainingData,
          'model_config': modelConfig ?? {
            'algorithm': 'random_forest',
            'n_estimators': 100,
            'max_depth': 10,
          },
        }),
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('Timeout: El entrenamiento tardó más de 5 minutos');
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Modelo entrenado exitosamente');
        print('📈 Accuracy: ${result['accuracy']}');
        return result;
      } else {
        throw Exception('Error en entrenamiento: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error al entrenar modelo en Colab: $e');
      rethrow;
    }
  }

  /// Predecir gastos futuros para un usuario
  Future<Map<String, dynamic>> predictExpenses({
    required String userId,
    required List<Map<String, dynamic>> historicalData,
    required String category,
    int daysToPredict = 30,
  }) async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada. Usa setColabApiUrl() primero.');
    }

    try {
      print('🔮 Solicitando predicción a Colab...');
      print('👤 Usuario: $userId');
      print('📁 Categoría: $category');
      print('📅 Días a predecir: $daysToPredict');

      final response = await http.post(
        Uri.parse('$_colabApiUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'historical_data': historicalData,
          'category': category,
          'days_to_predict': daysToPredict,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La predicción tardó más de 30 segundos');
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Predicción recibida');
        print('💰 Gasto predicho: \$${result['predicted_amount']}');
        print('📊 Confianza: ${result['confidence']}%');
        return result;
      } else {
        throw Exception('Error en predicción: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener predicción de Colab: $e');
      rethrow;
    }
  }

  /// Predecir gastos por múltiples categorías
  Future<Map<String, dynamic>> predictMultipleCategories({
    required String userId,
    required List<Map<String, dynamic>> historicalData,
    required List<String> categories,
    int daysToPredict = 30,
  }) async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada. Usa setColabApiUrl() primero.');
    }

    try {
      print('🔮 Solicitando predicciones múltiples a Colab...');
      print('👤 Usuario: $userId');
      print('📁 Categorías: ${categories.join(", ")}');

      final response = await http.post(
        Uri.parse('$_colabApiUrl/predict_multiple'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'historical_data': historicalData,
          'categories': categories,
          'days_to_predict': daysToPredict,
        }),
      ).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw Exception('Timeout: Las predicciones tardaron más de 2 minutos');
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Predicciones múltiples recibidas');
        return result;
      } else {
        throw Exception('Error en predicciones múltiples: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener predicciones múltiples: $e');
      rethrow;
    }
  }

  /// Obtener métricas del modelo entrenado
  Future<Map<String, dynamic>> getModelMetrics() async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada. Usa setColabApiUrl() primero.');
    }

    try {
      print('📊 Obteniendo métricas del modelo...');

      final response = await http.get(
        Uri.parse('$_colabApiUrl/metrics'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al obtener métricas');
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Métricas obtenidas');
        return result;
      } else {
        throw Exception('Error al obtener métricas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener métricas: $e');
      rethrow;
    }
  }

  /// Verificar estado de la API de Colab
  Future<bool> checkApiHealth() async {
    if (!isConfigured) {
      print('⚠️ URL de Colab no configurada');
      return false;
    }

    try {
      print('🔍 Verificando conexión con Colab...');

      final response = await http.get(
        Uri.parse('$_colabApiUrl/health'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout al verificar conexión');
        },
      );

      if (response.statusCode == 200) {
        print('✅ Colab API está activa');
        return true;
      } else {
        print('⚠️ Colab API respondió con código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error al verificar Colab API: $e');
      return false;
    }
  }

  /// Enviar feedback sobre una predicción
  Future<void> sendPredictionFeedback({
    required String predictionId,
    required double actualAmount,
    required double predictedAmount,
  }) async {
    if (!isConfigured) return;

    try {
      await http.post(
        Uri.parse('$_colabApiUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prediction_id': predictionId,
          'actual_amount': actualAmount,
          'predicted_amount': predictedAmount,
          'error': (actualAmount - predictedAmount).abs(),
        }),
      );

      print('✅ Feedback enviado al modelo');
    } catch (e) {
      print('⚠️ Error al enviar feedback: $e');
    }
  }

  /// Obtener recomendaciones personalizadas basadas en ML
  Future<Map<String, dynamic>> getMLRecommendations({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada');
    }

    try {
      print('💡 Obteniendo recomendaciones ML para usuario: $userId');

      final response = await http.post(
        Uri.parse('$_colabApiUrl/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'user_data': userData,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Recomendaciones ML recibidas');
        return result;
      } else {
        throw Exception('Error al obtener recomendaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener recomendaciones ML: $e');
      rethrow;
    }
  }

  /// Detectar anomalías en gastos
  Future<Map<String, dynamic>> detectAnomalies({
    required String userId,
    required List<Map<String, dynamic>> recentExpenses,
  }) async {
    if (!isConfigured) {
      throw Exception('URL de Colab no configurada');
    }

    try {
      print('🔍 Detectando anomalías en gastos...');

      final response = await http.post(
        Uri.parse('$_colabApiUrl/detect_anomalies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'expenses': recentExpenses,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Análisis de anomalías completado');
        if (result['anomalies_found'] > 0) {
          print('⚠️ Se encontraron ${result['anomalies_found']} anomalías');
        }
        return result;
      } else {
        throw Exception('Error al detectar anomalías: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al detectar anomalías: $e');
      rethrow;
    }
  }
}
