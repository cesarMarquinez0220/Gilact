import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import 'notification_handler.dart';
import 'sleep_notification_service.dart';

/// Servicio para manejar notificaciones de recordatorio de lactancia
/// Programa notificaciones cuando pasan 2 horas desde la última toma
class LactationNotificationService {
  static final LactationNotificationService _instance =
      LactationNotificationService._internal();
  factory LactationNotificationService() => _instance;
  LactationNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AppLogger _logger = getIt<AppLogger>();
  bool _isInitialized = false;

  // MethodChannel para programar alarmas nativas (funciona incluso con app cerrada)
  static const MethodChannel _nativeAlarmChannel = MethodChannel(
    'native_alarm_scheduler',
  );

  // Timer para verificar periódicamente si la notificación debería haberse disparado
  Timer? _notificationCheckTimer;
  int? _currentNotificationId;
  tz.TZDateTime? _currentScheduledTime;

  // ID base para notificaciones de lactancia
  static const int _lactationNotificationIdBase = 1000;
  // ID para la notificación diaria de sueño
  static const int _sleepNotificationId = 889;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          NotificationHandler.handleNotificationTap,
    );

    _isInitialized = true;
    _logger.d('LactationNotificationService: Servicio inicializado');
  }

  /// Calcula el intervalo de lactancia recomendado basado en la edad del bebé
  /// Los intervalos aumentan a medida que el bebé crece
  static Duration calculateLactationInterval(DateTime? birthDate) {
    if (birthDate == null) {
      // Si no hay fecha de nacimiento, usar intervalo por defecto de 2 horas
      return const Duration(hours: 2);
    }

    final now = DateTime.now();
    final ageInMonths = _calculateAgeInMonths(birthDate, now);

    // Intervalos recomendados según la edad del bebé
    if (ageInMonths < 1) {
      // 0-1 mes: cada 2 horas
      return const Duration(hours: 2);
    } else if (ageInMonths < 2) {
      // 1-2 meses: cada 2.5 horas
      return const Duration(hours: 2, minutes: 30);
    } else if (ageInMonths < 3) {
      // 2-3 meses: cada 3 horas
      return const Duration(hours: 3);
    } else if (ageInMonths < 4) {
      // 3-4 meses: cada 3.5 horas
      return const Duration(hours: 3, minutes: 30);
    } else if (ageInMonths < 6) {
      // 4-6 meses: cada 4 horas
      return const Duration(hours: 4);
    } else {
      // 6+ meses: cada 4.5 horas
      return const Duration(hours: 4, minutes: 30);
    }
  }

  /// Calcula la edad del bebé en meses
  static int _calculateAgeInMonths(DateTime birthDate, DateTime now) {
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    final totalMonths = years * 12 + months;

    // Ajustar si el día del mes aún no ha llegado
    if (now.day < birthDate.day) {
      return totalMonths > 0 ? totalMonths - 1 : 0;
    }

    return totalMonths;
  }

  /// Programar notificación de lactancia según la edad del bebé
  Future<void> scheduleLactationReminder({
    required DateTime lastFeedTime,
    String? babyName,
    DateTime? babyBirthDate,
  }) async {
    await initialize();

    // Verificar permisos de notificación
    final bool? granted = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (granted != true) {
      _logger.e(
        'LactationNotificationService: Permisos de notificación NO concedidos',
      );
      return;
    }

    // Calcular intervalo de lactancia basado en la edad del bebé
    final lactationInterval = calculateLactationInterval(babyBirthDate);

    _logger.d(
      'LactationNotificationService: Intervalo calculado basado en edad del bebé: ${lactationInterval.inHours}h ${lactationInterval.inMinutes.remainder(60)}m',
    );

    // Calcular tiempo de notificación según el intervalo calculado
    final notificationTime = lastFeedTime.add(lactationInterval);
    final now = tz.TZDateTime.now(tz.local);

    _logger.d(
      'LactationNotificationService: Última toma: ${lastFeedTime.toString()}',
    );
    _logger.d(
      'LactationNotificationService: Intervalo: ${lactationInterval.inMinutes} minutos',
    );
    _logger.d('LactationNotificationService: Hora actual: ${now.toString()}');
    _logger.d(
      'LactationNotificationService: Hora programada: ${notificationTime.toString()}',
    );
    _logger.d(
      'LactationNotificationService: Tiempo hasta notificación: ${notificationTime.difference(now).inMinutes} minutos',
    );

    // Si el tiempo ya pasó, no programar
    if (notificationTime.isBefore(now)) {
      _logger.w(
        'LactationNotificationService: El tiempo de notificación ya pasó, no se programará',
      );
      return;
    }

    // Convertir a TZDateTime
    final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    // Usar el timestamp de la última toma como parte del ID para hacerlo único
    final notificationId =
        _lactationNotificationIdBase +
        (lastFeedTime.millisecondsSinceEpoch % 10000).toInt();

    // Guardar información de la notificación programada
    await _saveScheduledNotification(
      notificationId: notificationId,
      scheduledTime: scheduledTime,
      lastFeedTime: lastFeedTime,
    );

    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'lactation_reminders',
      'Recordatorios de Lactancia',
      channelDescription:
          'Notificaciones para recordar registrar la próxima toma de lactancia',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4FD1C7),
      ledColor: Color(0xFF4FD1C7),
      ledOnMs: 1000,
      ledOffMs: 500,
      // Configurar para que no se elimine automáticamente
      autoCancel: false,
      ongoing: false,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // PRIMERO intentar con método nativo (más confiable cuando app está cerrada)
    // Si falla, usar flutter_local_notifications como fallback
    bool scheduledSuccessfully = false;

    // Intentar programar con método nativo primero
    try {
      _logger.d(
        'LactationNotificationService: Intentando programar con método NATIVO (funciona con app cerrada)...',
      );

      // Convertir la fecha programada a timestamp en milisegundos
      final timestamp = scheduledTime.millisecondsSinceEpoch;

      // Obtener mensaje de notificación
      final notificationMessage = _getNotificationMessage(
        babyName,
        lactationInterval,
      );

      final result = await _nativeAlarmChannel
          .invokeMethod<bool>('scheduleLactationNotification', {
            'timestamp': timestamp,
            'notification_id': notificationId,
            'title': '🍼 Recordatorio de Lactancia',
            'body': notificationMessage,
          });

      if (result == true) {
        _logger.success(
          'LactationNotificationService: Notificación programada con método NATIVO',
        );
        scheduledSuccessfully = true;

        // Guardar información de notificación programada
        await _saveScheduledNotification(
          notificationId: notificationId,
          scheduledTime: scheduledTime,
          lastFeedTime: lastFeedTime,
        );

        // Iniciar verificación periódica cada minuto para detectar si no se disparó
        _startNotificationCheckTimer(notificationId, scheduledTime);
      }
    } catch (e, stackTrace) {
      _logger.w(
        'LactationNotificationService: Error programando con método nativo',
        e,
        stackTrace,
      );
      _logger.w('Intentando con flutter_local_notifications como fallback...');
      scheduledSuccessfully = false;
    }

    // Si el método nativo falló, usar flutter_local_notifications como fallback
    if (!scheduledSuccessfully) {
      try {
        await _notifications.zonedSchedule(
          notificationId,
          '🍼 Recordatorio de Lactancia',
          _getNotificationMessage(babyName, lactationInterval),
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'lactation_reminder_${lastFeedTime.millisecondsSinceEpoch}',
        );

        _logger.success(
          'LactationNotificationService: Notificación programada para ${scheduledTime.toString()}',
        );

        // Verificar que se programó correctamente
        final androidNotifications = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidNotifications != null) {
          // Esperar un poco para que se registre
          await Future.delayed(const Duration(milliseconds: 500));

          final pending = await androidNotifications
              .pendingNotificationRequests();
          final ourNotificationList = pending
              .where((n) => n.id == notificationId)
              .toList();
          if (ourNotificationList.isNotEmpty) {
            final ourNotification = ourNotificationList.first;
            _logger.success(
              'LactationNotificationService: Notificación verificada en lista pendiente:',
            );
            _logger.d('   ID: ${ourNotification.id}');
            _logger.d('   Título: ${ourNotification.title}');
            _logger.d('   Cuerpo: ${ourNotification.body}');
          } else {
            _logger.e(
              'LactationNotificationService: ERROR - Notificación NO encontrada en lista pendiente después de programar',
            );
          }
        }

        // Iniciar verificación periódica cada minuto para detectar si no se disparó
        _startNotificationCheckTimer(notificationId, scheduledTime);
      } catch (e, stackTrace) {
        _logger.e(
          'LactationNotificationService: Error programando notificación',
          e,
          stackTrace,
        );
        // Intentar con modo inexacto si falla el modo exacto
        try {
          await _notifications.zonedSchedule(
            notificationId,
            '🍼 Recordatorio de Lactancia',
            _getNotificationMessage(babyName, lactationInterval),
            scheduledTime,
            details,
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload:
                'lactation_reminder_${lastFeedTime.millisecondsSinceEpoch}',
          );
          _logger.success(
            'LactationNotificationService: Notificación programada (modo inexacto)',
          );
        } catch (e2, stackTrace2) {
          _logger.e(
            'LactationNotificationService: Error programando notificación (modo inexacto)',
            e2,
            stackTrace2,
          );
        }
      }
    }

    // Guardar información de notificación programada
    await _saveScheduledNotification(
      notificationId: notificationId,
      scheduledTime: scheduledTime,
      lastFeedTime: lastFeedTime,
    );
  }

  /// Guardar información de notificación programada para verificación posterior
  Future<void> _saveScheduledNotification({
    required int notificationId,
    required tz.TZDateTime scheduledTime,
    required DateTime lastFeedTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'lactation_notification_$notificationId',
      scheduledTime.millisecondsSinceEpoch,
    );
    await prefs.setInt(
      'lactation_notification_${notificationId}_feed_time',
      lastFeedTime.millisecondsSinceEpoch,
    );
  }

  /// Cancelar notificación de lactancia específica
  Future<void> cancelLactationReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
    _stopNotificationCheckTimer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lactation_notification_$notificationId');
    await prefs.remove('lactation_notification_${notificationId}_feed_time');
    _logger.d(
      'LactationNotificationService: Notificación $notificationId cancelada',
    );
  }

  /// Cancelar todas las notificaciones de lactancia
  Future<void> cancelAllLactationReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('lactation_notification_') &&
          !key.contains('_feed_time')) {
        final notificationIdStr = key.replaceAll('lactation_notification_', '');
        final notificationId = int.tryParse(notificationIdStr);
        if (notificationId != null) {
          await _notifications.cancel(notificationId);
          await prefs.remove(key);
          await prefs.remove(
            'lactation_notification_${notificationId}_feed_time',
          );
        }
      }
    }

    _logger.d(
      'LactationNotificationService: Todas las notificaciones canceladas',
    );
  }

  /// Verificar y reprogramar notificaciones eliminadas
  Future<void> verifyAndRescheduleNotifications() async {
    await initialize();

    // Verificar notificaciones de lactancia
    await _verifyLactationNotifications();

    // Verificar notificación de sueño
    await _verifySleepNotification();
  }

  /// Verificar notificaciones de lactancia y reprogramar si fueron eliminadas
  Future<void> _verifyLactationNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotifications == null) return;

      final pendingNotifications = await androidNotifications
          .pendingNotificationRequests();

      final pendingIds = pendingNotifications.map((n) => n.id).toSet();

      // Obtener todas las notificaciones guardadas
      final keys = prefs.getKeys();
      final scheduledNotifications = <int, Map<String, int>>{};

      for (final key in keys) {
        if (key.startsWith('lactation_notification_') &&
            !key.contains('_feed_time')) {
          final notificationIdStr = key.replaceAll(
            'lactation_notification_',
            '',
          );
          final notificationId = int.tryParse(notificationIdStr);
          if (notificationId != null) {
            final scheduledTime = prefs.getInt(key);
            final feedTime = prefs.getInt(
              'lactation_notification_${notificationId}_feed_time',
            );
            if (scheduledTime != null && feedTime != null) {
              scheduledNotifications[notificationId] = {
                'scheduled': scheduledTime,
                'feed': feedTime,
              };
            }
          }
        }
      }

      // Reprogramar notificaciones que fueron eliminadas
      for (final entry in scheduledNotifications.entries) {
        final notificationId = entry.key;
        final data = entry.value;

        if (!pendingIds.contains(notificationId)) {
          // La notificación fue eliminada, reprogramarla
          final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
            data['scheduled']!,
          );
          final feedTime = DateTime.fromMillisecondsSinceEpoch(data['feed']!);
          final now = DateTime.now();

          // Solo reprogramar si el tiempo programado aún no ha pasado
          if (scheduledTime.isAfter(now)) {
            _logger.d(
              'LactationNotificationService: Reprogramando notificación eliminada $notificationId',
            );
            await scheduleLactationReminder(lastFeedTime: feedTime);
          } else {
            // Eliminar de preferencias si ya pasó
            await prefs.remove('lactation_notification_$notificationId');
            await prefs.remove(
              'lactation_notification_${notificationId}_feed_time',
            );
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.e(
        'LactationNotificationService: Error verificando notificaciones',
        e,
        stackTrace,
      );
    }
  }

  /// Verificar notificación de sueño y reprogramar si fue eliminada
  Future<void> _verifySleepNotification() async {
    try {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotifications == null) return;

      final pendingNotifications = await androidNotifications
          .pendingNotificationRequests();

      final hasSleepNotification = pendingNotifications.any(
        (n) => n.id == _sleepNotificationId,
      );

      if (!hasSleepNotification) {
        // La notificación de sueño fue eliminada, reprogramarla
        _logger.d(
          'LactationNotificationService: Reprogramando notificación de sueño eliminada',
        );
        // Importar y usar el servicio de notificaciones de sueño
        final sleepService = SleepNotificationService();
        await sleepService.scheduleDailySleepNotification();
      }
    } catch (e, stackTrace) {
      _logger.e(
        'LactationNotificationService: Error verificando notificación de sueño',
        e,
        stackTrace,
      );
    }
  }

  /// Obtener notificaciones pendientes de lactancia
  Future<List<int>> getPendingLactationNotificationIds() async {
    try {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotifications == null) return [];

      final pendingNotifications = await androidNotifications
          .pendingNotificationRequests();

      return pendingNotifications
          .where((n) => n.id >= _lactationNotificationIdBase)
          .map((n) => n.id)
          .toList();
    } catch (e, stackTrace) {
      _logger.e(
        'LactationNotificationService: Error obteniendo notificaciones pendientes',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Obtiene el mensaje de notificación personalizado según el intervalo
  String _getNotificationMessage(String? babyName, Duration interval) {
    final hours = interval.inHours;
    final minutes = interval.inMinutes.remainder(60);

    String timeText;
    if (minutes > 0) {
      timeText = '${hours}h ${minutes}m';
    } else {
      timeText = '${hours}h';
    }

    if (babyName != null) {
      return 'Han pasado $timeText desde la última toma de $babyName';
    } else {
      return 'Han pasado $timeText desde la última toma';
    }
  }

  /// Iniciar timer para verificar periódicamente si la notificación debería haberse disparado
  void _startNotificationCheckTimer(
    int notificationId,
    tz.TZDateTime scheduledTime,
  ) {
    // Cancelar timer anterior si existe
    _notificationCheckTimer?.cancel();

    _currentNotificationId = notificationId;
    _currentScheduledTime = scheduledTime;

    _logger.d(
      'LactationNotificationService: Iniciando verificación periódica cada minuto para notificación $notificationId',
    );

    // Verificar cada minuto si la notificación debería haberse disparado
    _notificationCheckTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) async {
      try {
        if (_currentScheduledTime == null || _currentNotificationId == null) {
          timer.cancel();
          _notificationCheckTimer = null;
          return;
        }

        final now = tz.TZDateTime.now(tz.local);
        final diff = _currentScheduledTime!.difference(now);

        _logger.d(
          'LactationNotificationService: Verificación periódica - Diferencia: ${diff.inMinutes} minutos (${diff.isNegative ? "PASÓ" : "FUTURO"})',
        );

        // Si la fecha programada ya pasó (0 minutos o más)
        if (diff.isNegative || diff.inMinutes == 0) {
          _logger.d(
            'LactationNotificationService: Verificación periódica - Fecha programada ya pasó o es ahora (${diff.inMinutes} minutos)',
          );

          // Verificar si la notificación aún está pendiente
          final androidNotifications = _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

          if (androidNotifications != null) {
            final pending = await androidNotifications
                .pendingNotificationRequests();
            final isStillPending = pending.any(
              (n) => n.id == _currentNotificationId,
            );

            _logger.d(
              'LactationNotificationService: Notificación aún pendiente: $isStillPending',
            );

            if (isStillPending) {
              _logger.w(
                'LactationNotificationService: PROBLEMA DETECTADO - Notificación programada NO se disparó!',
              );
              _logger.d(
                'LactationNotificationService: Mostrando notificación inmediata como fallback...',
              );

              // Cancelar el timer ya que vamos a manejar esto
              timer.cancel();
              _notificationCheckTimer = null;

              // Cancelar la notificación programada que no se disparó
              await _notifications.cancel(_currentNotificationId!);

              // Mostrar notificación inmediata como fallback
              try {
                await _notifications.show(
                  _currentNotificationId!,
                  '🍼 Recordatorio de Lactancia',
                  'Han pasado 2 minutos desde la última toma',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'lactation_reminders',
                      'Recordatorios de Lactancia',
                      importance: Importance.high,
                      priority: Priority.high,
                      icon: '@mipmap/ic_launcher',
                      enableVibration: true,
                      playSound: true,
                      category: AndroidNotificationCategory.reminder,
                    ),
                  ),
                  payload: 'lactation_reminder_fallback',
                );
                _logger.success(
                  'LactationNotificationService: Notificación de fallback mostrada',
                );
              } catch (e, stackTrace) {
                _logger.e(
                  'LactationNotificationService: Error mostrando notificación de fallback',
                  e,
                  stackTrace,
                );
              }

              // Limpiar estado
              _currentNotificationId = null;
              _currentScheduledTime = null;
            } else {
              // La notificación ya no está pendiente, probablemente se disparó
              _logger.success(
                'LactationNotificationService: Notificación ya no está pendiente (probablemente se disparó)',
              );
              timer.cancel();
              _notificationCheckTimer = null;
              _currentNotificationId = null;
              _currentScheduledTime = null;
            }
          }
        } else if (!diff.isNegative && diff.inMinutes <= 5) {
          // Si estamos a menos de 5 minutos de la hora programada, verificar más frecuentemente
          _logger.d(
            'LactationNotificationService: Verificación periódica - ${diff.inMinutes} minutos hasta notificación',
          );
        }
      } catch (e, stackTrace) {
        _logger.e(
          'LactationNotificationService: Error en verificación periódica',
          e,
          stackTrace,
        );
      }
    });
  }

  /// Detener el timer de verificación
  void _stopNotificationCheckTimer() {
    _notificationCheckTimer?.cancel();
    _notificationCheckTimer = null;
    _currentNotificationId = null;
    _currentScheduledTime = null;
  }
}
