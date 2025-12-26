# 🔐 Script: Configurar Primer Administrador

## Método Rápido desde Firebase Console

### Paso 1: Acceder a Firebase Console
```
1. Abre: https://console.firebase.google.com/
2. Selecciona tu proyecto: gestor-financiero-28ac2
3. Ve a: Firestore Database
4. Selecciona base de datos: gestofin
```

### Paso 2: Encontrar tu Usuario
```
1. Navega a la colección: users
2. Busca tu usuario por email
3. Haz clic en el documento
```

### Paso 3: Agregar Campo accountType
```
1. Haz clic en "Agregar campo" o editar
2. Nombre del campo: accountType
3. Tipo: string
4. Valor: admin
5. Guarda
```

### Paso 4: Verificar
```
1. Reinicia tu app Flutter completamente
2. Abre el drawer
3. Deberías ver: "Administrador" con opciones ML
```

---

## Método Alternativo: Código Flutter

Si prefieres hacerlo desde código, crea un botón temporal:

### 1. Agrega este código en tu screen_home.dart (temporal)

```dart
import 'package:gestor_de_gastos_jc/config/services/user_role_service.dart';

// En el body de ScreenHome, agrega:
FloatingActionButton(
  onPressed: () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await UserRoleService().setAdminRole(user.uid);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Configurado como administrador'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reiniciar app
      print('🔄 Reinicia la app para aplicar cambios');
    }
  },
  child: Icon(Icons.admin_panel_settings),
  tooltip: 'Hacerme Admin (Solo desarrollo)',
)
```

### 2. Ejecuta la App

```bash
flutter run
```

### 3. Presiona el Botón

El botón configurará tu cuenta actual como administrador.

### 4. Reinicia la App

Usa Hot Restart (R) o reinicia completamente.

### 5. Elimina el Botón

Una vez configurado, elimina el botón temporal.

---

## Verificación Rápida

### Comprobar en Firebase Console

```
1. Firebase Console → Firestore → gestofin → users
2. Tu usuario debería tener:
   {
     "email": "tu@email.com",
     "username": "tu_nombre",
     "accountType": "admin"  ⬅️ Debe estar presente
   }
```

### Comprobar en la App

```dart
// Agrega este código temporal en cualquier parte
Future<void> checkMyRole() async {
  final role = await UserRoleService().getCurrentUserRole();
  print('🔍 Mi rol actual: $role');
  
  final isAdmin = await UserRoleService().isAdmin();
  print('🔍 ¿Soy admin?: $isAdmin');
}
```

---

## Configurar Múltiples Admins

### Desde Firebase Console

Para cada usuario que quieras hacer admin:

```
1. Ve a: Firestore → gestofin → users
2. Encuentra el usuario
3. Edita o agrega: accountType = "admin"
4. Guarda
5. El usuario debe reiniciar la app
```

### Desde Código (Panel de Admin)

```dart
// En un futuro AdminPanel
Future<void> promoteToAdmin(String userId) async {
  final success = await UserRoleService().updateUserRole(
    userId: userId,
    newRole: UserRoleService.ADMIN,
  );
  
  if (success) {
    print('✅ Usuario promovido a admin');
  }
}
```

---

## 🚨 Importante: Solo para Desarrollo

El botón temporal de "Hacerme Admin" **DEBE SER ELIMINADO** en producción.

En producción, los administradores deben configurarse:
1. Manualmente desde Firebase Console
2. O mediante un panel de administración protegido

---

## Ejemplo Completo: Botón Debug

```dart
// lib/modules/home/screen_home.dart

class ScreenHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contenido normal de la app'),
            
            // ⚠️ SOLO PARA DEBUG - ELIMINAR EN PRODUCCIÓN
            if (kDebugMode) ...[
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await UserRoleService().setAdminRole(user.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Admin configurado. Reinicia la app')),
                    );
                  }
                },
                icon: Icon(Icons.admin_panel_settings),
                label: Text('DEBUG: Hacerme Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
              Text(
                'Este botón solo aparece en modo debug',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Estado Actual

```
✅ UserModel actualizado con accountType
✅ Drawer muestra ML solo a admins
✅ UserRoleService creado
✅ Verificación de roles implementada
⏳ PENDIENTE: Configurar primer administrador
```

---

## Próximos Pasos

1. ✅ Configurar tu cuenta como admin (Firebase Console o botón debug)
2. ✅ Reiniciar la app
3. ✅ Verificar que ves opciones ML en el drawer
4. ✅ Probar acceso a /colab-ml
5. ✅ Eliminar botón debug si lo usaste

---

**¡Listo para configurar tu primer administrador!** 🚀
