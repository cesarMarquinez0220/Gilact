import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Datasource local para configuraciones usando SharedPreferences
@injectable
class SettingsLocalDataSource {
  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  // Claves para almacenar configuración
  static const String _keySoundEnabled = 'soundEnabled';
  static const String _keyVibrationEnabled = 'vibrationEnabled';
  static const String _keyAutoSaveProgress = 'autoSaveProgress';
  static const String _keyLanguage = 'language';
  static const String _keyAppVersion = 'app_version';
  static const String _keyBiometricEnabled = 'biometric_login_enabled';

  /// Obtiene el estado del sonido
  Future<bool> getSoundEnabled() async {
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  /// Guarda el estado del sonido
  Future<bool> setSoundEnabled(bool value) async {
    return await _prefs.setBool(_keySoundEnabled, value);
  }

  /// Obtiene el estado de la vibración
  Future<bool> getVibrationEnabled() async {
    return _prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  /// Guarda el estado de la vibración
  Future<bool> setVibrationEnabled(bool value) async {
    return await _prefs.setBool(_keyVibrationEnabled, value);
  }

  /// Obtiene el estado del guardado automático
  Future<bool> getAutoSaveProgress() async {
    return _prefs.getBool(_keyAutoSaveProgress) ?? true;
  }

  /// Guarda el estado del guardado automático
  Future<bool> setAutoSaveProgress(bool value) async {
    return await _prefs.setBool(_keyAutoSaveProgress, value);
  }

  /// Obtiene el idioma
  Future<String> getLanguage() async {
    return _prefs.getString(_keyLanguage) ?? 'es';
  }

  /// Guarda el idioma
  Future<bool> setLanguage(String language) async {
    return await _prefs.setString(_keyLanguage, language);
  }

  /// Obtiene la versión de la app
  Future<String> getAppVersion() async {
    return _prefs.getString(_keyAppVersion) ?? '1.0.0';
  }

  /// Guarda la versión de la app
  Future<bool> setAppVersion(String version) async {
    return await _prefs.setString(_keyAppVersion, version);
  }

  /// Obtiene el estado de la autenticación biométrica
  Future<bool> getBiometricEnabled() async {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Guarda el estado de la autenticación biométrica
  Future<bool> setBiometricEnabled(bool value) async {
    return await _prefs.setBool(_keyBiometricEnabled, value);
  }

  /// Obtiene todas las configuraciones locales
  Future<Map<String, dynamic>> getAllLocalSettings() async {
    return {
      'soundEnabled': await getSoundEnabled(),
      'vibrationEnabled': await getVibrationEnabled(),
      'autoSaveProgress': await getAutoSaveProgress(),
      'language': await getLanguage(),
      'appVersion': await getAppVersion(),
      'biometricEnabled': await getBiometricEnabled(),
    };
  }
}

