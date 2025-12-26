import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_gastos_jc/core/models/user_profile_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Usar la base de datos 'gestofin' en lugar de la predeterminada
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  // Stream del estado del usuario
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrar nuevo usuario
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('🔐 Iniciando registro para: $email');

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Usuario creado en Firebase Auth: ${credential.user?.uid}');

      User? user = credential.user;

      if (user != null) {
        // Actualizar el displayName si se proporcionó
        if (displayName != null) {
          await user.updateDisplayName(displayName);
          await user.reload();
          user = _auth.currentUser!; // Refrescar usuario después de actualizar
          print('✅ DisplayName actualizado: $displayName');
        }

        // Guardar usuario en Firestore
        print('💾 Guardando perfil en Firestore para UID: ${user.uid}');
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': displayName ?? user.displayName,
          'photoUrl': user.photoURL,
          'accountType': 'user', // Por defecto todos los usuarios son tipo 'user'
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': null,
        }, SetOptions(merge: false)); // merge: false asegura que se cree nuevo documento
        print('✅ Perfil guardado en Firestore con accountType: user');

        // Enviar email de verificación
        try {
          await user.sendEmailVerification();
          print('✅ Email de verificación enviado exitosamente a: ${user.email}');
        } on FirebaseAuthException catch (emailError) {
          print('⚠️ Error al enviar email de verificación: ${emailError.code} - ${emailError.message}');
          // No lanzamos el error para permitir que el registro continúe
          // El usuario puede reenviar el email más tarde
        }
      } else {
        throw Exception('No se pudo crear el usuario en Firebase Auth');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Error de Firebase Auth: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error general en registro: $e');
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Iniciar sesión con email
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si el email está verificado
      if (credential.user != null && !credential.user!.emailVerified) {
        print('⚠️ Email no verificado para: ${credential.user!.email}');
        // Permitir login pero mostrar advertencia en la UI
      } else {
        print('✅ Email verificado para: ${credential.user!.email}');
      }

      // Actualizar última fecha de login (sin esperar para no bloquear)
      if (credential.user != null) {
        _updateLastLogin(credential.user!.uid).then((_) {
          print('✅ LastLogin actualizado correctamente');
        }).catchError((e) {
          print('⚠️ No se pudo actualizar lastLogin: $e');
        });
      }

      print('🔐 Retornando usuario después de signIn');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  // Reenviar email de verificación
  Future<void> resendVerificationEmail() async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      if (user.emailVerified) {
        throw Exception('El email ya está verificado');
      }

      print('📧 Reenviando email de verificación a: ${user.email}');
      await user.sendEmailVerification();
      print('✅ Email de verificación reenviado exitosamente');
    } on FirebaseAuthException catch (e) {
      print('❌ Error Firebase al reenviar email: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error al reenviar email de verificación: $e');
      throw Exception('Error al reenviar email de verificación: $e');
    }
  }

  // Verificar si el email del usuario actual está verificado
  Future<bool> isEmailVerified() async {
    User? user = currentUser;
    if (user == null) return false;

    // Recargar el usuario para obtener el estado más reciente
    await user.reload();
    user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  // Actualizar perfil del usuario
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Actualizar en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Obtener perfil del usuario
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // Actualizar última fecha de login
  Future<void> _updateLastLogin(String uid) async {
    try {
      print('💾 Actualizando lastLogin para UID: $uid');
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Timeout al actualizar lastLogin');
          throw Exception('Timeout actualizando lastLogin');
        },
      );
      print('✅ LastLogin actualizado exitosamente');
    } catch (e) {
      print('⚠️ Error al actualizar lastLogin: $e');
      rethrow;
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Eliminar datos del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Eliminar cuenta de Firebase Auth
      await user.delete();
    } catch (e) {
      throw Exception('Error al eliminar cuenta: $e');
    }
  }
}
