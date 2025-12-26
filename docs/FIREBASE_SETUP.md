# Configuración de Firebase para Gestor de Gastos

## Estructura de Datos en Firestore

Este proyecto utiliza Firebase como backend para autenticación y almacenamiento de datos.

### Colecciones Principales

#### 1. users
Almacena los perfiles de usuario.
```
users/{userId}
  - uid: string
  - email: string
  - displayName: string?
  - photoUrl: string?
  - createdAt: timestamp
  - lastLoginAt: timestamp?
```

#### 2. expenses
Almacena todos los gastos de los usuarios.
```
expenses/{expenseId}
  - userId: string (referencia al usuario)
  - description: string
  - amount: number
  - category: string
  - date: timestamp
  - isRecurrent: boolean
  - createdAt: timestamp
```

#### 3. budgets
Almacena los presupuestos configurados por los usuarios.
```
budgets/{budgetId}
  - userId: string
  - category: string
  - amount: number
  - period: string (monthly, weekly, yearly)
  - startDate: timestamp
  - endDate: timestamp?
  - createdAt: timestamp
```

#### 4. savings
Almacena las metas de ahorro de los usuarios.
```
savings/{savingId}
  - userId: string
  - goal: string
  - targetAmount: number
  - currentAmount: number
  - targetDate: timestamp
  - createdAt: timestamp
```

#### 5. predictions
Almacena predicciones generadas por el modelo de ML.
```
predictions/{predictionId}
  - userId: string
  - type: string (expense, saving, budget_alert)
  - predictedValue: number
  - category: string
  - predictionDate: timestamp
  - confidence: number (0.0 - 1.0)
  - metadata: map
  - createdAt: timestamp
```

## Reglas de Seguridad

Las reglas de seguridad están definidas en `firestore.rules` y garantizan:

1. **Autenticación obligatoria**: Todos los usuarios deben estar autenticados
2. **Aislamiento de datos**: Cada usuario solo puede acceder a sus propios datos
3. **Validación de datos**: Los campos requeridos y tipos de datos son validados
4. **Protección de userId**: No se permite cambiar el userId en actualizaciones

## Servicios Implementados

### AuthService
- `registerWithEmail()` - Registro de nuevos usuarios
- `signInWithEmail()` - Inicio de sesión
- `signOut()` - Cerrar sesión
- `resetPassword()` - Recuperación de contraseña
- `updateUserProfile()` - Actualizar perfil
- `getUserProfile()` - Obtener perfil del usuario
- `deleteAccount()` - Eliminar cuenta

### ExpenseService
- `createExpense()` - Crear nuevo gasto
- `getExpenses()` - Obtener todos los gastos del usuario
- `getExpensesByDateRange()` - Filtrar por fechas
- `getExpensesByCategory()` - Filtrar por categoría
- `updateExpense()` - Actualizar gasto
- `deleteExpense()` - Eliminar gasto
- `getTotalExpensesByPeriod()` - Calcular total por período
- `getExpensesByCategories()` - Obtener gastos agrupados por categoría

### BudgetFirestoreService
- `createBudget()` - Crear presupuesto
- `getBudgets()` - Obtener presupuestos
- `getActiveBudgets()` - Obtener presupuestos activos
- `getBudgetByCategory()` - Buscar por categoría
- `updateBudget()` - Actualizar presupuesto
- `deleteBudget()` - Eliminar presupuesto

### SavingFirestoreService
- `createSaving()` - Crear meta de ahorro
- `getSavings()` - Obtener todas las metas
- `getActiveSavings()` - Obtener metas activas
- `getCompletedSavings()` - Obtener metas completadas
- `updateSaving()` - Actualizar meta
- `addAmountToSaving()` - Agregar dinero al ahorro
- `subtractAmountFromSaving()` - Retirar dinero
- `deleteSaving()` - Eliminar meta

### PredictionFirestoreService
- `createPrediction()` - Crear predicción
- `getPredictions()` - Obtener predicciones
- `getPredictionsByType()` - Filtrar por tipo
- `getFuturePredictions()` - Predicciones futuras
- `getPredictionsByCategory()` - Filtrar por categoría
- `deletePrediction()` - Eliminar predicción

### MLService
- `exportTrainingData()` - Exportar datos para entrenamiento
- `generateExpensePrediction()` - Generar predicción de gastos
- `analyzeSpendingPatterns()` - Analizar patrones de gasto
- `generateSavingsRecommendations()` - Generar recomendaciones de ahorro
- `exportToCSV()` - Exportar datos en formato CSV
- `exportToJSON()` - Exportar datos en formato JSON

## Despliegue de Reglas de Seguridad

Para desplegar las reglas de seguridad a Firebase:

```bash
firebase deploy --only firestore:rules
```

## Índices Recomendados

Para optimizar las consultas, crea estos índices en Firebase Console:

### expenses
- Campos: `userId` (Ascending), `date` (Descending)
- Campos: `userId` (Ascending), `category` (Ascending), `date` (Descending)

### budgets
- Campos: `userId` (Ascending), `createdAt` (Descending)
- Campos: `userId` (Ascending), `startDate` (Ascending)

### savings
- Campos: `userId` (Ascending), `createdAt` (Descending)

### predictions
- Campos: `userId` (Ascending), `createdAt` (Descending)
- Campos: `userId` (Ascending), `type` (Ascending), `predictionDate` (Ascending)
- Campos: `userId` (Ascending), `category` (Ascending), `predictionDate` (Ascending)

## Machine Learning

El servicio ML está preparado para:

1. **Exportar datos históricos** para entrenar modelos externos
2. **Generar predicciones básicas** usando promedios históricos
3. **Analizar patrones de gasto** por categoría y período
4. **Generar recomendaciones** de ahorro basadas en la regla 50/30/20

### Futuras Mejoras

- Integración con Firebase ML Kit para modelos personalizados
- Implementación de modelos de series temporales (ARIMA, LSTM)
- Predicciones de tendencias de largo plazo
- Detección de anomalías en gastos
- Recomendaciones personalizadas basadas en comportamiento

## Uso Básico

```dart
// Inicializar servicios
final authService = AuthService();
final expenseService = ExpenseService();
final mlService = MLService();

// Registrar usuario
final user = await authService.registerWithEmail(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'Usuario',
);

// Crear gasto
final expense = ExpenseModel(
  userId: user!.uid,
  description: 'Compra supermercado',
  amount: 50.00,
  category: 'Alimentación',
  date: DateTime.now(),
);
await expenseService.createExpense(expense);

// Generar predicción
final prediction = await mlService.generateExpensePrediction(
  userId: user.uid,
  category: 'Alimentación',
  daysToPredict: 30,
);
```

## Notas Importantes

1. **Seguridad**: Nunca expongas tus credenciales de Firebase
2. **Costos**: Monitorea el uso de Firestore para evitar cargos excesivos
3. **Índices**: Crea índices cuando Firebase lo sugiera en la consola
4. **Backup**: Configura backups automáticos en Firebase Console
5. **ML**: Los modelos actuales son básicos, considera implementar modelos más sofisticados
