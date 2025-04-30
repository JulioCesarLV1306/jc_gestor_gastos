import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreenListGastos extends StatefulWidget {
  const ScreenListGastos({super.key});

  @override
  State<ScreenListGastos> createState() => _ScreenListGastosState();
}

class _ScreenListGastosState extends State<ScreenListGastos> {

  @override
  Widget build(BuildContext context) {
    final providerHome = Provider.of<ProviderHome>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Gastos'),
      ),
      body: providerHome.gastos.isEmpty
          ? const Center(
            child: Text('No hay gastos registrados'),
          )
          : ListView.builder(
              itemCount: providerHome.gastos.length,
              itemBuilder: (context, index) {
                final gasto =providerHome.gastos[index];
                return Card(
                  color: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(gasto.descripcion,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.backgroundColor,
                            fontSize: 22)),
                    subtitle: Text(
                      'Categoría: ${gasto.categoria}\n'
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '\$${gasto.cantidad.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTextColor,
                            fontSize: 22),
                      ),
                    ),
                    onLongPress: () => providerHome.eliminarGasto(context, index),
                  ),
                );
              },
            ),
    );
  }
}
