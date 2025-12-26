import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:gestor_de_gastos_jc/config/services/user_service.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';
import 'package:gestor_de_gastos_jc/modules/chatbot/chatbot_screen.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:gestor_de_gastos_jc/widgets/custom_card.dart';
import 'package:gestor_de_gastos_jc/widgets/custom_budget_dialog.dart';
import 'package:gestor_de_gastos_jc/widgets/custom_savings_dialog.dart';
import 'package:gestor_de_gastos_jc/widgets/custon_drawer.dart';
import 'package:gestor_de_gastos_jc/widgets/buttons/index.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../bd/bd.dart';
import 'pages/screen_list_gastos.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  // ==================== PROPIEDADES ====================
  final UserService _userService = UserService();
  final _advancedDrawerController = AdvancedDrawerController();
  String _userName = 'Usuario';
  String _userEmail = 'Sin correo';

  // ==================== CICLO DE VIDA ====================
  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    // Esperar un momento para que AuthProvider se inicialice
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Verificar autenticación
    final authProvider = context.read<AuthProvider>();
    final firebaseUser = authProvider.user;
    
    if (firebaseUser != null) {
      print('✅ ScreenHome: Usuario autenticado detectado - ${firebaseUser.email}');
      
      // Reinicializar el provider con el usuario autenticado
      final providerHome = context.read<ProviderHome>();
      await providerHome.init();
    } else {
      print('⚠️ ScreenHome: No hay usuario autenticado');
    }
    
    _loadUserName();
  }

  // ==================== MÉTODOS PRIVADOS ====================
  Future<void> _loadUserName() async {
    // Obtener datos del usuario autenticado en Firebase
    final authProvider = context.read<AuthProvider>();
    final firebaseUser = authProvider.user;
    
    if (firebaseUser != null) {
      // Usar datos de Firebase si está autenticado
      setState(() {
        _userName = firebaseUser.displayName ?? 'Usuario';
        _userEmail = firebaseUser.email ?? 'Sin correo';
      });
      
      print('👤 Usuario autenticado: $_userName ($_userEmail)');
      
      // También cargar desde Hive para datos adicionales si es necesario
      await _userService.initHive();
      final hiveName = _userService.getUserData('name');
      
      // Si hay nombre en Hive y no en Firebase, usar Hive
      if (hiveName != null && firebaseUser.displayName == null) {
        setState(() {
          _userName = hiveName;
        });
      }
    } else {
      // Fallback a Hive si no hay usuario de Firebase
      await _userService.initHive();
      final name = _userService.getUserData('name') ?? 'Usuario';
      final email = _userService.getUserData('email') ?? 'Sin correo';

      setState(() {
        _userEmail = email;
        _userName = name;
      });
      
      print('⚠️ No hay usuario autenticado en Firebase, usando datos locales');
    }
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  /// Muestra el diálogo para establecer el presupuesto
  void _mostrarDialogoPresupuesto(BuildContext context, ProviderHome provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => CustomBudgetDialog(
        title: 'Presupuesto Mensual',
        hint: 'Establece tu presupuesto mensual para gestionar mejor tus finanzas',
        labelText: 'Cantidad del presupuesto',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.primaryBlue,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryPurple,
          ],
        ),
        onSave: (value) async {
          await provider.establecerPresupuesto(value);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Presupuesto establecido: \$${value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
      ),
    );
  }

  /// Muestra el diálogo para establecer la meta de ahorro
  void _mostrarDialogoMetaAhorro(BuildContext context, ProviderHome provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => CustomSavingsDialog(
        onSave: (meta, semanas) async {
          try {
            await provider.establecerMetaAhorro(meta, semanas);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Meta establecida: \$${meta.toStringAsFixed(2)} en $semanas semanas',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Error: ${e.toString()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final providerHome = Provider.of<ProviderHome>(context);
    
    return AdvancedDrawer(
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backdrop: _buildDrawerBackdrop(),
      drawer: CustonDrawer(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(providerHome),
        floatingActionButton: _buildChatButton(),
      ),
    );
  }

  /// Construye el botón flotante de chat
  Widget _buildChatButton() {
    return FloatingChatButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatbotScreen(),
          ),
        );
      },
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryBlue,
          AppColors.primaryPurple,
        ],
      ),
      icon: Icons.smart_toy_outlined,
      size: 65,
      showPulseAnimation: true,
    );
  }

  // ==================== WIDGETS DE CONSTRUCCIÓN ====================
  
  /// Construye el fondo del drawer
  Widget _buildDrawerBackdrop() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey, Colors.blueGrey.withOpacity(0.2)],
        ),
      ),
    );
  }

  /// Construye el AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      leading: ClipOval(
        child: Image.asset(
          'assets/img/logo1.png',
          fit: BoxFit.cover,
        ),
      ),
      title: const Text(
        'Gestor de Gastos',
        style: TextStyle(
          color: AppColors.warningTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/img/menu.svg',
            color: AppColors.warningTextColor,
            height: 40,
            width: 40,
          ),
          onPressed: _handleMenuButtonPressed,
        ),
      ],
    );
  }

  /// Construye el cuerpo principal
  Widget _buildBody(ProviderHome providerHome) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildUserHeader(),
              _buildConfigurationSection(providerHome),
              const Divider(),
              const SizedBox(height: 16),
              _buildStatisticsSection(providerHome),
              const SizedBox(height: 16),
              const Divider(),
              _buildExpenseFormSection(providerHome),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado de usuario
  Widget _buildUserHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserInfo(),
          _buildAnimatedLogo(),
        ],
      ),
    );
  }

  /// Construye la información del usuario
  Widget _buildUserInfo() {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_userName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _userEmail,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Text(
              'Bienvenido a tu app de Finanzas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye el avatar del usuario
  Widget _buildUserAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: AnimatedGradientBackground(
            colors: const [
              AppColors.primaryTextColor,
              AppColors.primaryColor,
              AppColors.primaryBlue,
            ],
            child: Center(
              child: SvgPicture.asset(
                'assets/img/user.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.warningTextColor,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.cover,
                height: 40,
                width: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el logo animado
  Widget _buildAnimatedLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.3),
            AppColors.primaryOrange.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Blob.animatedRandom(
        size: 80,
        edgesCount: 5,
        minGrowth: 4,
        loop: true,
        child: const Icon(
          Icons.monetization_on,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Construye la sección de configuración (presupuesto y ahorro)
  Widget _buildConfigurationSection(ProviderHome providerHome) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;
        
        // Espaciado responsivo
        final verticalMargin = isMobile ? 16.0 : isTablet ? 20.0 : 24.0;
        final spacing = isMobile ? 12.0 : isTablet ? 16.0 : 20.0;
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: verticalMargin),
          child: Column(
            children: [
              // Card de Presupuesto
              ConfigCardButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Presupuesto Mensual',
                subtitle: 'Gestiona tu límite',
                value: providerHome.presupuestoGeneral,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryPurple,
                  ],
                ),
                iconColor: AppColors.primaryBlue,
                onPressed: () => _mostrarDialogoPresupuesto(context, providerHome),
              ),
              SizedBox(height: spacing),
              // Card de Ahorro
              ConfigCardButton(
                icon: Icons.savings_outlined,
                label: 'Meta de Ahorro',
                subtitle: 'Planifica tu futuro',
                value: providerHome.metaAhorro,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.9),
                    AppColors.primaryOrange.withOpacity(0.8),
                  ],
                ),
                iconColor: AppColors.primaryGreen,
                onPressed: () => _mostrarDialogoMetaAhorro(context, providerHome),
              ),
            ],
          ),
        );
      },
    );
  }



  /// Construye la sección de estadísticas (cards)
  Widget _buildStatisticsSection(ProviderHome providerHome) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar espaciado según el ancho disponible
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;
        final bool isTablet = screenWidth >= 600 && screenWidth < 1200;
        
        final spacing = isMobile ? 8.0 : isTablet ? 12.0 : 16.0;
        
        // Lista de cards
        final cards = [
          CustomCard(
            icono: Icons.account_balance,
            titulo: 'Presupuesto General',
            subtitulo: 'de saldo',
            numeroGastos: '\$${providerHome.presupuestoGeneral.toStringAsFixed(2)}',
            colorFondo: AppColors.primaryBlue,
          ),
          CustomCard(
            titulo: 'Saldo Restante',
            subtitulo: 'de saldo',
            numeroGastos: '\$${providerHome.saldoRestante.toStringAsFixed(2)}',
            colorFondo: AppColors.primaryRed,
          ),
          CustomCard(
            icono: Icons.money_off,
            titulo: 'Gastos Totales',
            subtitulo: 'Gastos registrados',
            numeroGastos: providerHome.gastos.length.toString(),
            colorFondo: AppColors.primaryPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenListGastos(),
                ),
              );
            },
          ),
          CustomCard(
            icono: Icons.savings,
            subtitulo: 'Ahorro acumulado',
            titulo: 'Ahorro recomendado',
            numeroGastos: providerHome.ahorro.toString(),
            colorFondo: AppColors.primaryOrange,
          ),
        ];
        
        // Usar Wrap para layout responsive automático
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.spaceBetween,
          children: cards,
        );
      },
    );
  }

  /// Construye la sección de formulario de gastos
  Widget _buildExpenseFormSection(ProviderHome providerHome) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Registrar Gasto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.49,
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _ExpenseForm(providerHome: providerHome),
          ),
        ),
      ],
    );
  }
}

