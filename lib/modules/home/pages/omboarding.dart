import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenOnboarding extends StatefulWidget {
  const ScreenOnboarding({super.key});

  @override
  _ScreenOnboardingState createState() => _ScreenOnboardingState();
}

class _ScreenOnboardingState extends State<ScreenOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _appVersion = 'Cargando...';

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.account_balance_wallet_outlined,
      title: '¡Bienvenido a Gestor de Gastos!',
      description: 'Controla tus finanzas de manera inteligente y sencilla',
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.primaryPurple],
      ),
    ),
    OnboardingPage(
      icon: Icons.trending_down,
      title: 'Registra tus Gastos',
      description: 'Lleva un control detallado de todos tus gastos por categorías',
      gradient: LinearGradient(
        colors: [AppColors.primaryPurple, AppColors.primaryRed],
      ),
    ),
    OnboardingPage(
      icon: Icons.savings_outlined,
      title: 'Establece Metas de Ahorro',
      description: 'Define tus objetivos financieros y alcánzalos paso a paso',
      gradient: LinearGradient(
        colors: [AppColors.primaryGreen, AppColors.primaryOrange],
      ),
    ),
    OnboardingPage(
      icon: Icons.notifications_active_outlined,
      title: 'Recibe Recordatorios',
      description: 'Notificaciones inteligentes para registrar gastos y recomendaciones',
      gradient: LinearGradient(
        colors: [AppColors.primaryOrange, AppColors.primaryBlue],
      ),
    ),
    OnboardingPage(
      icon: Icons.smart_toy_outlined,
      title: 'Asistente IA',
      description: 'Obtén consejos personalizados con nuestro chatbot inteligente',
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.primaryPurple],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Marcar onboarding como completado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    // Navegar al home
    if (mounted) {
      context.go('/login');
    }
  }

  void _skipOnboarding() async {
    await _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: AnimatedGradientBackground(
        colors: [
          AppColors.primaryBlue,
          AppColors.primaryColor,
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Botón de Saltar
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        color: AppColors.warningTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              // PageView con las pantallas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Indicadores de página
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),
              
              // Botón de siguiente/comenzar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Comenzar' : 'Siguiente',
                      style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Versión
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Versión $_appVersion',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.backgroundColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono con gradiente
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          
          // Título
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.warningTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Descripción
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.warningTextColor.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.warningTextColor
            : AppColors.warningTextColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Clase auxiliar para las páginas del onboarding
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
