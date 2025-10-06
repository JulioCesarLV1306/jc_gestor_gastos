import 'package:flutter/material.dart';

class CustonDrawer extends StatelessWidget {
  const CustonDrawer({
    super.key,
  });

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
                  'assets/img/logo1.png', // Cambia por tu logo
                ),
              ),
              ListTile(
                onTap: () {
                  // Acción para Home
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
              const Spacer(),
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