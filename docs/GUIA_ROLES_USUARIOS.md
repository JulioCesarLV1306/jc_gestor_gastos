# 🔐 Sistema de Roles y Permisos

## 📋 Descripción

Se ha implementado un sistema de roles para controlar el acceso a funcionalidades avanzadas como Machine Learning. Solo los usuarios con rol de **administrador** pueden acceder a estas funciones.

---

## 🎯 Tipos de Cuenta

### 1. Usuario Regular (`user`)
- ✅ Acceso completo a funciones básicas
- ✅ Registro de gastos
- ✅ Visualización de estadísticas personales
- ✅ Configuración de presupuesto
- ❌ NO puede acceder a ML
- ❌ NO puede ver estadísticas globales

### 2. Administrador (`admin`)
- ✅ Todas las funciones de usuario regular
- ✅ Acceso a Machine Learning con Colab
- ✅ Entrenamiento de modelos ML
- ✅ Visualización de estadísticas globales
- ✅ Gestión de roles de otros usuarios

---

## 🔧 Implementación

### Modelo de Usuario Actualizado

```dart
// lib/core/models/user_model.dart

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String accountType; // 'admin' o 'user'

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.accountType = 'user', // Por defecto es 'user'
  });

  // Métodos helper
  bool get isAdmin => accountType == 'admin';
  bool get isUser => accountType == 'user';
}
```

### Drawer Actualizado

El drawer ahora verifica el rol del usuario y solo muestra las opciones ML si es administrador:

```dart
// lib/widgets/custon_drawer.dart

// Verifica rol en Firestore
Future<bool> _isUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  final userDoc = await db.collection('users').doc(user.uid).get();
  final accountType = userDoc.data()?['accountType'] ?? 'user';
  
  return accountType == 'admin';
}
```

---

## 🚀 Uso del Servicio de Roles

### Importar el Servicio

```dart
import 'package:gestor_de_gastos_jc/config/services/user_role_service.dart';
```

### Verificar si es Admin

```dart
final roleService = UserRoleService();

// Método 1: Verificar directamente
final isAdmin = await roleService.isAdmin();
if (isAdmin) {
  // Mostrar opciones de admin
}

// Método 2: Obtener rol
final role = await roleService.getCurrentUserRole();
if (role == UserRoleService.ADMIN) {
  // Es administrador
}
```

### Ejemplo en Widget

```dart
class MyAdminFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserRoleService().isAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data != true) {
          return Text('No tienes permisos');
        }
        
        return AdminPanel(); // Mostrar panel de admin
      },
    );
  }
}
```

---

## 🔑 Configurar Primer Administrador

### Opción 1: Desde Firebase Console (Recomendado)

1. Abre **Firebase Console**
2. Ve a **Firestore Database**
3. Selecciona la base de datos: `gestofin`
4. Navega a la colección `users`
5. Encuentra tu usuario
6. Edita el documento y agrega/modifica:
   ```json
   {
     "accountType": "admin"
   }
   ```
7. Guarda los cambios
8. Reinicia la app

### Opción 2: Desde Código (Solo para desarrollo)

```dart
import 'package:gestor_de_gastos_jc/config/services/user_role_service.dart';

// En alguna parte temporal de tu código (ej: botón de debug)
Future<void> makeCurrentUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await UserRoleService().setAdminRole(user.uid);
    print('✅ Usuario configurado como admin');
  }
}
```

### Opción 3: Durante el Registro

Modifica el servicio de registro para permitir crear admins:

```dart
// En auth_service.dart o register_page.dart

Future<void> registerAdmin({
  required String email,
  required String password,
  required String username,
}) async {
  // Crear usuario en Firebase Auth
  final userCredential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);

  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  // Guardar en Firestore con rol admin
  await db.collection('users').doc(userCredential.user!.uid).set({
    'email': email,
    'username': username,
    'accountType': 'admin', // ⬅️ Configurar como admin
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

---

## 🛡️ Proteger Rutas

Puedes proteger rutas específicas para que solo admins accedan:

```dart
// En routers.dart

GoRoute(
  path: '/colab-ml',
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/login';
    
    // Verificar si es admin
    final isAdmin = await UserRoleService().isAdmin();
    if (!isAdmin) {
      // Redirigir a home si no es admin
      return '/home';
    }
    
    return null; // Permitir acceso
  },
  builder: (context, state) => const ColabMLPage(),
),
```

---

## 📊 Gestión de Roles

### Listar Administradores

```dart
final roleService = UserRoleService();
final admins = await roleService.listAdmins();

for (var admin in admins) {
  print('Admin: ${admin['email']}');
}
```

### Cambiar Rol de Usuario

```dart
final roleService = UserRoleService();

