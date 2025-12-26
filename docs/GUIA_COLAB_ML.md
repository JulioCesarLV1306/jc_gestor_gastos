# 🤖 Guía Completa: Integración ML con Google Colab

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración de Google Colab](#configuración-de-google-colab)
4. [Configuración de Ngrok](#configuración-de-ngrok)
5. [Integración con Flutter](#integración-con-flutter)
6. [Uso de la Aplicación](#uso-de-la-aplicación)
7. [API Endpoints](#api-endpoints)
8. [Ejemplos de Uso](#ejemplos-de-uso)
9. [Solución de Problemas](#solución-de-problemas)

---

## 🎯 Descripción General

Este sistema permite entrenar y usar modelos de Machine Learning para predecir gastos futuros utilizando Google Colab como backend y Flutter como frontend.

### Características Principales

- ✅ **Entrenamiento en la Nube**: Entrena modelos con datos de múltiples usuarios en Google Colab
- ✅ **Predicciones en Tiempo Real**: Obtén predicciones de gastos futuros desde tu app Flutter
- ✅ **Detección de Anomalías**: Identifica gastos inusuales automáticamente
- ✅ **Recomendaciones Personalizadas**: Recibe sugerencias basadas en patrones de gasto
- ✅ **API REST**: Comunicación mediante endpoints HTTP
- ✅ **Ngrok**: Túnel seguro para conectar Colab con tu app

### Arquitectura del Sistema

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────────┐
│  Flutter App    │ ◄─────► │    Ngrok     │ ◄─────► │ Google Colab    │
│  (Cliente)      │  HTTPS  │   (Túnel)    │  Local  │  (Servidor ML)  │
└─────────────────┘         └──────────────┘         └─────────────────┘
        │                                                      │
        │                                                      │
        ▼                                                      ▼
┌─────────────────┐                                  ┌─────────────────┐
│   Firestore     │                                  │  Scikit-learn   │
│   (Base Datos)  │                                  │  Random Forest  │
└─────────────────┘                                  └─────────────────┘
```

---

## 📦 Requisitos Previos

### 1. Cuenta de Google
- Gmail activa para acceder a Google Colab

### 2. Cuenta de Ngrok
- Crear cuenta gratuita en: https://dashboard.ngrok.com/signup
- Obtener token de autenticación

### 3. Dependencias de Flutter
```yaml
# Ya incluidas en pubspec.yaml
dependencies:
  http: ^1.1.0
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  hive: ^2.2.3
```

### 4. Python Packages (en Colab)
```python
pip install flask flask-ngrok pyngrok pandas numpy scikit-learn joblib
```

---

## 🔧 Configuración de Google Colab

### Paso 1: Subir Notebook a Colab

1. Abre Google Colab: https://colab.research.google.com/
2. Ve a **File → Upload notebook**
3. Selecciona el archivo `colab_expense_predictor.ipynb`
4. Haz clic en **Upload**

### Paso 2: Configurar Token de Ngrok

1. Ve a https://dashboard.ngrok.com/get-started/your-authtoken
2. Copia tu token de autenticación
3. En Colab, encuentra la celda **"🎯 Configurar Token de Ngrok"**
4. Reemplaza:
   ```python
   NGROK_AUTH_TOKEN = "tu_token_aqui"
   ```
   Con tu token real:
   ```python
   NGROK_AUTH_TOKEN = "2abc123XYZ..."
   ```

### Paso 3: Ejecutar Notebook

1. Ve a **Runtime → Run all** (o presiona `Ctrl+F9`)
2. Espera a que todas las celdas se ejecuten (2-3 minutos)
3. La última celda mostrará:
   ```
   🎉 ¡SERVIDOR INICIADO EXITOSAMENTE!
   📡 URL Pública de la API: https://xxxx-xx-xxx.ngrok.io
   ```

### Paso 4: Copiar URL de Ngrok

**MUY IMPORTANTE:** Copia la URL completa que aparece (ejemplo: `https://1234-56-789.ngrok.io`)

⚠️ **NOTA:** Esta URL cambia cada vez que ejecutas el notebook. Guárdala bien.

---

## 🌐 Configuración de Ngrok

### Opción 1: Usar Dashboard de Ngrok (Recomendado)

1. Inicia sesión en https://dashboard.ngrok.com/
2. Ve a **Cloud Edge → Tunnels**
3. Verás tu túnel activo con la URL pública
4. Copia la URL (ejemplo: `https://abc123.ngrok.io`)

### Opción 2: Desde el Notebook

La URL aparecerá automáticamente en la salida de la última celda del notebook.

### Verificar Conexión

Prueba tu API en el navegador:
```
https://tu-url.ngrok.io/health
```

Deberías ver:
```json
{
  "status": "healthy",
  "model_trained": false,
  "timestamp": "2024-12-26T10:30:00"
}
```

---

## 📱 Integración con Flutter

### Paso 1: Agregar Ruta en Router

Edita `lib/routes/routers.dart`:

```dart
import 'package:gestor_de_gastos_jc/modules/ml/colab_ml_page.dart';

// Dentro de las rutas:
GoRoute(
  path: '/colab-ml',
  builder: (context, state) => const ColabMLPage(),
),
```

### Paso 2: Agregar http en pubspec.yaml

Ya está incluido, pero verifica:

```yaml
dependencies:
  http: ^1.1.0
```

Si no está, ejecuta:
```bash
flutter pub add http
```

### Paso 3: Configurar URL en la App

1. Inicia tu app Flutter
2. Navega a **Configuración → ML con Colab** (o `/colab-ml`)
3. Pega la URL de Ngrok que copiaste
4. Presiona **Verificar Conexión**

Si todo está bien, verás: ✅ **Conectado exitosamente a Colab**

---

## 🎮 Uso de la Aplicación

### 1. Entrenar Modelo

#### Desde la App:
1. Ve a la página **ML con Colab**
2. Ajusta el slider de **Cantidad de usuarios** (10-100)
3. Presiona **Entrenar Modelo en Colab**
4. Espera 1-3 minutos (dependiendo de la cantidad de datos)
5. Verás los resultados:
   - **Accuracy**: Precisión del modelo (0-100%)
   - **MAE**: Error promedio absoluto
   - **RMSE**: Error cuadrático medio
   - **R² Score**: Calidad del ajuste (0-1)

#### Desde Colab (Manual):
```python
sample_data = [
    {'userId': 'user1', 'fecha': '2024-01-01', 'monto': 50.0, 'categoria': 'Comida'},
    {'userId': 'user1', 'fecha': '2024-01-02', 'monto': 30.0, 'categoria': 'Transporte'},
    # ... más datos
]

train_response = requests.post(
    f"{public_url}/train",
    json={
        'training_data': sample_data,
        'model_config': {'n_estimators': 100, 'max_depth': 10}
    }
)
print(train_response.json())
```

### 2. Predecir Gastos Futuros

1. Ajusta el slider de **Días a predecir** (7-90 días)
2. Presiona **Obtener Predicción**
3. Revisa los resultados:
   - **Total Predicho**: Gasto total estimado
   - **Promedio Diario**: Gasto promedio por día
   - **Confianza**: Nivel de confianza (0-100%)

### 3. Detectar Anomalías

1. Presiona **Analizar Gastos Anómalos**
2. El sistema analiza tus últimos 30 gastos
3. Si encuentra anomalías, muestra:
   - Cantidad de anomalías
   - Detalles de cada gasto anómalo
   - Severidad (alta/media)

---

## 🔌 API Endpoints

### 1. Health Check
```http
GET /health
```
**Response:**
```json
{
  "status": "healthy",
  "model_trained": true,
  "timestamp": "2024-12-26T10:30:00"
}
```

### 2. Entrenar Modelo
```http
POST /train
Content-Type: application/json

{
  "training_data": [
    {
      "userId": "user123",
      "fecha": "2024-01-15",
      "monto": 45.50,
      "categoria": "Comida"
    }
  ],
  "model_config": {
    "algorithm": "random_forest",
    "n_estimators": 100,
    "max_depth": 10
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Model trained successfully",
  "accuracy": 87.5,
  "metrics": {
    "mae": 12.34,
    "rmse": 18.56,
    "r2": 0.875,
    "training_samples": 800,
    "test_samples": 200
  }
}
```

### 3. Predecir Gastos
```http
POST /predict
Content-Type: application/json

{
  "user_id": "user123",
  "historical_data": [
    {
      "userId": "user123",
      "fecha": "2024-01-15",
      "monto": 45.50,
      "categoria": "Comida"
    }
  ],
  "days_to_predict": 30
}
```

**Response:**
```json
{
  "user_id": "user123",
  "predicted_amount": 1245.80,
  "average_daily": 41.53,
  "confidence": 87.5,
  "days": 30,
  "predictions": [
    {
      "date": "2024-02-01",
      "predicted_amount": 42.30
    }
  ]
}
```

### 4. Detectar Anomalías
```http
POST /detect_anomalies
Content-Type: application/json

{
  "user_id": "user123",
  "expenses": [
    {
      "userId": "user123",
      "fecha": "2024-01-15",
      "monto": 500.00,
      "categoria": "Comida"
    }
  ]
}
```

**Response:**
```json
{
  "anomalies_found": 2,
  "total_analyzed": 30,
  "anomalies": [
    {
      "index": 5,
      "amount": 500.00,
      "category": "Comida",
      "date": "2024-01-15",
      "anomaly_score": -0.75,
      "severity": "high"
    }
  ]
}
```

### 5. Obtener Métricas
```http
GET /metrics
```

**Response:**
```json
{
  "mae": 12.34,
  "rmse": 18.56,
  "r2": 0.875,
  "accuracy": 87.5,
  "training_samples": 800,
  "test_samples": 200
}
```

---

## 💻 Ejemplos de Uso

### Ejemplo 1: Flujo Completo desde Flutter

```dart
// 1. Configurar URL
final colabService = ColabMLService();
colabService.setColabApiUrl('https://abc123.ngrok.io');

// 2. Verificar conexión
final isHealthy = await colabService.checkApiHealth();
if (!isHealthy) {
  print('Error: No se pudo conectar');
  return;
}

// 3. Recopilar datos de entrenamiento
final trainingService = MLTrainingService();
final data = await trainingService.collectTrainingDataFromAllUsers(maxUsers: 50);

// 4. Preparar datos
final trainingData = (data['expenses'] as List).map((e) => {
  'userId': e['userId'],
  'fecha': e['fecha'],
  'monto': e['monto'],
  'categoria': e['categoria'],
}).toList();

// 5. Entrenar modelo
final result = await colabService.trainModel(
  trainingData: trainingData,
  modelConfig: {'n_estimators': 100, 'max_depth': 10},
);

print('Accuracy: ${result['accuracy']}%');

// 6. Hacer predicción
final prediction = await colabService.predictExpenses(
  userId: 'user123',
  historicalData: userExpenses,
  category: 'Comida',
  daysToPredict: 30,
);

print('Gasto predicho: \$${prediction['predicted_amount']}');
```

### Ejemplo 2: Análisis de Anomalías

```dart
final anomalies = await colabService.detectAnomalies(
  userId: userId,
  recentExpenses: recentExpenses,
);

if (anomalies['anomalies_found'] > 0) {
  print('⚠️ Gastos anómalos encontrados:');
  for (var anomaly in anomalies['anomalies']) {
    print('- \$${anomaly['amount']} en ${anomaly['category']} (${anomaly['severity']})');
  }
}
```

### Ejemplo 3: Predicciones Múltiples

```dart
final predictions = await colabService.predictMultipleCategories(
  userId: userId,
  historicalData: allExpenses,
  categories: ['Comida', 'Transporte', 'Entretenimiento'],
  daysToPredict: 30,
);

predictions['predictions'].forEach((category, pred) {
  print('$category: \$${pred['total_predicted']}');
});
```

---

## 🔧 Solución de Problemas

### Problema 1: "URL de Colab no configurada"

**Solución:**
```dart
colabService.setColabApiUrl('https://tu-url.ngrok.io');
```

### Problema 2: "Timeout: El entrenamiento tardó más de 5 minutos"

**Causas:**
- Demasiados datos de entrenamiento
- Colab con recursos limitados

**Soluciones:**
1. Reduce `maxUsers` a 30 o menos
2. Usa Colab Pro para más recursos
3. Filtra datos por fechas recientes

### Problema 3: "Error: Model not trained yet"

**Solución:**
Debes entrenar el modelo primero:
```dart
await colabService.trainModel(trainingData: data);
```

### Problema 4: URL de Ngrok cambió

**Causa:** Ngrok genera URLs nuevas cada vez que reinicias Colab

**Solución:**
1. Ejecuta el notebook de nuevo
2. Copia la nueva URL
3. Actualiza en la app Flutter

### Problema 5: "Connection refused" o "No se pudo conectar"

**Verificar:**
1. ¿El notebook de Colab está ejecutándose?
2. ¿Copiaste la URL completa con `https://`?
3. ¿La URL de Ngrok es la correcta?

**Solución:**
```python
# En Colab, verifica el estado
print(public_url)
```

### Problema 6: Predicciones poco precisas

**Causas:**
- Pocos datos de entrenamiento
- Datos no representativos

**Soluciones:**
1. Entrena con más usuarios (50-100)
2. Usa datos de al menos 3 meses
3. Ajusta `model_config`:
   ```dart
   {
     'n_estimators': 200,  // Más árboles
     'max_depth': 15,      // Más profundidad
   }
   ```

---

## 📊 Métricas y Evaluación

### Accuracy (Precisión)
- **Bueno:** > 80%
- **Aceptable:** 60-80%
- **Malo:** < 60%

### MAE (Mean Absolute Error)
- Error promedio en dólares
- **Ejemplo:** MAE = 15 significa que el modelo se equivoca en promedio $15

### RMSE (Root Mean Squared Error)
- Error cuadrático medio
- Penaliza errores grandes
- **Mejor:** Valores más bajos

### R² Score (Coeficiente de Determinación)
- **1.0:** Predicción perfecta
- **0.8-0.9:** Muy bueno
- **0.6-0.8:** Aceptable
- **< 0.6:** Necesita mejora

---

## 🚀 Mejores Prácticas

### 1. Entrenamiento
- Entrena con al menos 50 usuarios
- Usa datos de al menos 2-3 meses
- Re-entrena el modelo mensualmente

### 2. Predicciones
- No predecir más de 90 días
- Usar predicciones de 7-30 días para mayor precisión
- Validar predicciones con gastos reales

### 3. Datos
- Mantén datos limpios y consistentes
- Elimina duplicados antes de entrenar
- Categoriza gastos correctamente

### 4. Seguridad
- No expongas tu token de Ngrok
- Usa HTTPS siempre
- Valida datos antes de enviar

### 5. Performance
- Usa caché para predicciones frecuentes
- Limita cantidad de requests por minuto
- Entrena en horarios de baja actividad

---

## 📝 Notas Importantes

1. **Persistencia:** Google Colab se desconecta después de 12 horas de inactividad o 90 minutos sin uso.

2. **URL Dinámica:** La URL de Ngrok cambia cada vez que ejecutas el notebook. Guárdala en tu app.

3. **Límites de Ngrok Gratis:**
   - 1 proceso por vez
   - URL dinámica
   - 40 requests/minuto

4. **Colab Pro:** Considera upgrade si necesitas:
   - Sesiones más largas (24h)
   - GPU más potente
   - Sin límites de tiempo

5. **Datos Sensibles:** No envíes información personal identificable. Usa IDs anónimos.

---

## 🎓 Recursos Adicionales

### Documentación Oficial
- [Google Colab](https://colab.research.google.com/notebooks/intro.ipynb)
- [Ngrok](https://ngrok.com/docs)
- [Scikit-learn](https://scikit-learn.org/stable/documentation.html)
- [Flask](https://flask.palletsprojects.com/)

### Tutoriales
- [Random Forest Regressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html)
- [Isolation Forest](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html)

---

## ✅ Checklist de Implementación

- [ ] Crear cuenta de Ngrok
- [ ] Obtener token de Ngrok
- [ ] Subir notebook a Google Colab
- [ ] Configurar token en notebook
- [ ] Ejecutar notebook completo
- [ ] Copiar URL de Ngrok
- [ ] Agregar ruta en Flutter
- [ ] Pegar URL en app
- [ ] Verificar conexión
- [ ] Entrenar modelo con datos reales
- [ ] Hacer primera predicción
- [ ] Detectar anomalías
- [ ] Documentar resultados

---

## 🆘 Soporte

Si tienes problemas:

1. Verifica que el notebook esté ejecutándose
2. Revisa la consola de Colab por errores
3. Verifica la URL de Ngrok en el dashboard
4. Prueba el endpoint `/health` en el navegador
5. Revisa los logs en la app Flutter

---

**Última actualización:** Diciembre 26, 2024
**Versión:** 1.0.0
