import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/ml_training_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Página para entrenar el modelo de Machine Learning
/// Esta página permite recopilar datos de múltiples usuarios y entrenar el modelo
class MLTrainingPage extends StatefulWidget {
  const MLTrainingPage({super.key});

  @override
  State<MLTrainingPage> createState() => _MLTrainingPageState();
}

class _MLTrainingPageState extends State<MLTrainingPage> {
  final MLTrainingService _mlTrainingService = MLTrainingService();
  
  bool _isTraining = false;
  String _status = 'Listo para entrenar';
  Map<String, dynamic>? _trainingResults;
  String? _csvPath;
  String? _jsonPath;

  int _maxUsers = 50;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  /// Iniciar el entrenamiento del modelo
  Future<void> _startTraining() async {
    setState(() {
      _isTraining = true;
      _status = 'Iniciando entrenamiento...';
      _trainingResults = null;
    });

    try {
      // 1. Recopilar datos de todos los usuarios
      setState(() => _status = 'Recopilando datos de $_maxUsers usuarios...');
      
      final trainingData = await _mlTrainingService.collectTrainingDataFromAllUsers(
        maxUsers: _maxUsers,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() => _status = 'Datos recopilados. Generando dataset...');

      // 2. Generar dataset con features
      final dataset = await _mlTrainingService.generateMLDataset(
        maxUsers: _maxUsers,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() => _status = 'Exportando datos...');

      // 3. Exportar a CSV
      final csv = _mlTrainingService.exportTrainingDataToCSV(trainingData);
      final csvFile = await _saveToFile('training_data.csv', csv);
      
      // 4. Exportar estadísticas a JSON
      final json = _mlTrainingService.exportAggregatedStatsToJSON(trainingData);
      final jsonFile = await _saveToFile('training_stats.json', json);

      setState(() => _status = 'Guardando modelo...');

      // 5. Guardar modelo en Firestore
      await _mlTrainingService.saveTrainedModel(
        modelName: 'expense_predictor',
        modelMetadata: {
          'version': '1.0.0',
          'algorithm': 'statistical_analysis',
          'features': ['amount', 'category', 'dayOfWeek', 'month', 'isWeekend'],
          'maxUsers': _maxUsers,
        },
        trainingStats: trainingData['aggregatedStatistics'],
      );

      setState(() {
        _isTraining = false;
        _status = '¡Entrenamiento completado exitosamente!';
        _trainingResults = trainingData;
        _csvPath = csvFile;
        _jsonPath = jsonFile;
      });

      _showSuccessDialog();

    } catch (e) {
      setState(() {
        _isTraining = false;
        _status = 'Error: $e';
      });

      _showErrorDialog(e.toString());
    }
  }

  /// Guardar contenido en archivo
  Future<String> _saveToFile(String filename, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      print('✅ Archivo guardado: ${file.path}');
      return file.path;
    } catch (e) {
      print('❌ Error al guardar archivo: $e');
      rethrow;
    }
  }

  /// Mostrar diálogo de éxito
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('¡Éxito!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El modelo ha sido entrenado exitosamente.'),
            const SizedBox(height: 16),
            if (_trainingResults != null) ...[
              Text('Usuarios: ${_trainingResults!['metadata']['usersProcessed']}'),
              Text('Gastos: ${_trainingResults!['metadata']['totalExpenses']}'),
              Text('Presupuestos: ${_trainingResults!['metadata']['totalBudgets']}'),
            ],
            const SizedBox(height: 16),
            const Text('Archivos generados:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_csvPath != null) Text('CSV: $_csvPath', style: const TextStyle(fontSize: 10)),
            if (_jsonPath != null) Text('JSON: $_jsonPath', style: const TextStyle(fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de error
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamiento de Modelo ML'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.deepPurple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.psychology, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    const Text(
                      'Entrenar Modelo de Predicción',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Utiliza datos de múltiples usuarios para mejorar las predicciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Configuración
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Número de usuarios
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Número de usuarios'),
                              Text(
                                '$_maxUsers usuarios',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _maxUsers.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 18,
                      label: '$_maxUsers',
                      onChanged: _isTraining ? null : (value) {
                        setState(() => _maxUsers = value.toInt());
                      },
                    ),

                    const SizedBox(height: 16),

                    // Rango de fechas
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Período de datos'),
                              Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_isTraining)
                      const CircularProgressIndicator()
                    else if (_trainingResults != null)
                      const Icon(Icons.check_circle, size: 48, color: Colors.green)
                    else
                      const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Resultados
            if (_trainingResults != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultados del Entrenamiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildStatRow('Usuarios procesados', '${_trainingResults!['metadata']['usersProcessed']}'),
                      _buildStatRow('Total de gastos', '${_trainingResults!['metadata']['totalExpenses']}'),
                      _buildStatRow('Presupuestos', '${_trainingResults!['metadata']['totalBudgets']}'),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Estadísticas Agregadas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_trainingResults!['aggregatedStatistics'] != null) ...[
                        _buildStatRow(
                          'Gasto promedio',
                          '\$${_trainingResults!['aggregatedStatistics']['expenses']['average'].toStringAsFixed(2)}',
                        ),
                        _buildStatRow(
                          'Gasto mediano',
                          '\$${_trainingResults!['aggregatedStatistics']['expenses']['median'].toStringAsFixed(2)}',
                        ),
                        _buildStatRow(
                          'Presupuesto promedio',
                          '\$${_trainingResults!['aggregatedStatistics']['budgets']['averageBudget'].toStringAsFixed(2)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],

            // Botón de entrenamiento
            ElevatedButton.icon(
              onPressed: _isTraining ? null : _startTraining,
              icon: _isTraining 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isTraining ? 'Entrenando...' : 'Iniciar Entrenamiento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este proceso recopilará datos anónimos de gastos y presupuestos de múltiples usuarios para entrenar el modelo de predicción. Los datos se guardarán localmente en formato CSV y JSON.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
