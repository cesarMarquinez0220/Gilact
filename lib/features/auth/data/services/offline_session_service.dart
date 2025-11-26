import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../../../core/services/app_logger.dart';

/// Servicio para gestionar sesiones offline de usuarios
class OfflineSessionService {
  final AppLogger _logger;

  OfflineSessionService(this._logger);
  static const String _sessionKey = 'offline_session';
  static const String _sessionTokenKey = 'session_token';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _userDataKey = 'cached_user_data';
  static const Duration _sessionDuration = Duration(days: 30); // Sesión válida por 30 días

  /// Guardar sesión después de login exitoso
  Future<void> saveOfflineSession({
    required User user,
    required String email,
    required String passwordHash, // Hash de la contraseña, NO la contraseña real
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Generar token de sesión único
      final sessionToken = _generateSessionToken(user.id, email);

      // 2. Calcular fecha de expiración
      final expiryDate = DateTime.now().add(_sessionDuration);

      // 3. Guardar datos de sesión
      await prefs.setString(_sessionKey, 'active');
      await prefs.setString(_sessionTokenKey, sessionToken);
      await prefs.setString(_sessionExpiryKey, expiryDate.toIso8601String());

      // 4. Guardar datos del usuario (sin información sensible)
      await prefs.setString(_userDataKey, jsonEncode({
        'id': user.id,
        'email': email,
        'name': user.name,
        'createdAt': user.createdAt.toIso8601String(),
        'isEmailVerified': user.isEmailVerified,
      }));

      // 5. Guardar hash de contraseña para validación local
      await prefs.setString('password_hash_$email', passwordHash);

      _logger.serviceSuccess('OfflineSessionService', 'Sesión offline guardada para usuario: $email');
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'guardar sesión offline', e, stackTrace);
    }
  }

  /// Verificar si hay una sesión válida
  Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Verificar si existe sesión
      final session = prefs.getString(_sessionKey);
      if (session != 'active') return false;

      // 2. Verificar expiración
      final expiryString = prefs.getString(_sessionExpiryKey);
      if (expiryString == null) return false;

      final expiryDate = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiryDate)) {
        // Sesión expirada, limpiar
        await clearSession();
        return false;
      }

      // 3. Verificar que existe token
      final token = prefs.getString(_sessionTokenKey);
      if (token == null || token.isEmpty) return false;

      return true;
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'verificar sesión', e, stackTrace);
      return false;
    }
  }

  /// Obtener usuario de sesión offline
  Future<User?> getOfflineUser() async {
    try {
      if (!await hasValidSession()) return null;

      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);

      if (userDataJson == null) return null;

      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;

      return User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        createdAt: DateTime.parse(userData['createdAt'] as String),
        updatedAt: DateTime.now(),
        isEmailVerified: userData['isEmailVerified'] as bool? ?? false,
      );
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'obtener usuario offline', e, stackTrace);
      return null;
    }
  }

  /// Validar credenciales localmente (sin internet)
  Future<bool> validateCredentialsOffline({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Obtener hash guardado
      final storedHash = prefs.getString('password_hash_$email');
      if (storedHash == null) return false;

      // 2. Calcular hash de la contraseña ingresada
      final inputHash = _hashPassword(password);

      // 3. Comparar hashes
      return storedHash == inputHash;
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'validar credenciales offline', e, stackTrace);
      return false;
    }
  }

  /// Limpiar sesión
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_sessionTokenKey);
      await prefs.remove(_sessionExpiryKey);
      await prefs.remove(_userDataKey);

      // No eliminar password_hash para permitir login offline
      _logger.serviceSuccess('OfflineSessionService', 'Sesión offline limpiada');
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'limpiar sesión', e, stackTrace);
    }
  }

  /// Generar token de sesión
  String _generateSessionToken(String userId, String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$userId-$email-$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Hash de contraseña (SHA-256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Extender sesión (cuando hay conexión)
  Future<void> extendSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newExpiry = DateTime.now().add(_sessionDuration);
      await prefs.setString(_sessionExpiryKey, newExpiry.toIso8601String());
      _logger.d('Sesión extendida hasta ${newExpiry.toIso8601String()}');
    } catch (e, stackTrace) {
      _logger.serviceError('OfflineSessionService', 'extender sesión', e, stackTrace);
    }
  }

  /// Obtener hash de contraseña (método público para uso en AuthBloc)
  String hashPassword(String password) {
    return _hashPassword(password);
  }
}

