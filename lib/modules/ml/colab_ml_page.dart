import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/colab_ml_service.dart';
import 'package:gestor_de_gastos_jc/config/services/ml_training_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_de_gastos_jc/bd/boxes.dart';

class ColabMLPage extends StatefulWidget {
  const ColabMLPage({Key? key}) : super(key: key);

  @override
  State<ColabMLPage> createState() => _ColabMLPageState();
}

class _ColabMLPageState extends State<ColabMLPage> {
  final ColabMLService _colabService = ColabMLService();
  final MLTrainingService _trainingService = MLTrainingService();
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isConnected = false;
  bool _isTraining = false;
  bool _isPredicting = false;
  
  Map<String, dynamic>? _trainingResult;
  Map<String, dynamic>? _predictionResult;
  Map<String, dynamic>? _metricsResult;
  Map<String, dynamic>? _anomaliesResult;
  
  int _maxUsers = 50;
  int _daysToPredict = 30;

  @override
  void initState() {
    super.initState();
    // Cargar URL guardada si existe
    final savedUrl = Boxes.configBox.get('colab_api_url');
    if (savedUrl != null) {
      _urlController.text = savedUrl;
      _colabService.setColabApiUrl(savedUrl);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    
    try {
      final isHealthy = await _colabService.checkApiHealth();
      
      setState(() {
        _isConnected = isHealthy;
        _isLoading = false;
      });

      if (isHealthy) {
        // Guardar URL
        await Boxes.configBox.put('colab_api_url', _urlController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Conectado a Colab exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo conectar con Colab'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _trainModel() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Primero conecta con Colab'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isTraining = true);

    try {
      // Recopilar datos de entrenamiento
      final collectedData = await _trainingService.collectTrainingDataFromAllUsers(
        maxUsers: _maxUsers,
      );

      final expenses = collectedData['expenses'] as List;
      
      // Preparar datos para Colab
      final trainingData = expenses.map((expense) {
        return {
          'userId': expense['userId'],
          'fecha': expense['fecha'],
          'monto': expense['monto'],
          'categoria': expense['categoria'],
        };
      }).toList();

      // Enviar a Colab para entrenar
      final result = await _colabService.trainModel(
        trainingData: trainingData,
        modelConfig: {
          'algorithm': 'random_forest',
          'n_estimators': 100,
          'max_depth': 10,
        },
      );

      setState(() {
        _trainingResult = result;
        _isTraining = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Modelo entrenado exitosamente en Colab'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Obtener métricas
      _getMetrics();
      
    } catch (e) {
      setState(() => _isTraining = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al entrenar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _predictExpenses() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Primero conecta con Colab'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPredicting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      // Obtener gastos históricos del usuario
      final gastos = Boxes.gastoBox.values.where((g) => g.userId == userId).toList();
      
      final historicalData = gastos.map((gasto) {
        return {
          'userId': userId,
          'fecha': gasto.fecha.toIso8601String(),
          'monto': gasto.cantidad,
          'categoria': gasto.categoria,
        };
      }).toList();

      // Solicitar predicción a Colab
      final result = await _colabService.predictExpenses(
        userId: userId,
        historicalData: historicalData,
        category: 'Todas',
        daysToPredict: _daysToPredict,
      );

      setState(() {
        _predictionResult = result;
        _isPredicting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Predicción completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      setState(() => _isPredicting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al predecir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _detectAnomalies() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Primero conecta con Colab'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final gastos = Boxes.gastoBox.values.where((g) => g.userId == userId).toList();
      
      // Tomar últimos 30 gastos
      final recentExpenses = gastos
          .take(30)
          .map((gasto) => {
                'userId': userId,
                'fecha': gasto.fecha.toIso8601String(),
                'monto': gasto.cantidad,
                'categoria': gasto.categoria,
              })
          .toList();

      final result = await _colabService.detectAnomalies(
        userId: userId,
        recentExpenses: recentExpenses,
      );

      setState(() {
        _anomaliesResult = result;
        _isLoading = false;
      });

      if (mounted) {
        final anomaliesCount = result['anomalies_found'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              anomaliesCount > 0
                  ? '⚠️ Se encontraron $anomaliesCount anomalías'
                  : '✅ No se encontraron anomalías',
            ),
            backgroundColor: anomaliesCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al detectar anomalías: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getMetrics() async {
    if (!_isConnected) return;

    try {
      final metrics = await _colabService.getModelMetrics();
      setState(() => _metricsResult = metrics);
    } catch (e) {
      print('Error al obtener métricas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción ML con Colab'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de conexión
            _buildConnectionSection(),
            const SizedBox(height: 24),

            // Sección de entrenamiento
            if (_isConnected) _buildTrainingSection(),
            const SizedBox(height: 24),

            // Sección de predicción
            if (_isConnected && _trainingResult != null) _buildPredictionSection(),
            const SizedBox(height: 24),

            // Sección de anomalías
            if (_isConnected && _trainingResult != null) _buildAnomaliesSection(),
            const SizedBox(height: 24),

            // Resultados
            if (_trainingResult != null) _buildTrainingResults(),
            if (_metricsResult != null) _buildMetricsResults(),
            if (_predictionResult != null) _buildPredictionResults(),
            if (_anomaliesResult != null) _buildAnomaliesResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conexión a Google Colab',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL de Ngrok',
                hintText: 'https://xxxx.ngrok.io',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (value) {
                _colabService.setColabApiUrl(value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkConnection,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi),
              label: Text(_isLoading ? 'Conectando...' : 'Verificar Conexión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            if (_isConnected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Conectado exitosamente a Colab'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎓 Entrenar Modelo ML',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Cantidad de usuarios: $_maxUsers'),
            Slider(
              value: _maxUsers.toDouble(),
              min: 10,
              max: 100,
              divisions: 18,
              label: '$_maxUsers usuarios',
              onChanged: (value) {
                setState(() => _maxUsers = value.toInt());
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTraining ? null : _trainModel,
              icon: _isTraining
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.model_training),
              label: Text(_isTraining ? 'Entrenando...' : 'Entrenar Modelo en Colab'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔮 Predecir Gastos Futuros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Días a predecir: $_daysToPredict'),
            Slider(
              value: _daysToPredict.toDouble(),
              min: 7,
              max: 90,
              divisions: 11,
              label: '$_daysToPredict días',
              onChanged: (value) {
                setState(() => _daysToPredict = value.toInt());
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isPredicting ? null : _predictExpenses,
              icon: _isPredicting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics),
              label: Text(_isPredicting ? 'Prediciendo...' : 'Obtener Predicción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomaliesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔍 Detectar Anomalías',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _detectAnomalies,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.warning_amber),
              label: const Text('Analizar Gastos Anómalos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingResults() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Resultados del Entrenamiento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildResultRow('Accuracy', '${_trainingResult!['accuracy']?.toStringAsFixed(2)}%'),
            _buildResultRow('MAE', '\$${_trainingResult!['metrics']?['mae']?.toStringAsFixed(2)}'),
            _buildResultRow('RMSE', '\$${_trainingResult!['metrics']?['rmse']?.toStringAsFixed(2)}'),
            _buildResultRow('R² Score', '${_trainingResult!['metrics']?['r2']?.toStringAsFixed(4)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsResults() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 Métricas del Modelo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildResultRow('Training Samples', '${_metricsResult!['training_samples']}'),
            _buildResultRow('Test Samples', '${_metricsResult!['test_samples']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 Predicción de Gastos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildResultRow('Total Predicho', '\$${_predictionResult!['predicted_amount']?.toStringAsFixed(2)}'),
            _buildResultRow('Promedio Diario', '\$${_predictionResult!['average_daily']?.toStringAsFixed(2)}'),
            _buildResultRow('Confianza', '${_predictionResult!['confidence']?.toStringAsFixed(2)}%'),
            _buildResultRow('Días', '${_predictionResult!['days']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomaliesResults() {
    final anomalies = _anomaliesResult!['anomalies'] as List? ?? [];
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Anomalías Detectadas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildResultRow('Total Analizado', '${_anomaliesResult!['total_analyzed']}'),
            _buildResultRow('Anomalías Encontradas', '${_anomaliesResult!['anomalies_found']}'),
            const SizedBox(height: 16),
            if (anomalies.isNotEmpty) ...[
              const Text('Detalles de Anomalías:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...anomalies.map((anomaly) => ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: anomaly['severity'] == 'high' ? Colors.red : Colors.orange,
                    ),
                    title: Text('\$${anomaly['amount']}'),
                    subtitle: Text('${anomaly['category']} - ${anomaly['date']}'),
                    trailing: Text(
                      anomaly['severity'],
                      style: TextStyle(
                        color: anomaly['severity'] == 'high' ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
