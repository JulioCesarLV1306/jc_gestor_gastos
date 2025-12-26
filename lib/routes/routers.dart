import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_de_gastos_jc/modules/home/pages/omboarding.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/home/screen_home.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/auth/forgot_password_page.dart';
import '../modules/ml/colab_ml_page.dart';
import '../modules/ml/ml_training_page.dart';

bool hasCompletedOnboarding = false;

// Notificador para cambios de autenticación
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('🔄 AuthNotifier: Estado de autenticación cambió - ${user?.email ?? "sin usuario"}');
      notifyListeners();
    });
  }
}

// Crear el router
GoRouter createRouter() {
  final authNotifier = AuthNotifier();
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier, // Escuchar cambios de autenticación
    routes: [
      // Ruta inicial que redirige según el estado
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          // 1. Verificar onboarding
          final prefs = await SharedPreferences.getInstance();
          final hasSeenOnboarding = prefs.getBool('onboardingCompleted') ?? false;
          
          if (!hasSeenOnboarding) {
            return '/onboarding';
          }
          
          // 2. Verificar autenticación de Firebase
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('🔐 Router: Usuario autenticado detectado - ${user.email}');
            return '/home';
          }
          
          print('🔐 Router: No hay usuario autenticado, ir a login');
          return '/login';
        },
      ),
      
      // Onboarding (primera vez que abre la app)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ScreenOnboarding(),
      ),
      
      // Rutas de Autenticación
      GoRoute(
        path: '/login',
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('🔐 Router: Usuario ya autenticado, redirigir a home');
            return '/home';
          }
          return null; // Permitir acceso a login
        },
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('🔐 Router: Usuario ya autenticado, redirigir a home');
            return '/home';
          }
          return null; // Permitir acceso a register
        },
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Home (solo para usuarios autenticados)
      GoRoute(
        path: '/home',
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('🔐 Router: No autenticado, redirigir a login');
            return '/login';
          }
          return null; // Permitir acceso a home
        },
        builder: (context, state) => const ScreenHome(),
      ),
      
      // ML con Colab
      GoRoute(
        path: '/colab-ml',
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('🔐 Router: No autenticado, redirigir a login');
            return '/login';
          }
          return null;
        },
        builder: (context, state) => const ColabMLPage(),
      ),
      
      // ML Training (local)
      GoRoute(
        path: '/ml-training',
        redirect: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('🔐 Router: No autenticado, redirigir a login');
            return '/login';
          }
          return null;
        },
        builder: (context, state) => const MLTrainingPage(),
      ),
    ],
  );
}