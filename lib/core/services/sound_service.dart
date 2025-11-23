import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Servicio para manejar sonidos en la aplicación
@singleton
class SoundService {
  final SharedPreferences _prefs;
  static const String _keySoundEnabled = 'soundEnabled';

  SoundService(this._prefs);

  /// Verifica si el sonido está habilitado
  bool isSoundEnabled() {
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  /// Reproduce un sonido del sistema (click, tap, etc.)
  /// Solo reproduce si el sonido está habilitado
  Future<void> playSystemSound(SystemSoundType soundType) async {
    if (!isSoundEnabled()) return;

    try {
      SystemSound.play(soundType);
    } catch (e) {
      // Ignorar errores de reproducción de sonido
      print('⚠️ Error reproduciendo sonido: $e');
    }
  }

  /// Reproduce sonido de click
  Future<void> playClickSound() async {
    await playSystemSound(SystemSoundType.click);
  }

  /// Reproduce sonido de alerta
  Future<void> playAlertSound() async {
    await playSystemSound(SystemSoundType.alert);
  }

  /// Reproduce sonido cuando se completa una acción
  Future<void> playSuccessSound() async {
    // Usar click como sonido de éxito
    await playClickSound();
  }

  /// Reproduce sonido cuando hay un error
  Future<void> playErrorSound() async {
    await playAlertSound();
  }
}

