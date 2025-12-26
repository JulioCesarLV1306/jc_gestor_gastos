# Sistema de Autenticación y Notificaciones Push

## ✅ Implementación Completada

Se ha implementado un sistema completo de autenticación con Firebase y notificaciones push para recordatorios y recomendaciones.

## 📦 Componentes Implementados

### 1. Autenticación Firebase
- **AuthService**: Servicio completo de autenticación
- **AuthProvider**: Provider para manejar el estado de autenticación
- **LoginPage**: Pantalla de inicio de sesión
- **RegisterPage**: Pantalla de registro
- **ForgotPasswordPage**: Recuperación de contraseña

### 2. Notificaciones Push
- **NotificationService**: Firebase Cloud Messaging (FCM)
- **ScheduledNotificationService**: Notificaciones programadas locales
- Permisos configurados en Android
- Handler de notificaciones en segundo plano

## 🔐 Uso de Autenticación

### Registro de Usuario

```dart
import 'package:provider/provider.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';

// En tu widget
final authProvider = context.read<AuthProvider>();

final success = await authProvider.register(
  email: 'usuario@example.com',
  password: 'password123',
  displayName: 'Juan Pérez',
);

if (success) {
  print('Usuario registrado exitosamente');
  // Navegar a home
} else {
  print('Error: ${authProvider.errorMessage}');
}
```

### Inicio de Sesión

```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.signIn(
  email: 'usuario@example.com',
  password: 'password123',
);

if (success) {
  // Usuario autenticado
  String userId = authProvider.user!.uid;
  String email = authProvider.user!.email!;
}
```

### Verificar Estado de Autenticación

```dart
// En cualquier parte de tu app
final authProvider = context.watch<AuthProvider>();

if (authProvider.isAuthenticated) {
  // Usuario conectado
  print('Usuario: ${authProvider.user!.displayName}');
} else {
  // Mostrar login
}
```

### Cerrar Sesión

```dart
await context.read<AuthProvider>().signOut();
```

## 🔔 Uso de Notificaciones

### Inicialización (Ya está en main.dart)

Las notificaciones se inicializan automáticamente al arrancar la app.

### Guardar Token FCM del Usuario

```dart
import 'package:gestor_de_gastos_jc/config/services/notification_service.dart';

final notificationService = NotificationService();
final userId = authProvider.user!.uid;

// Guardar token en Firestore para enviar notificaciones personalizadas
await notificationService.saveTokenToDatabase(userId);
```

### Programar Recordatorio Diario de Gastos

```dart
import 'package:gestor_de_gastos_jc/config/services/scheduled_notification_service.dart';

final scheduledService = ScheduledNotificationService();

// Programar recordatorio todos los días a las 8:00 PM
await scheduledService.scheduleDailyExpenseReminder(
  userId: userId,
  hour: 20,  // 8 PM
  minute: 0,
);
```

### Programar Recordatorio Semanal

```dart
// Recordatorio cada lunes a las 9:00 AM
await scheduledService.scheduleWeeklyExpenseReminder(
  userId: userId,
  dayOfWeek: 1,  // 1 = Lunes, 7 = Domingo
  hour: 9,
  minute: 0,
);
```

### Enviar Recomendación de Inversión

```dart
// Programar recomendación basada en análisis ML
await scheduledService.scheduleInvestmentRecommendation(
  userId: userId,
  scheduledTime: DateTime.now().add(Duration(hours: 2)),
);
```

### Alerta de Presupuesto

```dart
// Enviar alerta cuando se excede el 80% del presupuesto
await scheduledService.scheduleBudgetAlert(
  userId: userId,
  category: 'Alimentación',
  budgetAmount: 1000.0,
  currentAmount: 850.0,
);
```

### Notificación de Meta Alcanzada

```dart
await scheduledService.sendSavingsGoalReached(
  userId: userId,
  goalName: 'Vacaciones 2025',
  amount: 5000.0,
);
```

## 📱 Ejemplo Completo de Integración

