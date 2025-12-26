# Guía de Uso - Sistema Firebase

## ✅ Implementación Completada

Se ha implementado exitosamente la arquitectura completa de Firebase para tu gestor de gastos con las siguientes características:

### 📦 Modelos Creados

1. **UserProfileModel** - Perfil de usuario
2. **ExpenseModel** - Modelo de gastos
3. **BudgetModel** - Modelo de presupuestos
4. **SavingModel** - Modelo de metas de ahorro
5. **PredictionModel** - Modelo de predicciones ML

### 🔐 Servicios Implementados

#### 1. AuthService
Manejo completo de autenticación de usuarios:

```dart
import 'package:gestor_de_gastos_jc/config/services/auth_service.dart';

final authService = AuthService();

// Registrar usuario
final user = await authService.registerWithEmail(
  email: 'usuario@example.com',
  password: 'password123',
  displayName: 'Mi Nombre',
);

// Iniciar sesión
final user = await authService.signInWithEmail(
  email: 'usuario@example.com',
  password: 'password123',
);

// Cerrar sesión
await authService.signOut();

// Obtener usuario actual
User? currentUser = authService.currentUser;

// Escuchar cambios de autenticación
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario conectado: ${user.email}');
  } else {
    print('Usuario desconectado');
  }
});
```

#### 2. ExpenseService
Gestión de gastos con Firestore:

```dart
import 'package:gestor_de_gastos_jc/config/services/expense_firestore_service.dart';
import 'package:gestor_de_gastos_jc/core/models/expense_model.dart';

final expenseService = ExpenseService();
final userId = authService.currentUser!.uid;

// Crear gasto
final expense = ExpenseModel(
  userId: userId,
  description: 'Compra de supermercado',
  amount: 150.50,
  category: 'Alimentación',
  date: DateTime.now(),
  isRecurrent: false,
);
await expenseService.createExpense(expense);

// Obtener gastos (Stream en tiempo real)
expenseService.getExpenses(userId).listen((expenses) {
  print('Total de gastos: ${expenses.length}');
  for (var expense in expenses) {
    print('${expense.description}: \$${expense.amount}');
  }
});

// Filtrar por fechas
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime.now();
expenseService.getExpensesByDateRange(
  userId: userId,
  startDate: startDate,
  endDate: endDate,
).listen((expenses) {
  print('Gastos del período: ${expenses.length}');
});

// Obtener total por período
final total = await expenseService.getTotalExpensesByPeriod(
  userId: userId,
  startDate: startDate,
  endDate: endDate,
);
print('Total gastado: \$$total');
```

#### 3. BudgetFirestoreService
Gestión de presupuestos:

```dart
import 'package:gestor_de_gastos_jc/config/services/budget_firestore_service.dart';
import 'package:gestor_de_gastos_jc/core/models/budget_model.dart';

final budgetService = BudgetFirestoreService();

// Crear presupuesto mensual
final budget = BudgetModel(
  userId: userId,
  category: 'Alimentación',
  amount: 1000.0,
  period: 'monthly',
  startDate: DateTime.now(),
);
await budgetService.createBudget(budget);

// Obtener presupuestos activos
budgetService.getActiveBudgets(userId).listen((budgets) {
  for (var budget in budgets) {
    print('${budget.category}: \$${budget.amount} ${budget.period}');
  }
});
```

#### 4. SavingFirestoreService
Gestión de metas de ahorro:

```dart
import 'package:gestor_de_gastos_jc/config/services/saving_firestore_service.dart';
import 'package:gestor_de_gastos_jc/core/models/saving_model.dart';

final savingService = SavingFirestoreService();

// Crear meta de ahorro
final saving = SavingModel(
  userId: userId,
  goal: 'Vacaciones 2025',
  targetAmount: 5000.0,
  currentAmount: 0.0,
  targetDate: DateTime(2025, 12, 31),
);
await savingService.createSaving(saving);

// Agregar dinero al ahorro
await savingService.addAmountToSaving(
  savingId: saving.id!,
  amount: 500.0,
);

// Ver progreso
savingService.getSavings(userId).listen((savings) {
  for (var saving in savings) {
    print('${saving.goal}: ${saving.progress.toStringAsFixed(1)}%');
    print('${saving.currentAmount} / ${saving.targetAmount}');
  }
});
```

#### 5. MLService
Análisis y predicciones con Machine Learning:

