import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../features/auth/domain/entities/user.dart';

/// Servicio global para manejar el estado de autenticación
class AuthStateService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // Stream para escuchar cambios en el estado de autenticación
  final StreamController<firebase_auth.User?> _authStateController =
      StreamController<firebase_auth.User?>.broadcast();

  /// Stream que emite el usuario actual
  Stream<firebase_auth.User?> get authStateStream =>
      _authStateController.stream;

  /// Usuario actual
  firebase_auth.User? _currentUser;
  firebase_auth.User? get currentUser => _currentUser;

  /// Estado de autenticación
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Inicializa el servicio de autenticación
  Future<void> initialize() async {
    // Escuchar cambios en el estado de autenticación de Firebase
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);

    // Verificar estado inicial
    await _checkAuthState();
  }

  /// Verifica el estado actual de autenticación
  Future<void> _checkAuthState() async {
    final user = _firebaseAuth.currentUser;
    _currentUser = user;
    _isAuthenticated = user != null;
    _authStateController.add(user);
  }

  /// Maneja los cambios en el estado de autenticación
  void _onAuthStateChanged(firebase_auth.User? user) {
    _currentUser = user;
    _isAuthenticated = user != null;
    _authStateController.add(user);
  }

  /// Obtiene el ID del usuario actual
  String? get currentUserId => _currentUser?.uid;

  /// Obtiene el email del usuario actual
  String? get currentUserEmail => _currentUser?.email;

  /// Obtiene el nombre del usuario actual
  String? get currentUserName => _currentUser?.displayName;

  /// Verifica si el usuario está autenticado
  bool isUserAuthenticated() {
    return _isAuthenticated && _currentUser != null;
  }

  /// Verifica si el email del usuario está verificado
  bool isEmailVerified() {
    return _currentUser?.emailVerified ?? false;
  }

  /// Obtiene información del usuario como entidad del dominio
  User? getUserAsEntity() {
    if (_currentUser == null) return null;

    return User(
      id: _currentUser!.uid,
      email: _currentUser!.email ?? '',
      name: _currentUser!.displayName ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: _currentUser!.emailVerified,
    );
  }

  /// Actualiza el estado de autenticación manualmente
  void updateAuthState(firebase_auth.User? user) {
    _currentUser = user;
    _isAuthenticated = user != null;
    _authStateController.add(user);
  }

  /// Limpia el estado de autenticación
  void clearAuthState() {
    _currentUser = null;
    _isAuthenticated = false;
    _authStateController.add(null);
  }

  /// Libera los recursos del servicio
  void dispose() {
    _authStateController.close();
  }
}

/// Estados de autenticación para usar en BLoCs
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

/// Clase para manejar el estado de autenticación en la aplicación
class GlobalAuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final DateTime lastUpdated;

  const GlobalAuthState({
    required this.status,
    this.user,
    this.errorMessage,
    required this.lastUpdated,
  });

  GlobalAuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return GlobalAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && errorMessage != null;
}