### En tu HomePage después de login:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';
import 'package:gestor_de_gastos_jc/config/services/notification_service.dart';
import 'package:gestor_de_gastos_jc/config/services/scheduled_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      final userId = authProvider.user!.uid;
      
      // Guardar token FCM
      final notificationService = NotificationService();
      await notificationService.saveTokenToDatabase(userId);
      
      // Programar recordatorios diarios
      final scheduledService = ScheduledNotificationService();
      await scheduledService.scheduleDailyExpenseReminder(
        userId: userId,
        hour: 20,  // 8:00 PM
        minute: 0,
      );
      
      // Suscribirse a topics generales
      await notificationService.subscribeToTopic('gastos_tips');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              // Navegar a login
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Text(
                  '¡Hola, ${authProvider.user?.displayName ?? 'Usuario'}!',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Ejemplo: Generar recomendación inmediata
                final scheduledService = ScheduledNotificationService();
                await scheduledService.scheduleInvestmentRecommendation(
                  userId: context.read<AuthProvider>().user!.uid,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recomendación programada'),
                  ),
                );
              },
              child: const Text('Generar Recomendación'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Flujo de Notificaciones Automáticas

### 1. Al Registrar Usuario
```dart
// Después del registro exitoso
final userId = user!.uid;

// Guardar token
await NotificationService().saveTokenToDatabase(userId);

// Programar recordatorios
await ScheduledNotificationService().scheduleDailyExpenseReminder(
  userId: userId,
  hour: 20,
  minute: 0,
);
```

### 2. Al Crear un Gasto
```dart
// Después de crear un gasto, verificar presupuesto
final budgetService = BudgetFirestoreService();
final budget = await budgetService.getBudgetByCategory(
  userId: userId,
  category: expense.category,
);

if (budget != null) {
  // Calcular total gastado
  final total = await ExpenseService().getTotalExpensesByPeriod(...);
  
  // Si está cerca del límite, enviar alerta
  if (total >= budget.amount * 0.8) {
    await ScheduledNotificationService().scheduleBudgetAlert(
      userId: userId,
      category: expense.category,
      budgetAmount: budget.amount,
      currentAmount: total,
    );
  }
}
```

### 3. Al Completar una Meta de Ahorro
```dart
// Cuando currentAmount >= targetAmount
if (saving.currentAmount >= saving.targetAmount) {
  await ScheduledNotificationService().sendSavingsGoalReached(
    userId: userId,
    goalName: saving.goal,
    amount: saving.targetAmount,
  );
}
```

### 4. Recomendaciones Periódicas
```dart
// Programar análisis y recomendaciones semanales
// Por ejemplo, cada domingo a las 6:00 PM
await ScheduledNotificationService().scheduleWeeklyExpenseReminder(
  userId: userId,
  dayOfWeek: 7,  // Domingo
  hour: 18,
  minute: 0,
);
```

## 🔄 Actualizar Rutas

Actualiza tu archivo de rutas para incluir las pantallas de autenticación:

```dart
// routes/routers.dart
import 'package:go_router/go_router.dart';
import 'package:gestor_de_gastos_jc/modules/auth/login_page.dart';
import 'package:gestor_de_gastos_jc/modules/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    // ... más rutas
  ],
);
```

## 📊 Notificaciones desde el Backend

Para enviar notificaciones desde tu servidor o Cloud Functions:

```javascript
// Cloud Function ejemplo (Node.js)
const admin = require('firebase-admin');

async function sendExpenseReminder(userId) {
  // Obtener token del usuario
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const fcmToken = userDoc.data().fcmToken;

  if (fcmToken) {
    const message = {
      notification: {
        title: '📝 Registra tus gastos',
        body: '¿Ya registraste tus gastos de hoy?',
      },
      data: {
        type: 'expense_reminder',
        userId: userId,
      },
      token: fcmToken,
    };

    await admin.messaging().send(message);
  }
}
```

## 🧪 Probar Notificaciones

### En desarrollo:
```dart
// Botón de prueba en tu UI
ElevatedButton(
  onPressed: () async {
    final scheduledService = ScheduledNotificationService();
    await scheduledService.scheduleDailyExpenseReminder(
      userId: 'test-user-id',
      hour: DateTime.now().hour,
      minute: DateTime.now().minute + 1, // En 1 minuto
    );
  },
  child: const Text('Probar Notificación'),
)
```

## 🔒 Permisos Configurados

### Android (Ya configurado en AndroidManifest.xml)
- ✅ `POST_NOTIFICATIONS` (Android 13+)
- ✅ `RECEIVE_BOOT_COMPLETED`
- ✅ `VIBRATE`
- ✅ `WAKE_LOCK`

### iOS
Los permisos se solicitan automáticamente en runtime.

## 📝 Notas Importantes

1. **Token FCM**: Se guarda automáticamente en Firestore bajo `users/{userId}/fcmToken`
2. **Notificaciones Locales**: Funcionan incluso sin conexión a internet
3. **Notificaciones Push**: Requieren conexión y token válido
4. **Background**: Las notificaciones funcionan con la app cerrada
5. **Timezone**: Las notificaciones usan la zona horaria local del dispositivo

## 🚀 Próximos Pasos

1. Integrar las pantallas de login en tu flujo de navegación
2. Personalizar los temas de las pantallas de auth
3. Configurar análisis automáticos para recomendaciones inteligentes
4. Crear Cloud Functions para notificaciones masivas
5. Implementar notificaciones in-app (dentro de la app)

---

¿Todo listo para empezar a usar el sistema de autenticación y notificaciones!
