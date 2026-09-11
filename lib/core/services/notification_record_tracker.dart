import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para rastrear cuando se guardan registros y cancelar notificaciones de reenvío
class NotificationRecordTracker {
  static final NotificationRecordTracker _instance =
      NotificationRecordTracker._internal();
  factory NotificationRecordTracker() => _instance;
  NotificationRecordTracker._internal();

  // MethodChannel para comunicarse con código nativo
  static const MethodChannel _channel = MethodChannel('notification_record_tracker');

  /// Marca que se guardó un registro de sueño
  /// Esto cancela la notificación de reenvío programada
  Future<void> markSleepRecordSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('last_sleep_record_time', timestamp.toString());
      
      // Notificar al código nativo (Android)
      try {
        await _channel.invokeMethod('markSleepRecordSaved');
      } catch (e) {
        // Ignorar si no está disponible (iOS o error)
      }
      
      // Para iOS, también actualizar UserDefaults directamente
      // (aunque esto se hace mejor desde el código nativo)
    } catch (e) {
      // Ignorar errores silenciosamente
    }
  }

  /// Marca que se guardó un registro de lactancia
  /// Esto cancela la notificación de reenvío programada
  Future<void> markLactationRecordSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('last_lactation_record_time', timestamp.toString());
      
      // Notificar al código nativo (Android)
      try {
        await _channel.invokeMethod('markLactationRecordSaved');
      } catch (e) {
        // Ignorar si no está disponible (iOS o error)
      }
      
      // Para iOS, también actualizar UserDefaults directamente
      // (aunque esto se hace mejor desde el código nativo)
    } catch (e) {
      // Ignorar errores silenciosamente
    }
  }
}

