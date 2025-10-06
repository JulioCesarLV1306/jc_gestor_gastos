import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/services/user_service.dart';

class ScreenOnboarding extends StatefulWidget {
  const ScreenOnboarding({super.key});

  @override
  _ScreenOnboardingState createState() => _ScreenOnboardingState();
}

class _ScreenOnboardingState extends State<ScreenOnboarding> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final UserService _userService = UserService();
 String _appVersion = 'Cargando...';
  @override
  void initState() {
    super.initState();
    _userService.initHive(); // Inicializar Hive para UserService
    _loadAppVersion(); // Cargar la versión de la app
  }
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version; // Obtiene el versionName
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      // Guardar datos en Hive
      await _userService.saveUserData('name', _nameController.text);
      await _userService.saveUserData('email', _emailController.text);

      // Marcar onboarding como completado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted', true);

      // Navegar a la pantalla principal
      context.go('/home');
    }
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Center(
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //logo
                      Image.asset(
                        'assets/img/logo1.png',
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        'Completa tu información:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: AppColors.warningTextColor),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        style: TextStyle(
                            color: AppColors.warningTextColor), //color de texto
                        //color de texto de la etiqueta
                        cursorColor: AppColors.warningTextColor,
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle:
                                TextStyle(color: AppColors.warningTextColor)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        style: TextStyle(
                            color: AppColors.warningTextColor), //color de texto
                        //color de texto de la etiqueta
                        cursorColor: AppColors.warningTextColor,
                        controller: _emailController,
                        decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle:
                                TextStyle(color: AppColors.warningTextColor)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Por favor ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warningTextColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          onPressed: _saveUserData,
                          child: Text('Guardar y continuar',
                              style: TextStyle(
                                  color: AppColors.backgroundColor,
                                  fontSize: 14)),
                        ),
                      ),

                      Text(
                        'Versión $_appVersion',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.backgroundColor.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
