import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'app_logger.dart';

/// Servicio para manejar sonidos en la aplicación
class SoundService {
  final SharedPreferences _prefs;
  final AppLogger _logger;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _keySoundEnabled = 'soundEnabled';

  // Rutas de los archivos de sonido
  static const String _soundSuccess = 'assets/sounds/success.mp3';
  static const String _soundAchievement = 'assets/sounds/achivement.wav';
  static const String _soundLevelUp = 'assets/sounds/level_up.wav';
  static const String _soundTriviaCorrect = 'assets/sounds/trivia_correct.ogg';

  SoundService(this._prefs, this._logger);

  /// Verifica si el sonido está habilitado
  bool isSoundEnabled() {
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  /// Reproduce un sonido personalizado desde assets
  /// Solo reproduce si el sonido está habilitado
  Future<void> _playAssetSound(String assetPath) async {
    if (!isSoundEnabled()) return;

    try {
      await _audioPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
      );
    } catch (e, stackTrace) {
      // Ignorar errores de reproducción de sonido
      _logger.serviceError(
        'SoundService',
        'reproducir sonido $assetPath',
        e,
        stackTrace,
      );
    }
  }

  /// Reproduce un sonido del sistema (click, tap, etc.) como fallback
  /// Solo reproduce si el sonido está habilitado
  Future<void> playSystemSound(SystemSoundType soundType) async {
    if (!isSoundEnabled()) return;

    try {
      SystemSound.play(soundType);
    } catch (e, stackTrace) {
      _logger.serviceError(
        'SoundService',
        'reproducir sonido del sistema',
        e,
        stackTrace,
      );
    }
  }

  /// Reproduce sonido de click (usando sistema como fallback)
  Future<void> playClickSound() async {
    await playSystemSound(SystemSoundType.click);
  }

  /// Reproduce sonido de alerta (usando sistema como fallback)
  Future<void> playAlertSound() async {
    await playSystemSound(SystemSoundType.alert);
  }

  /// Reproduce sonido cuando se gana XP o se completa una acción exitosa
  Future<void> playSuccessSound() async {
    await _playAssetSound(_soundSuccess);
  }

  /// Reproduce sonido cuando se desbloquea un logro
  Future<void> playAchievementSound() async {
    await _playAssetSound(_soundAchievement);
  }

  /// Reproduce sonido cuando se sube de nivel
  Future<void> playLevelUpSound() async {
    await _playAssetSound(_soundLevelUp);
  }

  /// Reproduce sonido cuando se responde correctamente en una trivia
  Future<void> playTriviaCorrectSound() async {
    await _playAssetSound(_soundTriviaCorrect);
  }

  /// Reproduce sonido cuando hay un error
  Future<void> playErrorSound() async {
    await playAlertSound();
  }
}
