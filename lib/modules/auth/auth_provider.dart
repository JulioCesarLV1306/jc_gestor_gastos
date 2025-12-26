import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Obtener el usuario actual al inicializar
    _user = _authService.currentUser;

    if (_user != null) {
      print('🔐 AuthProvider inicializado con usuario: ${_user!.email}');
    } else {
      print('🔐 AuthProvider inicializado sin usuario autenticado');
    }

    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        print('🔄 Estado de auth cambió - Usuario: ${user.email}');
      } else {
        print('🔄 Estado de auth cambió - Usuario cerró sesión');
      }
      notifyListeners();
    });
  }

  /// Registrar nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      _user = user;
      _isLoading = false;
      notifyListeners();

      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 AuthProvider.signIn: Iniciando login...');

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      print('🔐 AuthProvider.signIn: Usuario obtenido - ${user?.email}');

      _user = user;
      _isLoading = false;
      notifyListeners();

      print(
          '🔐 AuthProvider.signIn: Estado actualizado - isAuthenticated: ${_user != null}');

      return user != null;
    } catch (e) {
      print('❌ AuthProvider.signIn: Error - $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar perfil
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Recargar usuario
      await _authService.currentUser?.reload();
      _user = _authService.currentUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
