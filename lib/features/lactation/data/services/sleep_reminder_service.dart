import 'dart:async';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Servicio para manejar recordatorios automáticos sobre el sueño del bebé
/// Versión simplificada sin dependencias externas
class SleepReminderService {
  static final List<SleepReminderData> _pendingReminders = [];

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    final logger = getIt<AppLogger>();
    logger.d('SleepReminderService inicializado');
  }

  /// Programa una notificación para preguntar sobre el sueño del bebé
  /// Se ejecutará a las 8:00 AM del día siguiente
  static Future<void> scheduleSleepReminder({
    required DateTime feedingTime,
    required String feedingType,
  }) async {
    // Calcular la fecha y hora para la notificación (8 AM del día siguiente)
    final tomorrow = feedingTime.add(const Duration(days: 1));
    final notificationTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      8, // 8:00 AM
      0,
    );

    // Verificar que la hora sea válida (no en el pasado)
    if (notificationTime.isBefore(DateTime.now())) {
      final logger = getIt<AppLogger>();
      logger.w('La hora de notificación está en el pasado, no se programará');
      return;
    }

    // Crear el recordatorio
    final reminder = SleepReminderData(
      feedingTime: feedingTime,
      feedingType: feedingType,
      reminderTime: notificationTime,
      notificationId: feedingTime.millisecondsSinceEpoch,
    );

    // Agregar a la lista de recordatorios pendientes
    _pendingReminders.add(reminder);

    final logger = getIt<AppLogger>();
    logger.success('Recordatorio programado para: $notificationTime');
    logger.d('Tipo de alimentación: $feedingType');
  }

  /// Cancela todas las notificaciones programadas
  static Future<void> cancelAllNotifications() async {
    _pendingReminders.clear();
    final logger = getIt<AppLogger>();
    logger.d('Todos los recordatorios cancelados');
  }

  /// Cancela una notificación específica
  static Future<void> cancelNotification(int id) async {
    _pendingReminders.removeWhere((reminder) => reminder.notificationId == id);
    final logger = getIt<AppLogger>();
    logger.d('Recordatorio $id cancelado');
  }

  /// Obtiene los recordatorios pendientes
  static List<SleepReminderData> getPendingReminders() {
    return List.from(_pendingReminders);
  }

  /// Programa múltiples recordatorios para diferentes horarios
  static Future<void> scheduleMultipleReminders({
    required List<DateTime> feedingTimes,
    required String feedingType,
  }) async {
    for (final feedingTime in feedingTimes) {
      await scheduleSleepReminder(
        feedingTime: feedingTime,
        feedingType: feedingType,
      );
    }
  }

  /// Actualiza un recordatorio existente
  static Future<void> updateSleepReminder({
    required int notificationId,
    required DateTime feedingTime,
    required String feedingType,
  }) async {
    // Cancelar el recordatorio anterior
    await cancelNotification(notificationId);

    // Programar el nuevo
    await scheduleSleepReminder(
      feedingTime: feedingTime,
      feedingType: feedingType,
    );
  }

  /// Verifica si hay recordatorios pendientes para hoy
  static bool hasRemindersForToday() {
    final today = DateTime.now();
    return _pendingReminders.any((reminder) {
      return reminder.reminderTime.year == today.year &&
          reminder.reminderTime.month == today.month &&
          reminder.reminderTime.day == today.day;
    });
  }

  /// Obtiene el próximo recordatorio
  static SleepReminderData? getNextReminder() {
    if (_pendingReminders.isEmpty) return null;

    _pendingReminders.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
    return _pendingReminders.first;
  }
}

/// Clase para manejar datos de recordatorios
class SleepReminderData {
  final DateTime feedingTime;
  final String feedingType;
  final DateTime reminderTime;
  final int notificationId;

  SleepReminderData({
    required this.feedingTime,
    required this.feedingType,
    required this.reminderTime,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedingTime': feedingTime.toIso8601String(),
      'feedingType': feedingType,
      'reminderTime': reminderTime.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  factory SleepReminderData.fromMap(Map<String, dynamic> map) {
    return SleepReminderData(
      feedingTime: DateTime.parse(map['feedingTime']),
      feedingType: map['feedingType'],
      reminderTime: DateTime.parse(map['reminderTime']),
      notificationId: map['notificationId'],
    );
  }
}