```dart
import 'package:gestor_de_gastos_jc/config/services/ml_service.dart';

final mlService = MLService();

// Generar predicción de gastos
final prediction = await mlService.generateExpensePrediction(
  userId: userId,
  category: 'Alimentación',
  daysToPredict: 30,
);
print('Predicción para 30 días: \$${prediction.predictedValue}');
print('Confianza: ${(prediction.confidence * 100).toStringAsFixed(0)}%');

// Analizar patrones de gasto
final analysis = await mlService.analyzeSpendingPatterns(
  userId: userId,
  days: 30,
);
print('Total gastado: \$${analysis['totalExpenses']}');
print('Promedio diario: \$${analysis['averageDaily']}');
print('Categoría principal: ${analysis['topCategory']}');

// Obtener recomendaciones de ahorro
final recommendations = await mlService.generateSavingsRecommendations(
  userId: userId,
);
print('Ahorro recomendado mensual: \$${recommendations['recommendedMonthlySavings']}');
for (var rec in recommendations['recommendations']) {
  print('- ${rec['title']}: ${rec['description']}');
}

// Exportar datos para entrenamiento
final trainingData = await mlService.exportTrainingData(
  userId: userId,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);
print('Gastos exportados: ${trainingData['statistics']['expenseCount']}');

// Exportar como CSV para análisis externo
String csv = mlService.exportToCSV(trainingData);
// Guardar en archivo o enviar a servidor
```

### 🔒 Seguridad

Las reglas de Firestore están configuradas para:
- ✅ Requerir autenticación para todas las operaciones
- ✅ Cada usuario solo puede acceder a sus propios datos
- ✅ Validación de tipos de datos y campos requeridos
- ✅ Protección contra modificación de userId

**Estado**: ✅ Reglas desplegadas exitosamente en Firebase

### 📊 Estructura de Datos

```
Firestore Database
├── users/
│   └── {userId}
│       ├── uid
│       ├── email
│       ├── displayName
│       └── createdAt
├── expenses/
│   └── {expenseId}
│       ├── userId
│       ├── description
│       ├── amount
│       ├── category
│       ├── date
│       └── isRecurrent
├── budgets/
│   └── {budgetId}
│       ├── userId
│       ├── category
│       ├── amount
│       ├── period
│       └── startDate
├── savings/
│   └── {savingId}
│       ├── userId
│       ├── goal
│       ├── targetAmount
│       ├── currentAmount
│       └── targetDate
└── predictions/
    └── {predictionId}
        ├── userId
        ├── type
        ├── predictedValue
        ├── category
        ├── confidence
        └── predictionDate
```

### 🎯 Próximos Pasos

1. **Integrar en tu UI**: Usa los servicios en tus widgets
2. **Crear Provider**: Wrap los servicios con Provider para estado global
3. **Implementar pantallas**:
   - Login/Register
   - Lista de gastos
   - Dashboard con gráficas
   - Predicciones y recomendaciones

### 💡 Ejemplo de Integración con Provider

```dart
// providers/expense_provider.dart
import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/expense_firestore_service.dart';
import 'package:gestor_de_gastos_jc/core/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  void loadExpenses(String userId) {
    _isLoading = true;
    notifyListeners();

    _service.getExpenses(userId).listen((expenses) {
      _expenses = expenses;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _service.createExpense(expense);
    // El stream se actualizará automáticamente
  }

  Future<void> deleteExpense(String expenseId) async {
    await _service.deleteExpense(expenseId);
  }
}
```

### 📚 Documentación Adicional

- **FIREBASE_SETUP.md**: Documentación técnica completa
- **firestore.rules**: Reglas de seguridad desplegadas

### 🚀 Modelo Predictivo

El servicio ML actual incluye:
- ✅ Predicciones básicas usando promedios históricos
- ✅ Análisis de patrones de gasto
- ✅ Recomendaciones de ahorro (regla 50/30/20)
- ✅ Exportación de datos en CSV/JSON

**Futuras mejoras** para el modelo predictivo:
- Integración con Firebase ML Kit
- Modelos de series temporales (ARIMA, Prophet)
- Redes neuronales LSTM para predicciones más precisas
- Detección de anomalías en gastos
- Clustering de patrones de comportamiento

### ⚡ Comandos Útiles

```bash
# Desplegar reglas de seguridad
firebase deploy --only "firestore:rules"

# Ver logs de Firestore
firebase firestore:logs

# Exportar datos
gcloud firestore export gs://[BUCKET_NAME]
```

### 🎨 Características del Sistema

- 🔄 **Sincronización en tiempo real** con Streams
- 📱 **Funciona offline** con cache de Firestore
- 🔐 **Seguridad robusta** con reglas validadas
- 📊 **Análisis predictivo** básico implementado
- 💾 **Exportación de datos** para ML externo
- ⚡ **Consultas optimizadas** con índices

---

¿Necesitas ayuda para integrar estos servicios en tu UI o crear las pantallas de login/gastos?
