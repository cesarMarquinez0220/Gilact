import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:easy_localization/easy_localization.dart';

/// Servicio para manejar la localización e idioma de la aplicación
@singleton
class LocalizationService {
  final SharedPreferences _prefs;
  static const String _keyLanguage = 'language';

  LocalizationService(this._prefs);

  /// Obtiene el idioma actual guardado
  /// Retorna null si no hay preferencia guardada (para permitir detección automática)
  String? getCurrentLanguage() {
    return _prefs.getString(_keyLanguage);
  }

  /// Guarda el idioma seleccionado y actualiza EasyLocalization
  Future<bool> setLanguage(String languageCode) async {
    final saved = await _prefs.setString(_keyLanguage, languageCode);
    // El cambio de idioma se maneja a través de EasyLocalization
    return saved;
  }

  /// Obtiene el Locale correspondiente al código de idioma
  /// Retorna null si no hay preferencia guardada (para permitir detección automática del dispositivo)
  Locale? getLocale() {
    final languageCode = getCurrentLanguage();
    if (languageCode == null) {
      // No hay preferencia guardada, retornar null para permitir detección automática
      return null;
    }
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'es':
      default:
        return const Locale('es');
    }
  }

  /// Obtiene la lista de idiomas soportados
  List<Locale> getSupportedLocales() {
    return [
      const Locale('es'),
      const Locale('en'),
    ];
  }
}

