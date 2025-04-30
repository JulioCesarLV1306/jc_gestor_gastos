import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:gestor_de_gastos_jc/config/services/user_service.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:gestor_de_gastos_jc/widgets/custom_card.dart';
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
  final UserService _userService = UserService();
  String _userName = 'Usuario'; // Valor predeterminado
  String _userEmail = 'Sin correo'; // Valor predeterminado

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Cargar el nombre del usuario desde Hive
  }

  Future<void> _loadUserName() async {
    await _userService.initHive(); // Asegúrate de inicializar Hive
    final name = _userService.getUserData('name') ?? 'Usuario';
    //correo
    final email = _userService.getUserData('email') ?? 'Sin correo';

    setState(() {
      _userEmail = email;
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerHome = Provider.of<ProviderHome>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: //logo de la app
            ClipOval(
          child: Image.asset(
            //logo de la app
            'assets/img/logo1.png',
            fit: BoxFit.cover,
          ),
        ),
        title: const Text('Gestor de Gastos',
            style: TextStyle(
              color: AppColors.warningTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //cliv oval para el perfil
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $_userName',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              'Bienvenido a tu gestor de gastos',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //logo de la app imagen
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Blob.animatedRandom(
                        size: 80,
                        edgesCount: 5,
                        minGrowth: 4,
                        loop: true,
                        child: Icon(
                          Icons.monetization_on,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPresupuestoInfo('Configurar Presupuesto ',
                              providerHome.presupuestoGeneral, Colors.white),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => providerHome.EstablecerPresupuesto(
                            context), // Botón para establecer presupuesto
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomCard(
                          icono: Icons.account_balance,
                          titulo: 'Presupuesto General',
                          subtitulo: 'de saldo',
                          numeroGastos:
                              '\$${providerHome.presupuestoGeneral.toStringAsFixed(2)}', // Formatear el saldo restante
                          colorFondo: AppColors.primaryBlue,
                        ),
                        CustomCard(
                          titulo: 'Saldo Restante',
                          subtitulo: 'de saldo',
                          numeroGastos:
                              '\$${providerHome.saldoRestante.toStringAsFixed(2)}', // Formatear el saldo restante
                          colorFondo: AppColors.primaryRed,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                          titulo: 'Ahorro',
                          numeroGastos: providerHome.ahorro.toString(),
                          colorFondo: AppColors.primaryOrange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  'Registrar Gasto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warningTextColor,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.49, // Limita la altura
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: providerHome.formKey,
                      child: ListView(
                        children: [
                          DropdownButtonFormField<String>(
                            dropdownColor: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            style: TextStyle(
                                color: AppColors
                                    .warningTextColor), //color de texto
                            value: providerHome.categoriaSeleccionada !=
                                    'Sin categoría'
                                ? providerHome.categoriaSeleccionada
                                : null, // Asegúrate de que sea nulo si no hay selección
                            decoration: InputDecoration(
                              //color de texto dentro del campo
                              labelText: 'Categoría',
                              labelStyle:
                                  TextStyle(color: AppColors.warningTextColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppColors.primaryBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: AppColors.warningTextColor),
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
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            //solo mayusculas
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9\s]')),
                            ],
                            style: TextStyle(
                                color: AppColors
                                    .warningTextColor), //color de texto
                            controller: providerHome.descripcionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle:
                                  TextStyle(color: AppColors.warningTextColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppColors.primaryBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.warningTextColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa una descripción';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: TextStyle(
                                color: AppColors
                                    .warningTextColor), //color de texto
                            controller: providerHome.cantidadController,
                            decoration: InputDecoration(
                              labelText: 'Cantidad (\$)',
                              labelStyle:
                                  TextStyle(color: AppColors.warningTextColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppColors.primaryBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.warningTextColor),
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
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  providerHome.fechaSeleccionada == null
                                      ? 'Selecciona una fecha'
                                      : 'Fecha: ${DateFormat('dd/MM/yyyy').format(providerHome.fechaSeleccionada!)}',
                                  style: TextStyle(
                                      color: AppColors
                                          .warningTextColor), //color de texto
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    providerHome.seleccionarFecha(context),
                                child: const Text(
                                  'Seleccionar Fecha',
                                  style: TextStyle(
                                      color: AppColors
                                          .primaryBlue), //color de texto
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                            ),
                            onPressed: () async {
                              await providerHome.guardarGasto(context);
                            },
                            child: const Text('Guardar Gasto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildPresupuestoInfo(String label, double value, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    ),
  );
}
