import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _appVersion = 'Cargando...';

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    print('🔐 Intentando login con: ${_emailController.text.trim()}');

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        print('✅ Login exitoso - Usuario: ${authProvider.user?.email}');
        print('🔐 isAuthenticated: ${authProvider.isAuthenticated}');
        print('🔐 emailVerified: ${authProvider.user?.emailVerified}');

        // Verificar si el email está verificado
        if (authProvider.user != null && !authProvider.user!.emailVerified) {
          print('⚠️ Email no verificado - Mostrando diálogo');

          // Mostrar diálogo informando que el email no está verificado
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.primaryColor,
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Email No Verificado',
                      style: TextStyle(color: AppColors.warningTextColor),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu correo electrónico aún no ha sido verificado.',
                    style: TextStyle(
                        color: AppColors.warningTextColor.withOpacity(0.8)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Por favor, revisa tu bandeja de entrada (y spam) para verificar tu cuenta.',
                    style: TextStyle(
                        color: AppColors.warningTextColor.withOpacity(0.8)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '¿No recibiste el correo?',
                    style: TextStyle(
                      color: AppColors.warningTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      await authProvider.user?.sendEmailVerification();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Correo de verificación reenviado'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al reenviar correo: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Reenviar Correo',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Aún así permitir continuar (comentario en el código dice que no se cierra sesión)
                    context.go('/home');
                  },
                  child: Text(
                    'Continuar de todos modos',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        }

        // Si el email está verificado, navegar a home directamente
        print('✅ Email verificado - Navegando a /home...');
        print('🔐 Verificación final - isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.user?.email}');
        
        if (!mounted) {
          print('❌ Widget no montado, no se puede navegar');
          return;
        }
        
        // Navegar a home
        context.go('/home');
        print('✅ Navegación ejecutada a /home');
      } else {
        print('❌ Login falló: ${authProvider.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/img/logo1.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 24,
                            // fontWeight: FontWeight.bold,
                            color: AppColors.warningTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Ingresa a tu cuenta',
                          style: TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.w300,
                            color: AppColors.warningTextColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Campo de email
                        TextFormField(
                          style: TextStyle(color: AppColors.warningTextColor),
                          cursorColor: AppColors.warningTextColor,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle:
                                TextStyle(color: AppColors.warningTextColor),
                            prefixIcon: Icon(Icons.email,
                                color: AppColors.warningTextColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.warningTextColor
                                      .withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: AppColors.warningTextColor),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Por favor ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campo de contraseña
                        TextFormField(
                          style: TextStyle(color: AppColors.warningTextColor),
                          cursorColor: AppColors.warningTextColor,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle:
                                TextStyle(color: AppColors.warningTextColor),
                            prefixIcon: Icon(Icons.lock,
                                color: AppColors.warningTextColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.warningTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.warningTextColor
                                      .withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: AppColors.warningTextColor),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Olvidaste tu contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style:
                                  TextStyle(color: AppColors.warningTextColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de login
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warningTextColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.backgroundColor,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          color: AppColors.backgroundColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color:
                                    AppColors.warningTextColor.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O',
                                style: TextStyle(
                                  color: AppColors.warningTextColor
                                      .withOpacity(0.6),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color:
                                    AppColors.warningTextColor.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              context.push('/register');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              side:
                                  BorderSide(color: AppColors.warningTextColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Crear cuenta nueva',
                              style: TextStyle(
                                color: AppColors.warningTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Versión
                        Text(
                          'Versión $_appVersion',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.backgroundColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
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
