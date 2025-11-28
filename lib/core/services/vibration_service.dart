import 'dart:io';
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
  static const MethodChannel _vibrationChannel = MethodChannel(
    'system_vibration',
  );

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
      _logger.serviceError(
        'VibrationService',
        'vibración ligera',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra con feedback háptico medio
  Future<void> mediumImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e, stackTrace) {
      _logger.serviceError(
        'VibrationService',
        'vibración media',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra con feedback háptico pesado
  Future<void> heavyImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e, stackTrace) {
      _logger.serviceError(
        'VibrationService',
        'vibración pesada',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra con feedback de selección (para switches, botones, etc.)
  Future<void> selectionClick() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e, stackTrace) {
      _logger.serviceError(
        'VibrationService',
        'vibración de selección',
        e,
        stackTrace,
      );
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
      _logger.serviceError(
        'VibrationService',
        'vibración de éxito',
        e,
        stackTrace,
      );
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
      _logger.serviceError(
        'VibrationService',
        'vibración de logro',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra cuando se desbloquea un logro (patrón tipo Duolingo)
  /// Usa vibraciones del sistema nativas para máxima percepción
  /// Funciona incluso en modo silencio (vibraciones del sistema no dependen del modo silencio)
  Future<void> vibrateOnAchievementDuolingoStyle() async {
    if (!isVibrationEnabled()) {
      _logger.d('VibrationService: Vibración deshabilitada por el usuario');
      return;
    }

    try {
      _logger.d(
        'VibrationService: Iniciando vibración Duolingo style con vibraciones del sistema',
      );

      // Intentar usar vibraciones del sistema nativas (Android)
      if (Platform.isAndroid) {
        try {
          // Patrón tipo Duolingo mejorado según especificaciones:
          // 1. Pulse corto: 60ms, intensidad media (amplitud 128)
          // 2. Pausa: 40ms
          // 3. Doble pulse rápido: 50ms cada uno, intensidad media-baja (amplitud 100), pausa 30ms entre ellos
          // 4. Pausa: 80ms (antes del final)
          // 5. Pulse final: 80ms, intensidad baja (amplitud 70)
          // Formato: [vibración, pausa, vibración, pausa, ...]
          final pattern = [60, 40, 50, 30, 50, 80, 80];
          // Amplitudes: [media, 0, media-baja, 0, media-baja, 0, baja]
          // 0 = pausa, 128 = media, 100 = media-baja, 70 = baja
          final amplitudes = [128, 0, 100, 0, 100, 0, 70];

          await _vibrationChannel.invokeMethod('vibratePattern', {
            'pattern': pattern.map((e) => e.toInt()).toList(),
            'amplitudes': amplitudes,
          });

          _logger.d(
            'VibrationService: Vibración Duolingo style con sistema nativo completada',
          );
          return;
        } catch (e) {
          _logger.d(
            'VibrationService: Error con vibración nativa, usando HapticFeedback: $e',
          );
          // Continuar con fallback
        }
      }

      // Fallback: HapticFeedback secuencial (simulando el patrón especificado)
      _logger.d('VibrationService: Usando HapticFeedback como fallback');

      // 1. Pulse corto: 60ms, intensidad media
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 40)); // Pausa

      // 2. Doble pulse rápido: 50ms cada uno, intensidad media-baja
      await lightImpact(); // Simula media-baja
      await Future.delayed(
        const Duration(milliseconds: 30),
      ); // Pausa entre ellos
      await lightImpact(); // Segundo pulse
      await Future.delayed(
        const Duration(milliseconds: 80),
      ); // Pausa antes del final

      // 3. Pulse final más suave: 80ms, intensidad baja
      await lightImpact(); // Simula baja intensidad (más suave)

      _logger.d(
        'VibrationService: Vibración Duolingo style con HapticFeedback completada',
      );
    } catch (e, stackTrace) {
      // Fallback final a método básico si hay error
      _logger.serviceError(
        'VibrationService',
        'vibración Duolingo style',
        e,
        stackTrace,
      );
      _logger.d(
        'VibrationService: Error en vibración Duolingo, usando fallback básico',
      );
      await vibrateOnAchievement();
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
      _logger.serviceError(
        'VibrationService',
        'vibración de XP',
        e,
        stackTrace,
      );
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
      _logger.serviceError(
        'VibrationService',
        'vibración de nivel',
        e,
        stackTrace,
      );
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
      _logger.serviceError(
        'VibrationService',
        'vibración de trivia',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra cuando hay un error
  Future<void> vibrateOnError() async {
    if (!isVibrationEnabled()) return;
    try {
      await mediumImpact();
    } catch (e, stackTrace) {
      _logger.serviceError(
        'VibrationService',
        'vibración de error',
        e,
        stackTrace,
      );
    }
  }

  /// Vibra cuando se presiona un botón
  Future<void> vibrateOnButtonPress() async {
    await selectionClick();
  }
}
