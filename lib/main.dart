import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/core/models/presupuesto_model.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:gestor_de_gastos_jc/routes/routers.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
    // Inicializar Hive
  await Hive.initFlutter();
  // Registrar adaptadores
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PresupuestoModelAdapter());
  }
  // Abrir la caja de Hive para gastos
  // Abrir la caja de Hive
  await Hive.openBox<PresupuestoModel>('presupuestoBox');
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
                 ChangeNotifierProvider(
          create: (_) {
            final providerHome = ProviderHome();
            providerHome.init(); // Llamar al método init al inicio
            return providerHome;
          },
        ),
      ],
      child: MaterialApp.router(
       routerConfig: router,
        title: 'Flutter Demo',
        theme: ThemeData(
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

