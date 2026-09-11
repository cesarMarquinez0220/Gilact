import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_logger.dart';
import '../di/injection.dart';

/// Servicio para manejar notificaciones pendientes cuando la app está cerrada
class PendingNotificationService {
  static const String _pendingNotificationKey = 'pending_notification';

  /// Guardar información de notificación pendiente
  static Future<void> savePendingNotification({
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationData = {
        'type': type,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(
        _pendingNotificationKey,
        jsonEncode(notificationData),
      );
      final logger = getIt<AppLogger>();
      logger.d(
        'PendingNotificationService: Notificación pendiente guardada: $type',
      );
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e(
        'PendingNotificationService: Error guardando notificación pendiente',
        e,
        stackTrace,
      );
    }
  }

  /// Obtener notificación pendiente
  static Future<Map<String, dynamic>?> getPendingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationJson = prefs.getString(_pendingNotificationKey);
      if (notificationJson != null) {
        final notificationData =
            jsonDecode(notificationJson) as Map<String, dynamic>;
        final logger = getIt<AppLogger>();
        logger.d(
          'PendingNotificationService: Notificación pendiente encontrada: ${notificationData['type']}',
        );
        return notificationData;
      }
      return null;
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e(
        'PendingNotificationService: Error obteniendo notificación pendiente',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Limpiar notificación pendiente
  static Future<void> clearPendingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingNotificationKey);
      final logger = getIt<AppLogger>();
      logger.d('PendingNotificationService: Notificación pendiente limpiada');
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e(
        'PendingNotificationService: Error limpiando notificación pendiente',
        e,
        stackTrace,
      );
    }
  }

  /// Verificar si hay notificación pendiente
  static Future<bool> hasPendingNotification() async {
    final notification = await getPendingNotification();
    return notification != null;
  }
}
