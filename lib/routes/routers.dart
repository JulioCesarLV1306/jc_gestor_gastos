import 'package:gestor_de_gastos_jc/modules/home/pages/omboarding.dart';
import 'package:go_router/go_router.dart';
import '../modules/home/screen_home.dart';

bool hasCompletedOnboarding = false; // Cambia esto según el estado real

final GoRouter router = GoRouter(
  initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => ScreenOnboarding(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => ScreenHome(),
    ),
  ],
);