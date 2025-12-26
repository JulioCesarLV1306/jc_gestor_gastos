import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_de_gastos_jc/modules/auth/auth_provider.dart';
import 'package:gestor_de_gastos_jc/widgets/notification_helper.dart';

/// Página de configuración con notificaciones
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Información del usuario
          if (authProvider.isAuthenticated)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        authProvider.user!.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.user!.displayName ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      authProvider.user!.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Configuración de notificaciones
          if (authProvider.isAuthenticated)
            NotificationSettingsWidget(
              userId: authProvider.user!.uid,
            ),
          
          // Otras opciones
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Cambiar Contraseña'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navegar a cambio de contraseña
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Ayuda y Soporte'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navegar a ayuda
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Acerca de'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Gestor de Gastos',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Cerrar sesión
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
