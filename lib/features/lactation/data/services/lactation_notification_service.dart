import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../../lactation/data/services/lactation_service.dart';

/// Servicio para manejar notificaciones inteligentes de lactancia
class LactationNotificationService {
  static const String _keyLastNotification = 'last_lactation_notification';
  static const String _keyUserPreferences = 'notification_preferences';

  final LactationService _lactationService = GetIt.instance<LactationService>();

  /// Verifica si debe mostrar una notificación de recordatorio
  Future<bool> shouldShowReminderNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Verificar si ya se mostró una notificación hoy
      final lastNotification = prefs.getString(_keyLastNotification);
      if (lastNotification != null) {
        final lastNotificationDate = DateTime.parse(lastNotification);
        if (_isSameDay(lastNotificationDate, now)) {
          return false; // Ya se mostró hoy
        }
      }

      // Verificar si el usuario tiene registros recientes
      final hasRecentFeeds = await _hasRecentFeeds();
      if (hasRecentFeeds) {
        return false; // Ya está registrando, no necesita recordatorio
      }

      // Verificar si han pasado más de 3 horas desde la última toma
      final timeSinceLastFeed = await _getTimeSinceLastFeed();
      if (timeSinceLastFeed != null && timeSinceLastFeed.inHours >= 3) {
        return true; // Es hora de recordar
      }

      return false;
    } catch (e) {
      print('Error verificando notificación: $e');
      return false;
    }
  }

  /// Muestra una notificación motivacional
  Future<void> showMotivationalNotification(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Verificar si ya se mostró una notificación motivacional hoy
      final lastNotification = prefs.getString(_keyLastNotification);
      if (lastNotification != null) {
        final lastNotificationDate = DateTime.parse(lastNotification);
        if (_isSameDay(lastNotificationDate, now)) {
          return; // Ya se mostró hoy
        }
      }

      // Obtener estadísticas del día
      final todayStats = await _getTodayStats();

      // Mostrar notificación basada en el progreso
      final message = _getMotivationalMessage(todayStats);

      if (message != null) {
        _showNotificationDialog(context, message);

        // Marcar que se mostró la notificación
        await prefs.setString(_keyLastNotification, now.toIso8601String());
      }
    } catch (e) {
      print('Error mostrando notificación motivacional: $e');
    }
  }

  /// Verifica si el usuario tiene tomas recientes (últimas 2 horas)
  Future<bool> _hasRecentFeeds() async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      // Obtener registros de las últimas 2 horas
      final records = await _lactationService.getRecordsForDateRange(
        twoHoursAgo,
        now,
      );

      return records.isNotEmpty;
    } catch (e) {
      print('Error verificando tomas recientes: $e');
      return false;
    }
  }

  /// Obtiene el tiempo transcurrido desde la última toma
  Future<Duration?> _getTimeSinceLastFeed() async {
    try {
      final today = DateTime.now();
      final records = await _lactationService.getRecordsForDate(today);

      if (records.isNotEmpty) {
        final lastRecord = records.last;
        return today.difference(lastRecord.fechaRegistro);
      }

      return null;
    } catch (e) {
      print('Error obteniendo tiempo desde última toma: $e');
      return null;
    }
  }

  /// Obtiene estadísticas del día actual
  Future<Map<String, dynamic>> _getTodayStats() async {
    try {
      final today = DateTime.now();
      final records = await _lactationService.getRecordsForDate(today);

      final totalFeeds = records.length;
      final totalDuration = records.fold(
        Duration.zero,
        (total, record) => total + record.duracion,
      );

      return {
        'totalFeeds': totalFeeds,
        'totalDuration': totalDuration,
        'lastFeedTime': records.isNotEmpty ? records.last.fechaRegistro : null,
      };
    } catch (e) {
      print('Error obteniendo estadísticas del día: $e');
      return {
        'totalFeeds': 0,
        'totalDuration': Duration.zero,
        'lastFeedTime': null,
      };
    }
  }

  /// Genera mensaje motivacional basado en estadísticas
  String? _getMotivationalMessage(Map<String, dynamic> stats) {
    final totalFeeds = stats['totalFeeds'] as int;

    // Mensajes para diferentes situaciones
    if (totalFeeds == 0) {
      return '¡Hola mamá! 👋\n\nEs un gran día para comenzar a registrar las tomas de tu bebé. ¡Cada registro cuenta!';
    } else if (totalFeeds < 3) {
      return '¡Excelente! 🌟\n\nHas registrado $totalFeeds tomas hoy. ¡Continúa así!';
    } else if (totalFeeds < 6) {
      return '¡Increíble progreso! 🎉\n\n$totalFeeds tomas registradas hoy. ¡Tu bebé está bien alimentado!';
    } else if (totalFeeds < 8) {
      return '¡Fantástico! 🚀\n\n$totalFeeds tomas hoy. ¡Estás cumpliendo todas las metas!';
    } else {
      return '¡Eres una supermamá! 💪\n\n$totalFeeds tomas registradas. ¡Tu dedicación es admirable!';
    }
  }

  /// Muestra un diálogo de notificación
  void _showNotificationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF667eea),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Gracias'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar al registro de lactancia
              Navigator.pushNamed(context, '/lactation-calendar');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
            ),
            child: const Text(
              'Registrar Toma',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica si dos fechas son del mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Configura las preferencias de notificaciones del usuario
  Future<void> setNotificationPreferences({
    required bool enableReminders,
    required bool enableMotivational,
    required int reminderIntervalHours,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyUserPreferences,
        {
          'enableReminders': enableReminders,
          'enableMotivational': enableMotivational,
          'reminderIntervalHours': reminderIntervalHours,
        }.toString(),
      );
    } catch (e) {
      print('Error configurando preferencias: $e');
    }
  }

  /// Obtiene las preferencias de notificaciones del usuario
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferences = prefs.getString(_keyUserPreferences);

      if (preferences != null) {
        // Parsear las preferencias (implementación simplificada)
        return {
          'enableReminders': true,
          'enableMotivational': true,
          'reminderIntervalHours': 3,
        };
      }

      return {
        'enableReminders': true,
        'enableMotivational': true,
        'reminderIntervalHours': 3,
      };
    } catch (e) {
      print('Error obteniendo preferencias: $e');
      return {
        'enableReminders': true,
        'enableMotivational': true,
        'reminderIntervalHours': 3,
      };
    }
  }
}
