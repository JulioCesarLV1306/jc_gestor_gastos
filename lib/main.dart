import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gestor_de_gastos_jc/config/services/notification_service.dart';
import 'package:gestor_de_gastos_jc/config/services/scheduled_notification_service.dart';
import 'package:gestor_de_gastos_jc/core/models/presupuesto_model.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:gestor_de_gastos_jc/modules/chatbot/chat_provider.dart';
import 'package:gestor_de_gastos_jc/routes/routers.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// Handler de notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Mensaje en segundo plano: ${message.messageId}');
}
void main() async{
   WidgetsFlutterBinding.ensureInitialized();
   
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
   
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configurar handler de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inicializar servicios de notificaciones
  await NotificationService().initialize();
  await ScheduledNotificationService().initialize();
  
  // Inicializar Hive
  await Hive.initFlutter();
  // Registrar adaptadores
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PresupuestoModelAdapter());
  }
  // Abrir la caja de Hive para gastos
  // Abrir la caja de Hive
  await Hive.openBox<PresupuestoModel>('presupuestoBox');
  
  // Abrir caja de configuración para Colab ML
  await Hive.openBox('config');
// Leer el estado del onboarding
  final prefs = await SharedPreferences.getInstance();
  hasCompletedOnboarding = prefs.getBool('onboardingCompleted') ?? false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider debe ser el primero para que esté disponible
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // ProviderHome no se inicializa automáticamente, se hará en ScreenHome
        ChangeNotifierProvider(
          create: (_) => ProviderHome(),
        ),
        // ChatProvider para mantener el estado del chatbot
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: createRouter(),
        title: 'Gestor de Gastos',
        theme: ThemeData(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}