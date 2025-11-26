import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/services/offline_session_service.dart';
import '../../features/auth/domain/services/credentials_cache_service.dart';
import 'app_logger.dart';

/// Servicio para manejar autenticación biométrica (huella dactilar/Face ID)
class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final AppLogger _logger = GetIt.instance<AppLogger>();
  final OfflineSessionService _offlineSessionService =
      GetIt.instance<OfflineSessionService>();

  /// Verifica si el dispositivo soporta autenticación biométrica
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      _logger.d(
        'BiometricAuthService: isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported',
      );

      return isAvailable && isDeviceSupported;
    } catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error verificando disponibilidad',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Obtiene los tipos de autenticación biométrica disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error obteniendo tipos biométricos',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Obtiene el nombre del tipo de autenticación biométrica
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Touch ID';
      case BiometricType.strong:
        return 'Autenticación fuerte';
      case BiometricType.weak:
        return 'Autenticación débil';
      case BiometricType.iris:
        return 'Iris';
    }
  }

  /// Obtiene el mensaje para mostrar al usuario según el tipo de biometría
  String getBiometricMessage(List<BiometricType> availableTypes) {
    if (availableTypes.contains(BiometricType.face)) {
      return 'Usa Face ID para iniciar sesión';
    } else if (availableTypes.contains(BiometricType.fingerprint)) {
      return 'Usa tu huella dactilar para iniciar sesión';
    } else if (availableTypes.contains(BiometricType.strong)) {
      return 'Usa autenticación biométrica para iniciar sesión';
    }
    return 'Usa autenticación biométrica para iniciar sesión';
  }

  /// Verifica si el usuario tiene habilitada la autenticación biométrica
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('biometric_login_enabled') ?? false;
    } catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error verificando si está habilitada',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Habilita o deshabilita la autenticación biométrica
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_login_enabled', enabled);
      _logger.success(
        'BiometricAuthService: Autenticación biométrica ${enabled ? "habilitada" : "deshabilitada"}',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error guardando preferencia',
        e,
        stackTrace,
      );
    }
  }

  /// Autentica usando biométrica y retorna las credenciales guardadas
  Future<Map<String, String>?> authenticateWithBiometrics() async {
    try {
      // 1. Verificar si está disponible
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.w(
          'BiometricAuthService: Autenticación biométrica no disponible',
        );
        return null;
      }

      // 2. Verificar si está habilitada (si no lo está, la habilitamos automáticamente)
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        _logger.d(
          'BiometricAuthService: Autenticación biométrica no habilitada, habilitándola automáticamente',
        );
        await setBiometricEnabled(true);
      }

      // 3. Obtener tipos disponibles para el mensaje
      final availableTypes = await getAvailableBiometrics();
      final message = getBiometricMessage(availableTypes);

      // 4. Autenticar con biométrica
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        _logger.w(
          'BiometricAuthService: Autenticación biométrica fallida o cancelada',
        );
        return null;
      }

      // 5. Obtener credenciales guardadas
      final email = await CredentialsCacheService.loadCredentialsFromCache();
      if (email.isEmpty) {
        _logger.w('BiometricAuthService: No hay email guardado en caché');
        return null;
      }

      // 6. Verificar que hay una sesión válida
      final hasSession = await _offlineSessionService.hasValidSession();
      if (!hasSession) {
        _logger.w('BiometricAuthService: No hay sesión válida');
        return null;
      }

      // 7. Obtener usuario de sesión
      final user = await _offlineSessionService.getOfflineUser();
      if (user == null) {
        _logger.w('BiometricAuthService: No se pudo obtener usuario de sesión');
        return null;
      }

      _logger.success(
        'BiometricAuthService: Autenticación biométrica exitosa para: $email',
      );

      return {'email': email, 'userId': user.id};
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error de plataforma: ${e.code} - ${e.message}',
        e,
        stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      _logger.e('BiometricAuthService: Error autenticando', e, stackTrace);
      return null;
    }
  }

  /// Verifica si hay credenciales guardadas para usar con biométrica
  Future<bool> hasStoredCredentials() async {
    try {
      final email = await CredentialsCacheService.loadCredentialsFromCache();
      if (email.isEmpty) return false;

      final hasSession = await _offlineSessionService.hasValidSession();
      return hasSession;
    } catch (e, stackTrace) {
      _logger.e(
        'BiometricAuthService: Error verificando credenciales guardadas',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