// ==================== WIDGETS AUXILIARES ====================

/// Widget para el formulario de registro de gastos
class _ExpenseForm extends StatelessWidget {
  final ProviderHome providerHome;

  const _ExpenseForm({required this.providerHome});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: providerHome.formKey,
      child: ListView(
        children: [
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildAmountField(),
          const SizedBox(height: 16),
          _buildDateSelector(context),
          const SizedBox(height: 16),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  /// Construye el dropdown de categoría
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(16),
      style: const TextStyle(
        color: AppColors.warningTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      value: providerHome.categoriaSeleccionada != 'Sin categoría'
          ? providerHome.categoriaSeleccionada
          : null,
      decoration: InputDecoration(
        labelText: 'Categoría',
        labelStyle: TextStyle(
          color: AppColors.warningTextColor.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: AppColors.primaryBlue,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 2,
          ),
        ),
      ),
      items: BaseDeDatosSimulada.obtenerCategorias()
          .map((categoria) => DropdownMenuItem<String>(
                value: categoria.nombre,
                child: Text(categoria.nombre),
              ))
          .toList(),
      onChanged: (value) {
        providerHome.categoriaSeleccionada = value!;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecciona una categoría';
        }
        return null;
      },
    );
  }

  /// Construye el campo de descripción
  Widget _buildDescriptionField() {
    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      style: const TextStyle(
        color: AppColors.warningTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      controller: providerHome.descripcionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        labelStyle: TextStyle(
          color: AppColors.warningTextColor.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: AppColors.primaryBlue,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa una descripción';
        }
        return null;
      },
    );
  }

  /// Construye el campo de cantidad
  Widget _buildAmountField() {
    return TextFormField(
      style: const TextStyle(
        color: AppColors.warningTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      controller: providerHome.cantidadController,
      decoration: InputDecoration(
        labelText: 'Cantidad (\$)',
        labelStyle: TextStyle(
          color: AppColors.warningTextColor.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.attach_money,
          color: AppColors.primaryGreen,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 2,
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa una cantidad';
        }
        if (double.tryParse(value) == null) {
          return 'Por favor, ingresa un número válido';
        }
        return null;
      },
    );
  }

  /// Construye el selector de fecha
  Widget _buildDateSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => providerHome.seleccionarFecha(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha del gasto',
                        style: TextStyle(
                          color: AppColors.warningTextColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        providerHome.fechaSeleccionada == null
                            ? 'Seleccionar fecha'
                            : DateFormat('dd/MM/yyyy').format(
                                providerHome.fechaSeleccionada!),
                        style: const TextStyle(
                          color: AppColors.warningTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.warningTextColor.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el botón de guardar
  Widget _buildSubmitButton(BuildContext context) {
    return GradientButton(
      text: 'Guardar Gasto',
      icon: Icons.add_circle_outline,
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.primaryBlue,
          AppColors.primaryPurple,
        ],
      ),
      shadowColor: AppColors.primaryBlue,
      onPressed: () async {
        await providerHome.guardarGasto(context);
      },
    );
  }
}
