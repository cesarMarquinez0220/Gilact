import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Timer para verificar periódicamente si la notificación debería haberse disparado
  Timer? _notificationCheckTimer;

  // MethodChannel para verificar permisos de alarmas exactas
  static const MethodChannel _notificationChannel = MethodChannel(
    'notification_permissions',
  );

  // MethodChannel para programar alarmas nativas (funciona incluso con app cerrada)
  static const MethodChannel _nativeAlarmChannel = MethodChannel(
    'native_alarm_scheduler',
  );

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

    // Crear canal de notificación explícitamente para Android
    await _createNotificationChannel();

    _isInitialized = true;
    print('🔔 SleepNotificationService: Servicio inicializado');
  }

  /// Crear canal de notificación para Android
  Future<void> _createNotificationChannel() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'daily_sleep_reminder', // id
        'Registro de Sueño Diario', // name
        description:
            'Notificación diaria para registrar las horas de sueño del bebé',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(channel);
      print('✅ SleepNotificationService: Canal de notificación creado');
    }
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
  /// [skipTestNotification] si es true, no envía la notificación de prueba inmediata
  Future<void> scheduleDailySleepNotification({
    bool skipTestNotification = false,
  }) async {
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
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Verificar permiso de alarmas exactas (Android 12+) - declarar fuera del if para que esté disponible
    bool canScheduleExactAlarms = true;

    if (androidImplementation != null) {
      // Solicitar permiso de notificaciones
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();

      if (granted != true) {
        print(
          '❌ SleepNotificationService: Permisos de notificación NO concedidos',
        );
        print('⚠️ No se programará la notificación sin permisos');
        return;
      } else {
        print(
          '✅ SleepNotificationService: Permisos de notificación concedidos',
        );
      }

      // Verificar permiso de alarmas exactas (Android 12+)
      try {
        final result = await _notificationChannel.invokeMethod<bool>(
          'canScheduleExactAlarms',
        );
        canScheduleExactAlarms = result ?? false;
      } catch (e) {
        print(
          '⚠️ SleepNotificationService: No se pudo verificar permiso de alarmas exactas: $e',
        );
        // Asumir que no está concedido si no se puede verificar
        canScheduleExactAlarms = false;
      }

      print(
        'ℹ️ SleepNotificationService: Notificaciones habilitadas: ${await androidImplementation.areNotificationsEnabled()}',
      );
      print(
        'ℹ️ SleepNotificationService: Permiso de alarmas exactas: ${canScheduleExactAlarms ? "✅ Concedido" : "❌ NO concedido"}',
      );

      if (!canScheduleExactAlarms) {
        print(
          '⚠️ ADVERTENCIA: El permiso de alarmas exactas NO está concedido.',
        );
        print(
          '   Esto significa que las notificaciones programadas pueden no dispararse a tiempo.',
        );
        print('   Para solucionarlo:');
        print('   1. Ve a Configuración → Aplicaciones → Gilact → Permisos');
        print('   2. Activa "Alarmas y recordatorios"');
        print(
          '   3. O ve a Configuración → Aplicaciones → Gilact → Batería → No optimizar',
        );
      }

      // Asegurar que el canal esté creado
      await _createNotificationChannel();
    }

    final now = tz.TZDateTime.now(tz.local);

    // Programar para las 8:00 AM todos los días
    final horaDeseada = 8;
    final minutosDeseados = 0;

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

    // Crear detalles de notificación con la fecha programada
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_sleep_reminder', // Debe coincidir con el ID del canal
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
          enableVibration: true,
          playSound: true,
          showWhen: true,
          when: scheduledDate.millisecondsSinceEpoch,
          // Asegurar que se muestre incluso en modo "No molestar"
          category: AndroidNotificationCategory.reminder,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    print(
      '🔔 SleepNotificationService: Programando notificación para ${horaDeseada.toString().padLeft(2, '0')}:${minutosDeseados.toString().padLeft(2, '0')}',
    );
    print(
      '🔔 SleepNotificationService: Hora actual: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );
    print(
      '🔔 SleepNotificationService: Hora programada: ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
    );
    print(
      '🔔 SleepNotificationService: Tiempo hasta notificación: ${scheduledDate.difference(now).inMinutes} minutos',
    );

    // Notificación de prueba removida - ya no es necesaria

    // Programar la notificación diaria de las 8 AM
    // PRIMERO intentar con método nativo (más confiable cuando app está cerrada)
    // Si falla, usar flutter_local_notifications como fallback
    bool scheduledSuccessfully = false;

    // Intentar programar con método nativo primero
    try {
      print(
        '🔔 SleepNotificationService: Intentando programar con método NATIVO (funciona con app cerrada)...',
      );

      // Convertir la fecha programada a timestamp en milisegundos
      final timestamp = scheduledDate.millisecondsSinceEpoch;

      final result = await _nativeAlarmChannel.invokeMethod<bool>(
        'scheduleSleepNotification',
        {'timestamp': timestamp},
      );

      if (result == true) {
        print(
          '✅ SleepNotificationService: Notificación programada con método NATIVO',
        );
        scheduledSuccessfully = true;

        // Guardar información para verificación posterior
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('sleep_notification_scheduled', true);
        await prefs.setInt('sleep_notification_id', 889);
        await prefs.setString(
          'sleep_notification_scheduled_time',
          scheduledDate.toIso8601String(),
        );
        await prefs.setBool(
          'sleep_notification_native',
          true,
        ); // Marcar como nativa

        // Iniciar verificación periódica cada minuto para detectar si no se disparó
        _startNotificationCheckTimer(scheduledDate);

        // Verificar que se programó correctamente (aunque no aparezca en lista de Flutter)
        print(
          'ℹ️ SleepNotificationService: Notificación nativa programada (no aparece en lista de Flutter, es normal)',
        );
      }
    } catch (e) {
      print(
        '⚠️ SleepNotificationService: Error programando con método nativo: $e',
      );
      print('⚠️ Intentando con flutter_local_notifications como fallback...');
      scheduledSuccessfully = false;
    }

    // Si el método nativo falló, usar flutter_local_notifications como fallback
    if (!scheduledSuccessfully && canScheduleExactAlarms) {
      try {
        print(
          '🔔 SleepNotificationService: Intentando programar con modo EXACTO (fallback)...',
        );
        await _notifications.zonedSchedule(
          889, // ID para la notificación diaria de las 8 AM
          '🌙 Registro de Sueño Diario',
          '¿Cuántas horas durmió el bebé anoche?',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // 🧪 MODO PRUEBA: Comentar matchDateTimeComponents para prueba única
          // matchDateTimeComponents: DateTimeComponents.time,
          payload: 'daily_sleep_registration',
        );
        print('✅ Notificación programada (modo exacto)');
        scheduledSuccessfully = true;

        // Verificar que se programó correctamente
        final androidNotifications = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidNotifications != null) {
          final pending = await androidNotifications
              .pendingNotificationRequests();
          final ourNotificationList = pending
              .where((n) => n.id == 889)
              .toList();
          final ourNotification = ourNotificationList.isNotEmpty
              ? ourNotificationList.first
              : null;
          if (ourNotification != null) {
            print('✅ Notificación verificada en lista pendiente:');
            print('   ID: ${ourNotification.id}');
            print('   Título: ${ourNotification.title}');
            print('   Cuerpo: ${ourNotification.body}');
          } else {
            print('❌ ERROR: Notificación no encontrada en lista pendiente');
          }
        }

        // Guardar información para verificación posterior
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('sleep_notification_scheduled', true);
        await prefs.setInt('sleep_notification_id', 889);
        await prefs.setString(
          'sleep_notification_scheduled_time',
          scheduledDate.toIso8601String(),
        );

        // Iniciar verificación periódica cada minuto para detectar si no se disparó
        _startNotificationCheckTimer(scheduledDate);
      } catch (e, stackTrace) {
        print('❌ ERROR con modo exacto: $e');
        print('📋 Stack trace: $stackTrace');
        print('⚠️ Intentando con modo INEXACTO como fallback...');
        scheduledSuccessfully =
            false; // Marcar como no exitoso para intentar modo inexacto
      }
    } else {
      print(
        '⚠️ SleepNotificationService: Permiso de alarmas exactas NO concedido, usando modo INEXACTO',
      );
      print(
        '   ⚠️ ADVERTENCIA: Las notificaciones pueden tener retraso de varios minutos',
      );
      scheduledSuccessfully = false;
    }

    // Si el modo exacto falló o no está disponible, usar modo inexacto
    if (!scheduledSuccessfully) {
      try {
        await _notifications.zonedSchedule(
          889,
          '🌙 Registro de Sueño Diario',
          '¿Cuántas horas durmió el bebé anoche?',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // 🧪 MODO PRUEBA: Comentar matchDateTimeComponents para prueba única
          // matchDateTimeComponents: DateTimeComponents.time,
          payload: 'daily_sleep_registration',
        );
        print(
          '✅ Notificación programada (modo inexacto - puede tener retraso)',
        );
        scheduledSuccessfully = true;

        // Verificar que se programó correctamente
        final androidNotifications2 = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidNotifications2 != null) {
          final pending = await androidNotifications2
              .pendingNotificationRequests();
          final ourNotificationList = pending
              .where((n) => n.id == 889)
              .toList();
          final ourNotification = ourNotificationList.isNotEmpty
              ? ourNotificationList.first
              : null;
          if (ourNotification != null) {
            print(
              '✅ Notificación verificada en lista pendiente (modo inexacto):',
            );
            print('   ID: ${ourNotification.id}');
            print('   Título: ${ourNotification.title}');
            print('   Cuerpo: ${ourNotification.body}');
          } else {
            print(
              '❌ ERROR: Notificación no encontrada en lista pendiente (modo inexacto)',
            );
          }
        }

        // Guardar información para verificación posterior
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setBool('sleep_notification_scheduled', true);
        await prefs2.setInt('sleep_notification_id', 889);
        await prefs2.setString(
          'sleep_notification_scheduled_time',
          scheduledDate.toIso8601String(),
        );

        // Iniciar verificación periódica cada minuto para detectar si no se disparó
        _startNotificationCheckTimer(scheduledDate);
      } catch (e2) {
        print(
          '❌ ERROR CRÍTICO: No se pudo programar la notificación ni en modo exacto ni inexacto: $e2',
        );
        scheduledSuccessfully = false;
      }
    }

    // Verificar que se programó correctamente (solo si tuvo éxito)
    if (scheduledSuccessfully) {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidNotifications != null) {
        // Esperar un poco para que se registre
        await Future.delayed(const Duration(milliseconds: 500));

        final pending = await androidNotifications
            .pendingNotificationRequests();
        final ourNotificationList = pending.where((n) => n.id == 889).toList();
        final ourNotification = ourNotificationList.isNotEmpty
            ? ourNotificationList.first
            : null;
        if (ourNotification != null) {
          print('✅ Notificación verificada en lista pendiente:');
          print('   ID: ${ourNotification.id}');
          print('   Título: ${ourNotification.title}');
          print('   Cuerpo: ${ourNotification.body}');

          // Verificar la fecha programada
          final prefs = await SharedPreferences.getInstance();
          final savedTime = prefs.getString(
            'sleep_notification_scheduled_time',
          );
          if (savedTime != null) {
            final savedDate = DateTime.parse(savedTime);
            final now = DateTime.now();
            final diff = savedDate.difference(now);
            print('   ⏰ Fecha programada guardada: $savedTime');
            print('   ⏰ Tiempo hasta notificación: ${diff.inMinutes} minutos');

            if (diff.isNegative) {
              print('   ⚠️ ADVERTENCIA: La fecha programada ya pasó!');
            }
            // No iniciar timer aquí porque ya se inició después de programar
          }
        } else {
          print(
            '❌ ERROR: Notificación no encontrada en lista pendiente después de programar',
          );
        }
      }
    }

    // ✅ Verificar notificaciones pendientes después de programar
    final androidNotifications = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidNotifications != null) {
      final pendingNotifications = await androidNotifications
          .pendingNotificationRequests();

      print(
        '📋 Total de notificaciones pendientes: ${pendingNotifications.length}',
      );
      pendingNotifications.forEach((notification) {
        print('  📱 ID: ${notification.id}, Título: "${notification.title}"');
        if (notification.body != null) {
          print('     💬 Cuerpo: "${notification.body}"');
        }
      });

      // Verificar específicamente nuestra notificación
      final ourNotificationList = pendingNotifications
          .where((n) => n.id == 889)
          .toList();
      final ourNotification = ourNotificationList.isNotEmpty
          ? ourNotificationList.first
          : null;
      if (ourNotification != null) {
        print('✅ Nuestra notificación (ID 889) está en la lista pendiente');
      } else {
        print(
          '❌ ERROR: Nuestra notificación (ID 889) NO está en la lista pendiente',
        );
      }
    } else {
      print(
        '⚠️ No se pudo obtener el plugin de Android para verificar notificaciones',
      );
    }
  }

  /// Cancelar la notificación diaria de las 8 AM
  Future<void> cancelDailySleepNotification() async {
    // Cancelar notificación nativa si existe
    try {
      final prefs = await SharedPreferences.getInstance();
      final isNative = prefs.getBool('sleep_notification_native') ?? false;
      if (isNative) {
        await _nativeAlarmChannel.invokeMethod('cancelSleepNotification');
        await prefs.setBool('sleep_notification_native', false);
        print('🔔 SleepNotificationService: Notificación NATIVA cancelada');
      }
    } catch (e) {
      print(
        '⚠️ SleepNotificationService: Error cancelando notificación nativa: $e',
      );
    }

    // Cancelar notificación de Flutter también
    await _notifications.cancel(889);
    _stopNotificationCheckTimer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sleep_notification_scheduled', false);
    print(
      '🔔 SleepNotificationService: Notificación diaria de las 8 AM cancelada',
    );
  }

  /// Verificar si la notificación de sueño está programada
  Future<bool> isSleepNotificationScheduled() async {
    try {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotifications == null) return false;

      final pendingNotifications = await androidNotifications
          .pendingNotificationRequests();

      final isScheduled = pendingNotifications.any((n) => n.id == 889);

      if (isScheduled) {
        // Verificar también la fecha guardada
        final prefs = await SharedPreferences.getInstance();
        final savedTime = prefs.getString('sleep_notification_scheduled_time');
        if (savedTime != null) {
          final savedDate = DateTime.parse(savedTime);
          final now = DateTime.now();
          if (savedDate.isBefore(now)) {
            print(
              '⚠️ SleepNotificationService: Notificación programada pero la fecha ya pasó',
            );
            print('   Fecha programada: $savedTime');
            print('   Hora actual: ${now.toIso8601String()}');
            return false; // La notificación ya debería haberse disparado
          }
        }
      }

      return isScheduled;
    } catch (e) {
      print('❌ SleepNotificationService: Error verificando notificación: $e');
      return false;
    }
  }

  /// Verificar y reprogramar notificación si es necesario
  Future<void> verifyAndRescheduleIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getString('sleep_notification_scheduled_time');

      if (savedTime != null) {
        final savedDate = DateTime.parse(savedTime);
        final now = DateTime.now();
        final diff = savedDate.difference(now);

        // Verificar si la notificación aún está en la lista pendiente
        final androidNotifications = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        bool isStillPending = false;
        if (androidNotifications != null) {
          final pending = await androidNotifications
              .pendingNotificationRequests();
          isStillPending = pending.any((n) => n.id == 889);
        }

        // Si la fecha programada ya pasó (más de 2 minutos de diferencia)
        // Y la notificación aún está en la lista pendiente, significa que no se disparó
        if (diff.isNegative && diff.inMinutes.abs() > 2 && isStillPending) {
          print(
            '⚠️ SleepNotificationService: PROBLEMA DETECTADO - Notificación programada para ${savedDate.toIso8601String()} pero ya pasó (${diff.inMinutes.abs()} minutos)',
          );
          print(
            '⚠️ SleepNotificationService: La notificación aún está en la lista pendiente, lo que significa que NO se disparó',
          );
          print(
            '🔄 SleepNotificationService: Mostrando notificación inmediata como fallback...',
          );

          // Cancelar la notificación programada que no se disparó
          await _notifications.cancel(889);

          // Mostrar notificación inmediata como fallback
          try {
            await _notifications.show(
              889, // Mismo ID para reemplazar la programada
              '🌙 Registro de Sueño Diario',
              '¿Cuántas horas durmió el bebé anoche?',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'daily_sleep_reminder',
                  'Registro de Sueño Diario',
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                  enableVibration: true,
                  playSound: true,
                  category: AndroidNotificationCategory.reminder,
                ),
              ),
              payload: 'daily_sleep_registration',
            );
            print(
              '✅ SleepNotificationService: Notificación de fallback mostrada',
            );
          } catch (e) {
            print(
              '❌ SleepNotificationService: Error mostrando notificación de fallback: $e',
            );
          }

          // Reprogramar para mañana
          print('🔄 SleepNotificationService: Reprogramando para mañana...');
          await scheduleDailySleepNotification();
          return;
        } else if (diff.isNegative &&
            diff.inMinutes.abs() > 2 &&
            !isStillPending) {
          // La fecha pasó pero la notificación ya no está pendiente, probablemente se disparó
          print(
            '✅ SleepNotificationService: Notificación programada para ${savedDate.toIso8601String()} ya pasó y no está pendiente (probablemente se disparó)',
          );
          // Reprogramar para mañana
          print('🔄 SleepNotificationService: Reprogramando para mañana...');
          await scheduleDailySleepNotification();
          return;
        }
      }

      final isScheduled = await isSleepNotificationScheduled();
      if (!isScheduled) {
        print(
          '🔄 SleepNotificationService: Notificación no encontrada, reprogramando...',
        );
        // No mostrar notificación de prueba al reprogramar, solo programar
        await scheduleDailySleepNotification(skipTestNotification: true);
      } else {
        // Verificar que la fecha programada sea válida
        if (savedTime != null) {
          final savedDate = DateTime.parse(savedTime);
          final now = DateTime.now();
          if (savedDate.isBefore(now)) {
            print(
              '🔄 SleepNotificationService: Notificación programada pero fecha pasada, reprogramando...',
            );
            // No mostrar notificación de prueba al reprogramar, solo programar
            await scheduleDailySleepNotification(skipTestNotification: true);
          }
        }
      }
    } catch (e) {
      print(
        '❌ SleepNotificationService: Error verificando y reprogramando: $e',
      );
    }
  }

  /// Diagnosticar por qué la notificación no se disparó
  Future<void> diagnoseNotificationIssue() async {
    print(
      '🔍 SleepNotificationService: Iniciando diagnóstico de notificaciones...',
    );

    try {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidNotifications == null) {
        print('❌ No se pudo obtener el plugin de Android');
        return;
      }

      // 1. Verificar permisos de notificación
      final notificationsEnabled = await androidNotifications
          .areNotificationsEnabled();
      print(
        '📋 Permisos de notificación: ${notificationsEnabled == true ? "✅ Concedidos" : "❌ NO concedidos"}',
      );

      // 1.1. Verificar permiso de alarmas exactas (Android 12+)
      bool canScheduleExactAlarms = true;
      try {
        final result = await _notificationChannel.invokeMethod<bool>(
          'canScheduleExactAlarms',
        );
        canScheduleExactAlarms = result ?? false;
        print(
          '📋 Permiso de alarmas exactas: ${canScheduleExactAlarms ? "✅ Concedido" : "❌ NO concedido (CRÍTICO)"}',
        );
        if (!canScheduleExactAlarms) {
          print(
            '   ⚠️ Sin este permiso, las notificaciones programadas pueden no dispararse a tiempo.',
          );
          print(
            '   💡 Solución: Configuración → Aplicaciones → Gilact → Permisos → Alarmas y recordatorios',
          );
        }
      } catch (e) {
        print('⚠️ No se pudo verificar permiso de alarmas exactas: $e');
        canScheduleExactAlarms = false;
      }

      // 2. Verificar notificaciones pendientes
      final pending = await androidNotifications.pendingNotificationRequests();
      print('📋 Notificaciones pendientes: ${pending.length}');
      final ourNotificationList = pending.where((n) => n.id == 889).toList();
      final ourNotification = ourNotificationList.isNotEmpty
          ? ourNotificationList.first
          : null;

      if (ourNotification != null) {
        print('✅ Nuestra notificación (ID 889) está en la lista pendiente');
        print('   Título: ${ourNotification.title}');
        print('   Cuerpo: ${ourNotification.body}');
      } else {
        print('❌ Nuestra notificación (ID 889) NO está en la lista pendiente');
      }

      // 3. Verificar fecha programada guardada
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getString('sleep_notification_scheduled_time');
      if (savedTime != null) {
        final savedDate = DateTime.parse(savedTime);
        final now = DateTime.now();
        final diff = savedDate.difference(now);
        print('📅 Fecha programada guardada: $savedTime');
        print('📅 Hora actual: ${now.toIso8601String()}');
        print('📅 Diferencia: ${diff.inMinutes} minutos');

        if (diff.isNegative) {
          print('⚠️ PROBLEMA ENCONTRADO: La fecha programada ya pasó!');
          print(
            '   Esto significa que la notificación debería haberse disparado pero no lo hizo.',
          );

          // Verificar permiso de alarmas exactas
          bool canSchedule = true;
          try {
            final result = await _notificationChannel.invokeMethod<bool>(
              'canScheduleExactAlarms',
            );
            canSchedule = result ?? false;
          } catch (e) {
            canSchedule = false;
          }

          if (!canSchedule) {
            print(
              '   ❌ CAUSA PRINCIPAL: Permiso de alarmas exactas NO concedido',
            );
            print('   📱 Abriendo configuración de la app...');
            try {
              await _notificationChannel.invokeMethod('openAppSettings');
              print(
                '   ✅ Configuración abierta. Por favor concede el permiso "Alarmas y recordatorios"',
              );
            } catch (e) {
              print('   ⚠️ No se pudo abrir la configuración: $e');
            }
          } else {
            print('   Posibles causas:');
            print('   1. Optimización de batería bloqueando la notificación');
            print('   2. Modo "No molestar" activo');
            print('   3. App necesita estar en "No optimizar batería"');
            print('');
            print('   SOLUCIÓN:');
            print('   1. Ve a Configuración → Aplicaciones → Gilact → Batería');
            print('   2. Selecciona "No optimizar"');
          }
        } else {
          print(
            '✅ La fecha programada es futura, la notificación debería dispararse en ${diff.inMinutes} minutos',
          );
        }
      } else {
        print('⚠️ No hay fecha programada guardada');
      }

      // 4. Verificar canal de notificación
      print('📋 Verificando canal de notificación...');
      await _createNotificationChannel();
      print('✅ Canal de notificación verificado/creado');
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }
  }

  /// Iniciar timer para verificar periódicamente si la notificación debería haberse disparado
  void _startNotificationCheckTimer(tz.TZDateTime scheduledDate) {
    // Cancelar timer anterior si existe
    _notificationCheckTimer?.cancel();

    print(
      '⏰ SleepNotificationService: Iniciando verificación periódica cada minuto para notificación programada',
    );

    // Verificar cada minuto si la notificación debería haberse disparado
    _notificationCheckTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) async {
      try {
        final now = tz.TZDateTime.now(tz.local);
        final diff = scheduledDate.difference(now);

        print(
          '⏰ SleepNotificationService: Verificación periódica - Diferencia: ${diff.inMinutes} minutos (${diff.isNegative ? "PASÓ" : "FUTURO"})',
        );

        // Si la fecha programada ya pasó (0 minutos o más)
        if (diff.isNegative || diff.inMinutes == 0) {
          print(
            '⏰ SleepNotificationService: Verificación periódica - Fecha programada ya pasó o es ahora (${diff.inMinutes} minutos)',
          );

          // Verificar si la notificación aún está pendiente
          final androidNotifications = _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

          if (androidNotifications != null) {
            final pending = await androidNotifications
                .pendingNotificationRequests();
            final isStillPending = pending.any((n) => n.id == 889);

            print(
              '⏰ SleepNotificationService: Notificación aún pendiente: $isStillPending',
            );

            if (isStillPending) {
              print(
                '⚠️ SleepNotificationService: PROBLEMA DETECTADO - Notificación programada NO se disparó!',
              );
              print(
                '🔄 SleepNotificationService: Mostrando notificación inmediata como fallback...',
              );

              // Cancelar el timer ya que vamos a manejar esto
              timer.cancel();
              _notificationCheckTimer = null;

              // Cancelar la notificación programada que no se disparó
              await _notifications.cancel(889);

              // Mostrar notificación inmediata como fallback
              try {
                await _notifications.show(
                  889,
                  '🌙 Registro de Sueño Diario',
                  '¿Cuántas horas durmió el bebé anoche?',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'daily_sleep_reminder',
                      'Registro de Sueño Diario',
                      importance: Importance.high,
                      priority: Priority.high,
                      icon: '@mipmap/ic_launcher',
                      enableVibration: true,
                      playSound: true,
                      category: AndroidNotificationCategory.reminder,
                    ),
                  ),
                  payload: 'daily_sleep_registration',
                );
                print(
                  '✅ SleepNotificationService: Notificación de fallback mostrada',
                );
              } catch (e) {
                print(
                  '❌ SleepNotificationService: Error mostrando notificación de fallback: $e',
                );
              }

              // Reprogramar para mañana
              print(
                '🔄 SleepNotificationService: Reprogramando para mañana...',
              );
              await scheduleDailySleepNotification(skipTestNotification: true);
            } else {
              // La notificación ya no está pendiente, probablemente se disparó
              print(
                '✅ SleepNotificationService: Notificación ya no está pendiente (probablemente se disparó)',
              );
              timer.cancel();
              _notificationCheckTimer = null;
            }
          }
        } else if (!diff.isNegative && diff.inMinutes <= 5) {
          // Si estamos a menos de 5 minutos de la hora programada, verificar más frecuentemente
          print(
            '⏰ SleepNotificationService: Verificación periódica - ${diff.inMinutes} minutos hasta notificación',
          );
        }
      } catch (e) {
        print(
          '❌ SleepNotificationService: Error en verificación periódica: $e',
        );
      }
    });
  }

  /// Detener el timer de verificación
  void _stopNotificationCheckTimer() {
    _notificationCheckTimer?.cancel();
    _notificationCheckTimer = null;
  }
}
