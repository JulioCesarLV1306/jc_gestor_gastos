import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CustonDrawer extends StatelessWidget {
  const CustonDrawer({
    super.key,
  });

  // Método para verificar si el usuario es admin
  Future<bool> _isUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'gestofin',
      );

      final userDoc = await db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final accountType = userDoc.data()?['accountType'] ?? 'user';
      return accountType == 'admin';
    } catch (e) {
      print('Error verificando rol de usuario: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 128.0,
                height: 128.0,
                margin: const EdgeInsets.only(top: 24.0, bottom: 64.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/img/logo1.png',
                ),
              ),
              ListTile(
                onTap: () {
                  context.go('/home');
                },
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
              ),
              ListTile(
                onTap: () {
                  // Acción para Perfil
                },
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text('Perfil'),
              ),
              ListTile(
                onTap: () {
                  // Acción para Favoritos
                },
                leading: const Icon(Icons.favorite),
                title: const Text('Favoritos'),
              ),
              ListTile(
                onTap: () {
                  // Acción para Configuración
                },
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
              ),
              
              // Sección ML - Solo para Administradores
              FutureBuilder<bool>(
                future: _isUserAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  
                  if (snapshot.data != true) {
                    return const SizedBox.shrink();
                  }

                  // Usuario es administrador, mostrar opciones ML
                  return Column(
                    children: [
                      const Divider(color: Colors.white24, height: 32),
                      
                      // Título de sección
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16, color: Colors.amber),
                            const SizedBox(width: 8),
                            const Text(
                              'Administrador',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Opciones ML
                      ExpansionTile(
                        leading: const Icon(Icons.psychology),
                        title: const Text('Machine Learning'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.cloud, size: 20),
                            title: const Text('ML con Colab', style: TextStyle(fontSize: 14)),
                            subtitle: const Text(
                              'Predicciones en la nube',
                              style: TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                            onTap: () {
                              context.go('/colab-ml');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.model_training, size: 20),
                            title: const Text('Entrenar Modelo', style: TextStyle(fontSize: 14)),
                            subtitle: const Text(
                              'Análisis y entrenamiento',
                              style: TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                            onTap: () {
                              context.go('/ml-training');
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              
              const Spacer(),
              
              // Botón de cerrar sesión
              ListTile(
                onTap: () async {
                  // Mostrar diálogo de confirmación
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    await FirebaseAuth.instance.signOut();
                    // El router automáticamente redirigirá al login
                  }
                },
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              ),
              
              const SizedBox(height: 8),
              const DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Text('Términos de Servicio | Política de Privacidad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}