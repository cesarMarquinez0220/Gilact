import 'package:shared_preferences/shared_preferences.dart';

class CredentialsCacheService {
  static const String _emailKey = 'cached_email';
  static const String _saveCredentialsKey = 'save_credentials';
  static const String _lastLoginKey = 'last_login';

  // Cargar credenciales desde caché
  static Future<String> loadCredentialsFromCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey) ?? '';
    } catch (e) {
      print('Error cargando credenciales: $e');
      return '';
    }
  }

  // Guardar credenciales en caché
  static Future<void> saveCredentialsInCache(
    String email,
    bool saveCredentials,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (saveCredentials) {
        await prefs.setString(_emailKey, email);
        await prefs.setBool(_saveCredentialsKey, true);
      } else {
        await prefs.remove(_emailKey);
        await prefs.setBool(_saveCredentialsKey, false);
      }
    } catch (e) {
      print('Error guardando credenciales: $e');
    }
  }

  // Verificar si se deben guardar credenciales
  static Future<bool> shouldSaveCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_saveCredentialsKey) ?? false;
    } catch (e) {
      print('Error verificando preferencia de guardar credenciales: $e');
      return false;
    }
  }

  // Limpiar credenciales del caché
  static Future<void> clearCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_saveCredentialsKey);
    } catch (e) {
      print('Error limpiando credenciales: $e');
    }
  }

  // Guardar última vez de login
  static Future<void> saveLastLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error guardando última vez de login: $e');
    }
  }

  // Obtener última vez de login
  static Future<DateTime?> getLastLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastLoginString = prefs.getString(_lastLoginKey);
      if (lastLoginString != null) {
        return DateTime.tryParse(lastLoginString);
      }
      return null;
    } catch (e) {
      print('Error obteniendo última vez de login: $e');
      return null;
    }
  }

  // Verificar si es la primera vez que se abre la app
  static Future<bool> isFirstTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLoginKey) == null;
    } catch (e) {
      print('Error verificando primera vez: $e');
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
    } catch (e) {
      print('Error guardando preferencias de usuario: $e');
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
    } catch (e) {
      print('Error cargando preferencias de usuario: $e');
      return {
        'rememberCredentials': false,
        'biometricLogin': false,
        'language': 'es',
      };
    }
  }
}
