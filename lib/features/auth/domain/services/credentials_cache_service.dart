import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/app_logger.dart';

class CredentialsCacheService {
  static AppLogger get _logger => GetIt.instance<AppLogger>();
  static const String _emailKey = 'cached_email';
  static const String _saveCredentialsKey = 'save_credentials';
  static const String _lastLoginKey = 'last_login';

  // Cargar credenciales desde caché
  static Future<String> loadCredentialsFromCache() async {
    try {
      _logger.d(
        'CredentialsCacheService: Cargando credenciales desde caché...',
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_emailKey) ?? '';
      final saveCredentials = prefs.getBool(_saveCredentialsKey) ?? false;

      _logger.d('CredentialsCacheService: Email desde caché: "$email"');
      _logger.d('CredentialsCacheService: save_credentials: $saveCredentials');

      if (email.isEmpty) {
        _logger.w('CredentialsCacheService: Email vacío en caché');
      } else {
        _logger.success(
          'CredentialsCacheService: Email encontrado en caché: "$email"',
        );
      }

      return email;
    } catch (e, stackTrace) {
      _logger.e(
        'CredentialsCacheService: Error cargando credenciales',
        e,
        stackTrace,
      );
      return '';
    }
  }

  // Guardar credenciales en caché
  static Future<void> saveCredentialsInCache(
    String email,
    bool saveCredentials,
  ) async {
    try {
      _logger.d('CredentialsCacheService: Guardando credenciales en caché...');
      _logger.d('CredentialsCacheService: Email a guardar: "$email"');
      _logger.d('CredentialsCacheService: saveCredentials: $saveCredentials');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (saveCredentials) {
        await prefs.setString(_emailKey, email);
        await prefs.setBool(_saveCredentialsKey, true);
        _logger.success(
          'CredentialsCacheService: Credenciales guardadas exitosamente',
        );
      } else {
        await prefs.remove(_emailKey);
        await prefs.setBool(_saveCredentialsKey, false);
        _logger.d('CredentialsCacheService: Credenciales removidas del caché');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'CredentialsCacheService: Error guardando credenciales',
        e,
        stackTrace,
      );
    }
  }

  // Verificar si se deben guardar credenciales
  static Future<bool> shouldSaveCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_saveCredentialsKey) ?? false;
    } catch (e, stackTrace) {
      _logger.e(
        'Error verificando preferencia de guardar credenciales',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Limpiar credenciales del caché
  static Future<void> clearCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_saveCredentialsKey);
    } catch (e, stackTrace) {
      _logger.e('Error limpiando credenciales', e, stackTrace);
    }
  }

  // Guardar última vez de login
  static Future<void> saveLastLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e, stackTrace) {
      _logger.e('Error guardando última vez de login', e, stackTrace);
    }
  }

  // Obtener última vez de login
  static Future<DateTime?> getLastLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastLoginString = prefs.getString(_lastLoginKey);
      if (lastLoginString == null) return null;
      return DateTime.tryParse(lastLoginString);
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo última vez de login', e, stackTrace);
      return null;
    }
  }

  // Verificar si es la primera vez que se abre la app
  static Future<bool> isFirstTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLoginKey) == null;
    } catch (e, stackTrace) {
      _logger.e('Error verificando primera vez', e, stackTrace);
      return true;
    }
  }

  // Guardar preferencias de usuario
  static Future<void> saveUserPreferences({
    required bool rememberCredentials,
    required bool biometricLogin,
    required String language,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_saveCredentialsKey, rememberCredentials);
      await prefs.setBool('biometric_login', biometricLogin);
      await prefs.setString('language', language);
    } catch (e, stackTrace) {
      _logger.e('Error guardando preferencias de usuario', e, stackTrace);
    }
  }

  // Cargar preferencias de usuario
  static Future<Map<String, dynamic>> loadUserPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return {
        'rememberCredentials': prefs.getBool(_saveCredentialsKey) ?? false,
        'biometricLogin': prefs.getBool('biometric_login') ?? false,
        'language': prefs.getString('language') ?? 'es',
      };
    } catch (e, stackTrace) {
      _logger.e('Error cargando preferencias de usuario', e, stackTrace);
      return {
        'rememberCredentials': false,
        'biometricLogin': false,
        'language': 'es',
      };
    }
  }
}
