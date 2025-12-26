# 🤖 Guía de Entrenamiento del Modelo ML

## 📊 Sistema de Machine Learning para Predicción de Gastos

Este sistema utiliza datos agregados de múltiples usuarios para entrenar un modelo de predicción de gastos que proporciona recomendaciones personalizadas.

---

## 🎯 Características

### 1. Recopilación de Datos
- ✅ Recopila datos de hasta 100 usuarios
- ✅ Extrae gastos históricos de los últimos 365 días
- ✅ Obtiene presupuestos y metas de ahorro
- ✅ Calcula patrones de gasto por categoría

### 2. Procesamiento de Datos
- ✅ Calcula estadísticas agregadas
- ✅ Identifica patrones de comportamiento
- ✅ Genera features para ML (day of week, month, etc.)
- ✅ Calcula percentiles y medianas

### 3. Exportación
- ✅ Exporta a CSV para modelos externos
- ✅ Exporta estadísticas a JSON
- ✅ Guarda modelo en Firestore

### 4. Predicciones
- ✅ Recomendaciones personalizadas
- ✅ Comparación con promedios agregados
- ✅ Identificación de gastos excesivos

---

## 🚀 Cómo Usar

### Opción 1: Desde la UI

1. **Navegar a la página de entrenamiento:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => const MLTrainingPage(),
     ),
   );
   ```

2. **Configurar parámetros:**
   - Seleccionar número de usuarios (10-100)
   - Verificar rango de fechas (por defecto: último año)

3. **Iniciar entrenamiento:**
   - Presionar "Iniciar Entrenamiento"
   - Esperar a que se complete (puede tardar varios segundos)

4. **Revisar resultados:**
   - Ver estadísticas agregadas
   - Verificar archivos generados (CSV y JSON)

### Opción 2: Programáticamente

```dart
import 'package:gestor_de_gastos_jc/config/services/ml_training_service.dart';

final mlService = MLTrainingService();

// Recopilar y entrenar
final trainingData = await mlService.collectTrainingDataFromAllUsers(
  maxUsers: 50,
  startDate: DateTime.now().subtract(Duration(days: 365)),
  endDate: DateTime.now(),
);

// Generar dataset
final dataset = await mlService.generateMLDataset(
  maxUsers: 50,
);

// Exportar
final csv = mlService.exportTrainingDataToCSV(trainingData);
final json = mlService.exportAggregatedStatsToJSON(trainingData);

// Guardar modelo
await mlService.saveTrainedModel(
  modelName: 'expense_predictor',
  modelMetadata: {'version': '1.0.0'},
  trainingStats: trainingData['aggregatedStatistics'],
);
```

---

## 📁 Estructura de Datos

### Datos de Entrada (por usuario)

```javascript
{
  "userId": "abc123",
  "expenses": [
    {
      "amount": 150.50,
      "category": "Alimentación",
      "date": "2024-12-20T10:30:00",
      "description": "Supermercado"
    }
  ],
  "budget": {
    "presupuestoGeneral": 10000,
    "ahorroRecomendado": 1500,
    "gastosTotales": 7500
  }
}
```

### Estadísticas Agregadas (output)

```javascript
{
  "metadata": {
    "usersProcessed": 50,
    "totalExpenses": 5000,
    "totalBudgets": 45
  },
  "aggregatedStatistics": {
    "expenses": {
      "total": 750000,
      "average": 150,
      "median": 120,
      "percentile25": 50,
      "percentile75": 250,
      "categoryAverages": {
        "Alimentación": 300,
        "Transporte": 200,
        "Entretenimiento": 150
      }
    },
    "budgets": {
      "averageBudget": 8500,
      "averageSavingsRatio": 0.15
    }
  }
}
```

### Dataset ML (CSV)

```csv
userId,date,amount,category,dayOfWeek,month,year,hour
user1,2024-12-20T10:30:00,150.5,Alimentación,3,12,2024,10
user1,2024-12-21T18:45:00,50.0,Transporte,4,12,2024,18
user2,2024-12-22T14:20:00,200.0,Entretenimiento,5,12,2024,14
```

---

## 🎨 Features Generados

El sistema genera automáticamente las siguientes características para ML:

| Feature | Descripción | Ejemplo |
|---------|-------------|---------|
| `amount` | Cantidad del gasto | 150.50 |
| `amount_log` | Log(amount + 1) | 5.02 |
| `category` | Categoría del gasto | "Alimentación" |
| `dayOfWeek` | Día de la semana (1-7) | 3 |
| `month` | Mes (1-12) | 12 |
| `year` | Año | 2024 |
| `hour` | Hora del día (0-23) | 10 |
| `isWeekend` | Es fin de semana (0/1) | 0 |
| `isMonthStart` | Inicio de mes (0/1) | 0 |
| `isMonthEnd` | Fin de mes (0/1) | 1 |
| `quarter` | Trimestre (1-4) | 4 |

---

## 📊 Recomendaciones Personalizadas

### Obtener Recomendaciones

```dart
final recommendations = await mlService.getPersonalizedRecommendations(
  userId: 'abc123',
);