// Promover usuario a admin
final success = await roleService.updateUserRole(
  userId: 'user_id_here',
  newRole: UserRoleService.ADMIN,
);

// Degradar admin a user
final success2 = await roleService.updateUserRole(
  userId: 'admin_id_here',
  newRole: UserRoleService.USER,
);
```

---

## 🎨 UI para Gestión de Roles

### Panel de Administración

```dart
class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _roleService = UserRoleService();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'gestofin',
    );

    final snapshot = await db.collection('users').get();
    setState(() {
      _users = snapshot.docs.map((doc) => {
        'id': doc.id,
        'email': doc.data()['email'],
        'accountType': doc.data()['accountType'] ?? 'user',
      }).toList();
    });
  }

  Future<void> _toggleRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    
    final success = await _roleService.updateUserRole(
      userId: userId,
      newRole: newRole,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado a: $newRole')),
      );
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Usuarios')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isAdmin = user['accountType'] == 'admin';

          return ListTile(
            leading: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: isAdmin ? Colors.amber : Colors.grey,
            ),
            title: Text(user['email']),
            subtitle: Text(
              isAdmin ? 'Administrador' : 'Usuario',
              style: TextStyle(
                color: isAdmin ? Colors.amber : Colors.grey,
              ),
            ),
            trailing: Switch(
              value: isAdmin,
              onChanged: (value) {
                _toggleRole(user['id'], user['accountType']);
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🔐 Seguridad en Firestore

Actualiza las reglas de Firestore para proteger el campo `accountType`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/gestofin/documents {
    
    // Colección de usuarios
    match /users/{userId} {
      // Leer: solo el propio usuario
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Escribir: solo el propio usuario, pero NO puede cambiar accountType
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['accountType']);
      
      // Admins pueden cambiar accountType
      allow update: if request.auth != null 
        && get(/databases/gestofin/documents/users/$(request.auth.uid)).data.accountType == 'admin';
      
      // Crear usuario
      allow create: if request.auth != null;
    }
    
    // Colección ML - Solo admins
    match /ml_models/{modelId} {
      allow read, write: if request.auth != null 
        && get(/databases/gestofin/documents/users/$(request.auth.uid)).data.accountType == 'admin';
    }
  }
}
```

---

## ✅ Verificación del Sistema

### Checklist de Implementación

- ✅ UserModel actualizado con campo `accountType`
- ✅ Archivo `user_model.g.dart` regenerado
- ✅ Drawer muestra opciones ML solo a admins
- ✅ Servicio `UserRoleService` creado
- ✅ Verificación de roles implementada

### Cómo Probar

1. **Crear usuario regular:**
   - Registra un nuevo usuario
   - Por defecto será `user`
   - Verifica que NO vea opciones ML en el drawer

2. **Promover a admin:**
   - Ve a Firebase Console
   - Edita el usuario en Firestore
   - Cambia `accountType` a `admin`
   - Reinicia la app

3. **Verificar acceso:**
   - Abre el drawer
   - Deberías ver la sección "Administrador"
   - Con opciones: "ML con Colab" y "Entrenar Modelo"

4. **Probar navegación:**
   - Haz clic en "ML con Colab"
   - Deberías acceder a la página sin problemas

---

## 🐛 Solución de Problemas

### "No veo las opciones ML aunque soy admin"

**Verificar:**
1. ¿El campo `accountType` existe en Firestore?
2. ¿El valor es exactamente `"admin"`? (minúsculas)
3. ¿Reiniciaste la app después de cambiar el rol?

**Solución:**
```dart
// Agregar logs temporales en custon_drawer.dart
Future<bool> _isUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  print('🔍 User ID: ${user?.uid}');
  
  final userDoc = await db.collection('users').doc(user.uid).get();
  print('🔍 User doc exists: ${userDoc.exists}');
  print('🔍 Account type: ${userDoc.data()?['accountType']}');
  
  return userDoc.data()?['accountType'] == 'admin';
}
```

### "Error: user_model.g.dart no se regenera"

**Solución:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Los cambios en Firestore no se reflejan"

**Causa:** Caché de Firestore

**Solución:**
1. Reinicia completamente la app (hot restart no es suficiente)
2. O usa hot restart + clear app data

---

## 📚 Recursos

### Archivos Relacionados
- `lib/core/models/user_model.dart` - Modelo con roles
- `lib/widgets/custon_drawer.dart` - Drawer con verificación
- `lib/config/services/user_role_service.dart` - Servicio de roles
- `lib/routes/routers.dart` - Protección de rutas

### Referencias
- [Firebase Auth Roles](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Última actualización:** Diciembre 26, 2024  
**Versión:** 1.0.0
