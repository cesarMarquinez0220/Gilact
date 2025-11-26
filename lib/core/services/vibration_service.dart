import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'app_logger.dart';

/// Servicio para manejar vibraciones en la aplicación
@singleton
class VibrationService {
  final SharedPreferences _prefs;
  final AppLogger _logger;
  static const String _keyVibrationEnabled = 'vibrationEnabled';

  VibrationService(this._prefs, this._logger);

  /// Verifica si la vibración está habilitada
  bool isVibrationEnabled() {
    return _prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  /// Vibra con feedback háptico ligero
  /// Solo vibra si la vibración está habilitada
  Future<void> lightImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e, stackTrace) {
      // Ignorar errores de vibración
      _logger.serviceError('VibrationService', 'vibración ligera', e, stackTrace);
    }
  }

  /// Vibra con feedback háptico medio
  Future<void> mediumImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración media', e, stackTrace);
    }
  }

  /// Vibra con feedback háptico pesado
  Future<void> heavyImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración pesada', e, stackTrace);
    }
  }

  /// Vibra con feedback de selección (para switches, botones, etc.)
  Future<void> selectionClick() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de selección', e, stackTrace);
    }
  }

  /// Vibra cuando se completa una acción exitosa
  /// Patrón: vibración ligera seguida de una pausa y otra ligera (suave y celebratorio)
  Future<void> vibrateOnSuccess() async {
    if (!isVibrationEnabled()) return;
    try {
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await lightImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de éxito', e, stackTrace);
    }
  }

  /// Vibra cuando se desbloquea un logro
  /// Patrón: ligera-mediana-ligera (patrón de celebración)
  Future<void> vibrateOnAchievement() async {
    if (!isVibrationEnabled()) return;
    try {
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await lightImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de logro', e, stackTrace);
    }
  }

  /// Vibra cuando se gana XP
  /// Patrón: ligera-ligera (doble toque suave)
  Future<void> vibrateOnXP() async {
    if (!isVibrationEnabled()) return;
    try {
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await lightImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de XP', e, stackTrace);
    }
  }

  /// Vibra cuando se sube de nivel
  /// Patrón: ligera-mediana-ligera-mediana (patrón especial de celebración)
  Future<void> vibrateOnLevelUp() async {
    if (!isVibrationEnabled()) return;
    try {
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 70));
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await mediumImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de nivel', e, stackTrace);
    }
  }

  /// Vibra cuando se completa una trivia correctamente
  /// Patrón: ligera-ligera-ligera (triple toque suave)
  Future<void> vibrateOnTriviaCorrect() async {
    if (!isVibrationEnabled()) return;
    try {
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 40));
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 40));
      await lightImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de trivia', e, stackTrace);
    }
  }

  /// Vibra cuando hay un error
  Future<void> vibrateOnError() async {
    if (!isVibrationEnabled()) return;
    try {
      await mediumImpact();
    } catch (e, stackTrace) {
      _logger.serviceError('VibrationService', 'vibración de error', e, stackTrace);
    }
  }

  /// Vibra cuando se presiona un botón
  Future<void> vibrateOnButtonPress() async {
    await selectionClick();
  }
}
