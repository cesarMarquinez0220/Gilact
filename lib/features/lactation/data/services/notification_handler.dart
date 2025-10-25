import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'sleep_notification_service.dart';

/// Manejador global de notificaciones para la aplicación
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Inicializar el manejador con la clave de navegación
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Manejar cuando se toca una notificación
  static void handleNotificationTap(NotificationResponse response) {
    print('🔔 NotificationHandler: Notificación tocada - ID: ${response.id}');

    if (_navigatorKey?.currentState == null) {
      print('⚠️ NotificationHandler: Navigator no disponible');
      return;
    }

    final context = _navigatorKey!.currentState!.context;

    // Determinar el tipo de notificación basado en el ID
    switch (response.id) {
      case 999: // Notificación de prueba
        _handleTestNotification(context);
        break;
      default:
        // IDs 0-23 son recordatorios de sueño (horas del día)
        if (response.id != null && response.id! >= 0 && response.id! <= 23) {
          _handleSleepReminder(context, response.id!);
        } else {
          _handleGenericNotification(context);
        }
        break;
    }
  }

  /// Manejar recordatorio de sueño
  static void _handleSleepReminder(BuildContext context, int hour) {
    print(
      '🔔 NotificationHandler: Manejando recordatorio de sueño para las $hour:00',
    );

    // Navegar al formulario de registro de sueño usando rutas nombradas
    Navigator.of(context).pushNamed(
      '/sleep_record',
      arguments: {'from_notification': true, 'reminder_hour': hour},
    );
  }

  /// Manejar notificación de prueba
  static void _handleTestNotification(BuildContext context) {
    print('🔔 NotificationHandler: Manejando notificación de prueba');

    // Mostrar diálogo de prueba
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificación de Prueba'),
        content: const Text(
          'Esta es una notificación de prueba para el sistema de recordatorios de sueño.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar al formulario de sueño
              Navigator.of(context).pushNamed(
                '/sleep_record',
                arguments: {'from_notification': true},
              );
            },
            child: const Text('Registrar Sueño'),
          ),
        ],
      ),
    );
  }

  /// Manejar notificación genérica
  static void _handleGenericNotification(BuildContext context) {
    print('🔔 NotificationHandler: Manejando notificación genérica');

    // Mostrar mensaje genérico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación recibida'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navegar directamente al formulario de sueño
  static void navigateToSleepRecord(
    BuildContext context, {
    bool isFromNotification = false,
  }) {
    Navigator.of(context).pushNamed(
      '/sleep_record',
      arguments: {'from_notification': isFromNotification},
    );
  }

  /// Navegar al formulario de sueño desde cualquier parte de la app
  static void navigateToSleepRecordFromAnywhere({
    bool isFromNotification = false,
  }) {
    if (_navigatorKey?.currentState == null) {
      print('⚠️ NotificationHandler: Navigator no disponible para navegación');
      return;
    }

    final context = _navigatorKey!.currentState!.context;
    navigateToSleepRecord(context, isFromNotification: isFromNotification);
  }

  /// Verificar si hay contexto de navegación disponible
  static bool get isNavigationAvailable => _navigatorKey?.currentState != null;

  /// Obtener el contexto actual
  static BuildContext? get currentContext =>
      _navigatorKey?.currentState?.context;

  /// Programar notificaciones cada minuto para pruebas
  static Future<void> scheduleMinuteRemindersForTesting() async {
    try {
      final notificationService = GetIt.instance<SleepNotificationService>();
      await notificationService.scheduleMinuteReminders();

      print(
        '🔔 NotificationHandler: Notificaciones cada minuto programadas para pruebas',
      );
    } catch (e) {
      print(
        '❌ NotificationHandler: Error programando notificaciones cada minuto: $e',
      );
    }
  }
}

/// Extensión para facilitar el manejo de notificaciones
extension NotificationHandlerExtension on BuildContext {
  /// Navegar al formulario de sueño desde cualquier contexto
  void navigateToSleepRecord({bool isFromNotification = false}) {
    NotificationHandler.navigateToSleepRecord(
      this,
      isFromNotification: isFromNotification,
    );
  }
}