print(recommendations['recommendations']);
```

### Ejemplo de Recomendación

```javascript
{
  "userId": "abc123",
  "recommendations": [
    {
      "type": "reduce_spending",
      "category": "Entretenimiento",
      "userSpending": 450,
      "averageSpending": 250,
      "message": "Gastas 80% más que el promedio en Entretenimiento",
      "priority": "high"
    }
  ],
  "hasModel": true,
  "generatedAt": "2024-12-26T15:30:00"
}
```

---

## 🔧 Configuración en Router

Para agregar la página de entrenamiento al router:

```dart
// En routes/routers.dart
GoRoute(
  path: '/ml-training',
  builder: (context, state) => const MLTrainingPage(),
),
```

---

## 📈 Métricas del Modelo

El modelo guarda las siguientes métricas en Firestore:

```javascript
{
  "modelName": "expense_predictor",
  "version": "1.0.0",
  "metadata": {
    "algorithm": "statistical_analysis",
    "features": ["amount", "category", "dayOfWeek", "month"],
    "maxUsers": 50
  },
  "trainingStats": {
    "expenses": {
      "total": 750000,
      "average": 150,
      "median": 120
    }
  },
  "trainedAt": "2024-12-26T15:30:00",
  "status": "active"
}
```

---

## 🎯 Casos de Uso

### 1. Predicción de Gastos Futuros
```dart
// Predecir gasto en categoría específica
final prediction = await mlService.generateExpensePrediction(
  userId: userId,
  category: 'Alimentación',
  daysToPredict: 30,
);
```

### 2. Análisis de Patrones
```dart
// Analizar patrones de gasto
final patterns = await mlService.analyzeSpendingPatterns(
  userId: userId,
  days: 30,
);
```

### 3. Recomendaciones de Ahorro
```dart
// Generar recomendaciones
final recommendations = await mlService.generateSavingsRecommendations(
  userId: userId,
);
```

---

## 📝 Archivos Generados

### 1. training_data.csv
Ubicación: `Documents/training_data.csv`
- Datos crudos de gastos
- Listo para usar en Python/R
- Compatible con pandas, scikit-learn

### 2. training_stats.json
Ubicación: `Documents/training_stats.json`
- Estadísticas agregadas
- Metadata del modelo
- Patrones identificados

---

## 🔐 Privacidad y Seguridad

### Datos Anónimos
- ✅ Solo se usan IDs de usuario (hasheados)
- ✅ No se incluyen nombres ni emails
- ✅ Datos agregados no permiten identificar individuos

### Almacenamiento
- ✅ Datos locales en dispositivo del usuario
- ✅ Modelo guardado en Firestore con permisos
- ✅ Solo administradores pueden entrenar

---

## 🚀 Próximos Pasos

### Integración con TensorFlow Lite
```dart
// TODO: Implementar modelo de TensorFlow
import 'package:tflite_flutter/tflite_flutter.dart';

final interpreter = await Interpreter.fromAsset('expense_model.tflite');
```

### Algoritmos Avanzados
- [ ] Regresión lineal
- [ ] Random Forest
- [ ] Neural Networks
- [ ] Time Series (ARIMA, LSTM)

### Mejoras
- [ ] Predicción por hora del día
- [ ] Detección de anomalías
- [ ] Clustering de usuarios
- [ ] Análisis de tendencias

---

## 📞 Contacto y Soporte

Para dudas o mejoras en el sistema ML:
- Revisar logs en consola
- Verificar archivos CSV/JSON generados
- Consultar Firestore (`ml_models` collection)

---

## ✅ Checklist de Implementación

- [x] Servicio de recopilación de datos
- [x] Generación de features
- [x] Exportación a CSV/JSON
- [x] Guardado en Firestore
- [x] UI para entrenamiento
- [x] Recomendaciones personalizadas
- [ ] Integración con TensorFlow
- [ ] API REST para predicciones
- [ ] Dashboard de métricas

---

**Última actualización:** Diciembre 26, 2025
**Versión:** 1.0.0
