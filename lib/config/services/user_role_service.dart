import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Servicio para gestionar roles y permisos de usuarios
class UserRoleService {
  static final UserRoleService _instance = UserRoleService._internal();
  factory UserRoleService() => _instance;
  UserRoleService._internal();

  // Tipos de cuenta disponibles
  static const String ADMIN = 'admin';
  static const String USER = 'user';

  /// Obtener el rol del usuario actual
  Future<String> getCurrentUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return USER;

      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'gestofin',
      );

      final userDoc = await db.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        print('⚠️ Usuario no encontrado en Firestore, rol por defecto: user');
        return USER;
      }

      final accountType = userDoc.data()?['accountType'] ?? USER;
      print('✅ Rol del usuario ${user.email}: $accountType');
      
      return accountType;
    } catch (e) {
      print('❌ Error obteniendo rol del usuario: $e');
      return USER;
    }
  }

  /// Verificar si el usuario actual es administrador
  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == ADMIN;
  }

  /// Verificar si el usuario actual es usuario regular
  Future<bool> isUser() async {
    final role = await getCurrentUserRole();
    return role == USER;
  }

  /// Actualizar el rol de un usuario (solo administradores)
  Future<bool> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      // Verificar que el usuario actual es admin
      final isCurrentUserAdmin = await isAdmin();
      if (!isCurrentUserAdmin) {
        print('❌ Solo administradores pueden cambiar roles');
        return false;
      }

      // Validar el nuevo rol
      if (newRole != ADMIN && newRole != USER) {
        print('❌ Rol inválido: $newRole');
        return false;
      }

      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'gestofin',
      );

      await db.collection('users').doc(userId).update({
        'accountType': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Rol actualizado para usuario $userId: $newRole');
      return true;
    } catch (e) {
      print('❌ Error actualizando rol: $e');
      return false;
    }
  }

  /// Establecer rol de admin al registrar usuario (usar con precaución)
  Future<void> setAdminRole(String userId) async {
    try {
      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'gestofin',
      );

      await db.collection('users').doc(userId).update({
        'accountType': ADMIN,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Usuario $userId configurado como administrador');
    } catch (e) {
      print('❌ Error configurando admin: $e');
    }
  }

  /// Listar todos los administradores
  Future<List<Map<String, dynamic>>> listAdmins() async {
    try {
      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'gestofin',
      );

      final querySnapshot = await db
          .collection('users')
          .where('accountType', isEqualTo: ADMIN)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'email': doc.data()['email'],
                'username': doc.data()['username'],
                'accountType': doc.data()['accountType'],
              })
          .toList();
    } catch (e) {
      print('❌ Error listando administradores: $e');
      return [];
    }
  }

  /// Verificar permisos para acceder a funciones ML
  Future<bool> canAccessML() async {
    return await isAdmin();
  }

  /// Verificar permisos para gestionar usuarios
  Future<bool> canManageUsers() async {
    return await isAdmin();
  }

  /// Verificar permisos para ver estadísticas globales
  Future<bool> canViewGlobalStats() async {
    return await isAdmin();
  }
}
