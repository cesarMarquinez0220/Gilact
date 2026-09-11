import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Servicio global para manejar la configuración de la aplicación
@singleton
class AppConfigService {
  final SharedPreferences _prefs;
  
  AppConfigService(this._prefs);
  
  // Claves para almacenar configuración
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLastOpened = 'last_opened';
  static const String _keyUserPreferences = 'user_preferences';
  static const String _keyAppVersion = 'app_version';
  
  /// Modo de tema de la aplicación
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  
  /// Idioma de la aplicación
  String get language => _prefs.getString(_keyLanguage) ?? 'es';
  
  /// Estado de las notificaciones
  bool get notificationsEnabled => _prefs.getBool(_keyNotifications) ?? true;
  
  /// Si es la primera vez que se abre la aplicación
  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;
  
  /// Última vez que se abrió la aplicación
  DateTime? get lastOpened {
    final timestamp = _prefs.getString(_keyLastOpened);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  
  /// Versión de la aplicación
  String get appVersion => _prefs.getString(_keyAppVersion) ?? '1.0.0';
  
  /// Preferencias del usuario
  Map<String, dynamic> get userPreferences {
    final prefsJson = _prefs.getString(_keyUserPreferences);
    if (prefsJson != null) {
      try {
        return jsonDecode(prefsJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }
  
  /// Establece el modo de tema
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(_keyThemeMode, mode);
  }
  
  /// Establece el idioma
  Future<bool> setLanguage(String language) async {
    return await _prefs.setString(_keyLanguage, language);
  }
  
  /// Establece el estado de las notificaciones
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(_keyNotifications, enabled);
  }
  
  /// Marca que ya no es la primera vez que se abre la aplicación
  Future<bool> setFirstLaunchCompleted() async {
    return await _prefs.setBool(_keyFirstLaunch, false);
  }
  
  /// Actualiza la última vez que se abrió la aplicación
  Future<bool> updateLastOpened() async {
    return await _prefs.setString(_keyLastOpened, DateTime.now().toIso8601String());
  }
  
  /// Establece la versión de la aplicación
  Future<bool> setAppVersion(String version) async {
    return await _prefs.setString(_keyAppVersion, version);
  }
  
  /// Establece las preferencias del usuario
  Future<bool> setUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefsJson = jsonEncode(preferences);
      return await _prefs.setString(_keyUserPreferences, prefsJson);
    } catch (e) {
      return false;
    }
  }
  
  /// Actualiza una preferencia específica del usuario
  Future<bool> updateUserPreference(String key, dynamic value) async {
    final currentPrefs = userPreferences;
    currentPrefs[key] = value;
    return await setUserPreferences(currentPrefs);
  }
  
  /// Obtiene una preferencia específica del usuario
  T? getUserPreference<T>(String key) {
    final prefs = userPreferences;
    return prefs[key] as T?;
  }
  
  /// Limpia todas las preferencias del usuario
  Future<bool> clearUserPreferences() async {
    return await _prefs.remove(_keyUserPreferences);
  }
  
  /// Limpia toda la configuración
  Future<bool> clearAllConfig() async {
    return await _prefs.clear();
  }
  
  /// Exporta la configuración como JSON
  Map<String, dynamic> exportConfig() {
    return {
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'isFirstLaunch': isFirstLaunch,
      'lastOpened': lastOpened?.toIso8601String(),
      'appVersion': appVersion,
      'userPreferences': userPreferences,
    };
  }
  
  /// Importa configuración desde JSON
  Future<bool> importConfig(Map<String, dynamic> config) async {
    try {
      if (config.containsKey('themeMode')) {
        await setThemeMode(config['themeMode']);
      }
      if (config.containsKey('language')) {
        await setLanguage(config['language']);
      }
      if (config.containsKey('notificationsEnabled')) {
        await setNotificationsEnabled(config['notificationsEnabled']);
      }
      if (config.containsKey('appVersion')) {
        await setAppVersion(config['appVersion']);
      }
      if (config.containsKey('userPreferences')) {
        await setUserPreferences(config['userPreferences']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Configuración por defecto de la aplicación
class DefaultAppConfig {
  static const String defaultThemeMode = 'system';
  static const String defaultLanguage = 'es';
  static const bool defaultNotificationsEnabled = true;
  static const String defaultAppVersion = '1.0.0';
  
  static Map<String, dynamic> get defaultUserPreferences => {
    'showOnboarding': true,
    'enableAnalytics': true,
    'enableCrashReporting': true,
    'autoSaveProgress': true,
    'showTips': true,
    'darkMode': false,
    'fontSize': 'medium',
    'soundEnabled': true,
    'vibrationEnabled': true,
  };
}
