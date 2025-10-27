import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_handler.dart';
import 'lactation_service.dart';

/// Servicio para manejar notificaciones de recordatorio de sueño
class SleepNotificationService {
  static final SleepNotificationService _instance =
      SleepNotificationService._internal();
  factory SleepNotificationService() => _instance;
  SleepNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

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
    print('🔔 SleepNotificationService: Servicio inicializado');
  }

  /// Configurar notificaciones periódicas de sueño
  Future<void> scheduleSleepReminders({
    required List<int> reminderHours,
    required String babyName,
  }) async {
    await initialize();

    // Cancelar notificaciones existentes
    await cancelAllSleepReminders();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sleep_reminder_hours',
      reminderHours.map((h) => h.toString()).toList(),
    );

    for (int hour in reminderHours) {
      await _scheduleDailyReminder(hour: hour, babyName: babyName);
    }

    print(
      '🔔 SleepNotificationService: Recordatorios programados para las horas: $reminderHours',
    );
  }

  /// Programar notificaciones cada minuto (para pruebas)
  Future<void> scheduleMinuteReminders({String babyName = 'tu bebé'}) async {
    await initialize();

    // Cancelar notificaciones existentes
    await cancelAllSleepReminders();

    print(
      '🔔 SleepNotificationService: Programando notificaciones cada 2 minutos...',
    );

    // Programar notificaciones cada 2 minutos por los próximos 20 minutos
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < 10; i++) {
      final scheduledTime = now.add(Duration(minutes: (i + 1) * 2));

      print(
        '🔔 DEBUG: Programando notificación ${i + 1} para ${scheduledTime}',
      );

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'sleep_reminders_test',
            'Recordatorios de Sueño (Prueba)',
            channelDescription: 'Notificaciones de prueba cada minuto',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF03A696),
            ledColor: const Color(0xFF03A696),
            ledOnMs: 1000,
            ledOffMs: 500,
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

      try {
        // Intentar con modo exacto primero
        await _notifications.zonedSchedule(
          1000 + i, // ID único para cada notificación
          '💤 Recordatorio de Sueño (${i + 1})',
          'Es hora de registrar las horas de sueño de $babyName - Notificación ${i + 1}',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'sleep_reminder_test_${i + 1}',
        );
        print(
          '✅ DEBUG: Notificación ${i + 1} programada exitosamente (modo exacto)',
        );
      } catch (e) {
        print('❌ DEBUG: Error con modo exacto, intentando modo inexacto: $e');
        try {
          // Si falla el modo exacto, usar modo inexacto
          await _notifications.zonedSchedule(
            1000 + i,
            '💤 Recordatorio de Sueño (${i + 1})',
            'Es hora de registrar las horas de sueño de $babyName - Notificación ${i + 1}',
            scheduledTime,
            details,
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'sleep_reminder_test_${i + 1}',
          );
          print(
            '✅ DEBUG: Notificación ${i + 1} programada exitosamente (modo inexacto)',
          );
        } catch (e2) {
          print('❌ DEBUG: Error programando notificación ${i + 1}: $e2');
        }
      }
    }

    print(
      '🔔 SleepNotificationService: 10 notificaciones programadas cada 2 minutos',
    );
  }

  /// Programar una notificación inmediata para pruebas
  Future<void> scheduleImmediateTestNotification() async {
    await initialize();

    print('🔔 DEBUG: Programando notificación inmediata de prueba...');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sleep_reminders_test',
          'Recordatorios de Sueño (Prueba)',
          channelDescription: 'Notificaciones de prueba',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF03A696),
          ledColor: const Color(0xFF03A696),
          ledOnMs: 1000,
          ledOffMs: 500,
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

    try {
      await _notifications.show(
        9999, // ID único para notificación inmediata
        '🔔 Notificación de Prueba',
        'Esta es una notificación inmediata para verificar que el sistema funciona',
        details,
        payload: 'immediate_test',
      );
      print('✅ DEBUG: Notificación inmediata programada exitosamente');
    } catch (e) {
      print('❌ DEBUG: Error programando notificación inmediata: $e');
    }
  }

  /// Programar recordatorio diario
  Future<void> _scheduleDailyReminder({
    required int hour,
    required String babyName,
  }) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'sleep_reminders',
      'Recordatorios de Sueño',
      channelDescription:
          'Notificaciones para recordar registrar las horas de sueño del bebé',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF03A696),
      ledColor: const Color(0xFF03A696),
      ledOnMs: 1000,
      ledOffMs: 500,
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

    // Programar para hoy y todos los días siguientes
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      hour, // Usar la hora como ID único
      '💤 Recordatorio de Sueño',
      'Es hora de registrar las horas de sueño de $babyName',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancelar todos los recordatorios de sueño
  Future<void> cancelAllSleepReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderHours = prefs.getStringList('sleep_reminder_hours') ?? [];

    for (String hourStr in reminderHours) {
      final hour = int.tryParse(hourStr);
      if (hour != null) {
        await _notifications.cancel(hour);
      }
    }

    await prefs.remove('sleep_reminder_hours');
    print('🔔 SleepNotificationService: Todos los recordatorios cancelados');
  }

  /// Mostrar notificación inmediata de prueba
  Future<void> showTestNotification() async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sleep_test',
          'Prueba de Recordatorio',
          channelDescription:
              'Notificación de prueba para recordatorios de sueño',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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

    await _notifications.show(
      999, // ID único para notificación de prueba
      '💤 Prueba de Recordatorio',
      'Esta es una notificación de prueba para el registro de sueño',
      details,
    );
  }

  /// Obtener horas de recordatorio configuradas
  Future<List<int>> getReminderHours() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderHours = prefs.getStringList('sleep_reminder_hours') ?? [];
    return reminderHours
        .map((h) => int.tryParse(h) ?? 0)
        .where((h) => h > 0)
        .toList();
  }

  /// Verificar si hay recordatorios configurados
  Future<bool> hasRemindersConfigured() async {
    final hours = await getReminderHours();
    return hours.isNotEmpty;
  }

  /// Actualizar nombre del bebé en las notificaciones
  Future<void> updateBabyName(String babyName) async {
    final hours = await getReminderHours();
    if (hours.isNotEmpty) {
      await scheduleSleepReminders(reminderHours: hours, babyName: babyName);
    }
  }

  /// Programar notificación diaria a las 8 AM para registro de sueño
  /// Solo se programa si el usuario es postparto
  Future<void> scheduleDailySleepNotification() async {
    await initialize();

    // Verificar si el usuario es postparto antes de programar
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print(
          '⚠️ SleepNotificationService: Usuario no autenticado, no se programará notificación',
        );
        return;
      }

      // Verificar situación postparto usando LactationService
      final lactationService = LactationService(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      );

      final isPostpartum = await lactationService.hasPostpartumSituation();

      if (!isPostpartum) {
        print(
          '⚠️ SleepNotificationService: Usuario no es postparto, no se programará notificación',
        );
        return;
      }

      print(
        '✅ SleepNotificationService: Usuario es postparto, programando notificación',
      );
    } catch (e) {
      print('⚠️ SleepNotificationService: Error verificando situación: $e');
      return;
    }

    // 🔔 Verificar permisos de notificación
    final bool? granted = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (granted != true) {
      print(
        '❌ SleepNotificationService: Permisos de notificación NO concedidos',
      );
      print('⚠️ No se programará la notificación sin permisos');
      return;
    } else {
      print('✅ SleepNotificationService: Permisos de notificación concedidos');
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_sleep_reminder',
          'Registro de Sueño Diario',
          channelDescription:
              'Notificación diaria para registrar las horas de sueño del bebé',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF03A696),
          ledColor: const Color(0xFF03A696),
          ledOnMs: 1000,
          ledOffMs: 500,
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

    final now = tz.TZDateTime.now(tz.local);

    // Programar para las 8 AM todos los días
    final horaDeseada = 8; // 8 AM
    final minutosDeseados = 0; // en punto

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      horaDeseada,
      minutosDeseados,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print(
      '🔔 SleepNotificationService: Programando notificación diaria a las 8:00 AM',
    );

    // 🧪 PRUEBA: Mantener notificación inmediata de prueba
    print('🧪 Enviando notificación INMEDIATA de prueba...');
    await _notifications.show(
      888, // ID de prueba
      '🌙 Registro de Sueño Diario',
      '¿Cuántas horas durmió el bebé anoche?',
      details,
      payload: 'daily_sleep_registration',
    );
    print('✅ Notificación inmediata enviada (presiona para ir al formulario)');

    // Programar la notificación diaria de las 8 AM
    await _notifications.zonedSchedule(
      889, // ID diferente para no sobrescribir la inmediata
      '🌙 Registro de Sueño Diario',
      '¿Cuántas horas durmió el bebé anoche?',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_sleep_registration',
    );
    print('✅ Notificación diaria programada para las 8:00 AM');

    // ✅ Verificar notificaciones pendientes después de programar
    final pendingNotifications = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.pendingNotificationRequests();

    print(
      '📋 Total de notificaciones pendientes: ${pendingNotifications?.length ?? 0}',
    );
    pendingNotifications?.forEach((notification) {
      print('  📱 ID: ${notification.id}, Título: "${notification.title}"');
      if (notification.body != null) {
        print('     💬 Cuerpo: "${notification.body}"');
      }
    });
  }

  /// Cancelar la notificación diaria de las 8 AM
  Future<void> cancelDailySleepNotification() async {
    await _notifications.cancel(888);
    print(
      '🔔 SleepNotificationService: Notificación diaria de las 8 AM cancelada',
    );
  }
}
