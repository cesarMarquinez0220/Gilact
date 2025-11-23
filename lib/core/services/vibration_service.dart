import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Servicio para manejar vibraciones en la aplicación
@singleton
class VibrationService {
  final SharedPreferences _prefs;
  static const String _keyVibrationEnabled = 'vibrationEnabled';

  VibrationService(this._prefs);

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
    } catch (e) {
      // Ignorar errores de vibración
      print('⚠️ Error en vibración ligera: $e');
    }
  }

  /// Vibra con feedback háptico medio
  Future<void> mediumImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('⚠️ Error en vibración media: $e');
    }
  }

  /// Vibra con feedback háptico pesado
  Future<void> heavyImpact() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('⚠️ Error en vibración pesada: $e');
    }
  }

  /// Vibra con feedback de selección (para switches, botones, etc.)
  Future<void> selectionClick() async {
    if (!isVibrationEnabled()) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      print('⚠️ Error en vibración de selección: $e');
    }
  }

  /// Vibra cuando se completa una acción exitosa
  Future<void> vibrateOnSuccess() async {
    await lightImpact();
  }

  /// Vibra cuando hay un error
  Future<void> vibrateOnError() async {
    await mediumImpact();
  }

  /// Vibra cuando se presiona un botón
  Future<void> vibrateOnButtonPress() async {
    await selectionClick();
  }
}

