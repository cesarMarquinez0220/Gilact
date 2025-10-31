import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../lessons/presentation/pages/lesson_videos_page.dart';
import '../../presentation/pages/lactation_flow_page_enhanced.dart';
import '../../presentation/pages/lactation_record_page.dart';
import '../../presentation/pages/daily_sleep_form_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/services/pending_notification_service.dart';

/// Servicio para manejar notificaciones push desde Firestore
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isLocalNotificationsInitialized = false;

  /// Inicializar el servicio de notificaciones push
  Future<void> initialize() async {
    print('🔔 PushNotificationService: Inicializando...');

    // Solicitar permisos
    await _requestPermission();

    // Obtener token del dispositivo
    await _saveTokenToFirestore();

    // Escuchar cambios en el token
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔔 PushNotificationService: Token actualizado: $newToken');
      _saveTokenToFirestore();
    });

    // Configurar handlers para diferentes estados de la app
    _setupMessageHandlers();

    // Configurar listener para toques en notificaciones locales
    _setupLocalNotificationHandlers();

    print('✅ PushNotificationService: Inicializado correctamente');
  }

  /// Configurar handlers para notificaciones locales
  void _setupLocalNotificationHandlers() {
    if (!_isLocalNotificationsInitialized) {
      _localNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('🔔 PushNotificationService: Notificación local tocada');
          print('📦 Payload: ${response.payload}');

          if (response.payload != null) {
            final type = response.payload!;
            print(
              '🎯 PushNotificationService: Tipo de notificación local: $type',
            );

            // Navegar según el tipo
            switch (type) {
              case 'lesson':
                _navigateToLessons();
                break;
              case 'lactation_quick':
                _navigateToLactationQuick();
                break;
              case 'lactation_complete':
                _navigateToLactationComplete();
                break;
              case 'daily_sleep_registration':
                _navigateToDailySleep();
                break;
              default:
                print('⚠️ PushNotificationService: Tipo desconocido: $type');
            }
          }
        },
      );
      _isLocalNotificationsInitialized = true;
    }
  }

  /// Solicitar permisos para notificaciones
  Future<void> _requestPermission() async {
    print('🔔 PushNotificationService: Solicitando permisos...');

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ PushNotificationService: Permisos concedidos');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ PushNotificationService: Permisos provisionales');
    } else {
      print('❌ PushNotificationService: Permisos denegados');
    }
  }

  /// Guardar el token FCM en Firestore
  Future<void> _saveTokenToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('⚠️ PushNotificationService: No hay usuario autenticado');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        print('⚠️ PushNotificationService: No se pudo obtener token');
        return;
      }

      print('🔔 PushNotificationService: Guardando token en Firestore...');

      // Guardar el token en la colección del usuario
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('device_tokens')
          .doc(token)
          .set({
            'token': token,
            'platform': 'android', // o 'ios'
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      print('✅ PushNotificationService: Token guardado: $token');
    } catch (e) {
      print('❌ PushNotificationService: Error guardando token: $e');
    }
  }

  /// Configurar handlers para mensajes
  void _setupMessageHandlers() {
    // Cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('🔔 PushNotificationService: Mensaje recibido en foreground');
      print('📋 Título: ${message.notification?.title}');
      print('💬 Cuerpo: ${message.notification?.body}');
      print('📦 Data: ${message.data}');

      // MOSTRAR NOTIFICACIÓN VISUALMENTE
      try {
        print('🔍 DEBUG: Llamando a _showLocalNotificationFromPush...');
        await _showLocalNotificationFromPush(message);
      } catch (e) {
        print('❌ DEBUG: Error llamando a _showLocalNotificationFromPush: $e');
      }
    });

    // Cuando la app está en BACKGROUND y se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 PushNotificationService: Mensaje abierto desde background');

      // Verificar si el usuario está autenticado
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Usuario no autenticado: guardar notificación pendiente
        final data = message.data;
        final type = data['type'] as String?;
        if (type != null) {
          print(
            '💾 PushNotificationService: Guardando notificación pendiente (background): $type',
          );
          PendingNotificationService.savePendingNotification(
            type: type,
            data: data,
          );
        }
      } else {
        // Usuario autenticado: manejar directamente
        _handleMessage(message);
      }
    });

    // Verificar si la app se abrió desde una notificación
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        print('🔔 PushNotificationService: App abierta desde notificación');

        // Verificar si el usuario está autenticado
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Usuario no autenticado: guardar notificación pendiente
          final data = message.data;
          final type = data['type'] as String?;
          if (type != null) {
            print(
              '💾 PushNotificationService: Guardando notificación pendiente: $type',
            );
            PendingNotificationService.savePendingNotification(
              type: type,
              data: data,
            );
          }
        } else {
          // Usuario autenticado: manejar directamente
          _handleMessage(message);
        }
      }
    });
  }

  /// Manejar diferentes tipos de mensajes
  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    print('🔔 PushNotificationService: Tipo de notificación: $type');

    switch (type) {
      case 'lesson':
        _navigateToLessons();
        break;
      case 'lactation_quick':
        _navigateToLactationQuick();
        break;
      case 'lactation_complete':
        _navigateToLactationComplete();
        break;
      case 'daily_sleep_registration':
        _navigateToDailySleep();
        break;
      default:
        print('⚠️ PushNotificationService: Tipo de notificación desconocido');
    }
  }

  void _navigateToLessons() {
    print('📚 PushNotificationService: Navegando a lecciones...');

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ PushNotificationService: Context no disponible para navegación');
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
        '⚠️ PushNotificationService: Usuario no autenticado, redirigiendo a login...',
      );
      // Guardar notificación pendiente para reanudar después del login
      PendingNotificationService.savePendingNotification(
        type: 'lesson',
        data: const {},
      );
      _showLoginRequiredDialog(
        context,
        message: 'Por favor, inicia sesión para acceder a las lecciones.',
      );
      return;
    }

    print(
      '✅ PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    // Pasar lista vacía de videos porque se cargan en initState del LessonVideosPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LessonVideosPage(videos: const [], fromNotification: true),
      ),
    );

    print('✅ PushNotificationService: Navegación a lecciones completada');
  }

  /// Mostrar diálogo cuando se requiere inicio de sesión
  void _showLoginRequiredDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Inicio de sesión requerido'),
          content: Text(
            message ??
                'Por favor, inicia sesión para acceder a esta funcionalidad.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navegar al login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLactationQuick() {
    print(
      '🚀 PushNotificationService: Navegando a registro rápido de lactancia...',
    );

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ PushNotificationService: Context no disponible para navegación');
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
        '⚠️ PushNotificationService: Usuario no autenticado, redirigiendo a login...',
      );
      // Guardar notificación pendiente para reanudar después del login
      PendingNotificationService.savePendingNotification(
        type: 'lactation_quick',
        data: const {},
      );
      _showLoginRequiredDialog(
        context,
        message: 'Por favor, inicia sesión para acceder a las lecciones.',
      );
      return;
    }

    print(
      '✅ PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LactationFlowPage()));

    print('✅ PushNotificationService: Navegación a registro rápido completada');
  }

  void _navigateToLactationComplete() {
    print(
      '📝 PushNotificationService: Navegando a registro completo de lactancia...',
    );

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ PushNotificationService: Context no disponible para navegación');
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
        '⚠️ PushNotificationService: Usuario no autenticado, redirigiendo a login...',
      );
      // Guardar notificación pendiente para reanudar después del login
      PendingNotificationService.savePendingNotification(
        type: 'lactation_complete',
        data: const {},
      );
      _showLoginRequiredDialog(
        context,
        message: 'Por favor, inicia sesión para acceder a las lecciones.',
      );
      return;
    }

    print(
      '✅ PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LactationRecordPage()));

    print(
      '✅ PushNotificationService: Navegación a registro completo completada',
    );
  }

  void _navigateToDailySleep() {
    print('😴 PushNotificationService: Navegando a registro de sueño...');

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ PushNotificationService: Context no disponible para navegación');
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
        '⚠️ PushNotificationService: Usuario no autenticado, redirigiendo a login...',
      );
      // Guardar notificación pendiente para reanudar después del login
      PendingNotificationService.savePendingNotification(
        type: 'daily_sleep_registration',
        data: const {},
      );
      _showLoginRequiredDialog(
        context,
        message: 'Por favor, inicia sesión para acceder a esta funcionalidad.',
      );
      return;
    }

    print(
      '✅ PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DailySleepFormPage(cameFromNotification: true),
      ),
    );

    print(
      '✅ PushNotificationService: Navegación a registro de sueño completada',
    );
  }

  /// Suscribir a un tema (opcional)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ PushNotificationService: Suscrito al tema: $topic');
    } catch (e) {
      print('❌ PushNotificationService: Error suscribiendo al tema: $e');
    }
  }

  /// Desuscribir de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ PushNotificationService: Desuscrito del tema: $topic');
    } catch (e) {
      print('❌ PushNotificationService: Error desuscribiendo del tema: $e');
    }
  }

  /// Manejar notificación pendiente después del login
  /// Este método debe ser llamado después de que el usuario inicia sesión
  static Future<void> handlePendingNotification(BuildContext? context) async {
    print('🔍 PushNotificationService: Verificando notificación pendiente...');

    final pendingNotification =
        await PendingNotificationService.getPendingNotification();
    if (pendingNotification == null) {
      print('ℹ️ PushNotificationService: No hay notificación pendiente');
      return;
    }

    final type = pendingNotification['type'] as String?;
    if (type == null) {
      print(
        '⚠️ PushNotificationService: Tipo de notificación pendiente no válido',
      );
      await PendingNotificationService.clearPendingNotification();
      return;
    }

    print(
      '✅ PushNotificationService: Notificación pendiente encontrada: $type',
    );

    // Limpiar la notificación pendiente
    await PendingNotificationService.clearPendingNotification();

    // Navegar según el tipo de notificación
    if (context == null) {
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext == null) {
        print('❌ PushNotificationService: Context no disponible para navegar');
        return;
      }
      context = navigatorContext;
    }

    // Esperar un poco para asegurar que la navegación esté lista
    await Future.delayed(const Duration(milliseconds: 500));

    final service = PushNotificationService();
    switch (type) {
      case 'lesson':
        service._navigateToLessons();
        break;
      case 'lactation_quick':
        service._navigateToLactationQuick();
        break;
      case 'lactation_complete':
        service._navigateToLactationComplete();
        break;
      case 'daily_sleep_registration':
        service._navigateToDailySleep();
        break;
      default:
        print(
          '⚠️ PushNotificationService: Tipo de notificación pendiente desconocido: $type',
        );
    }
  }

  /// Mostrar notificación localmente cuando la app está en foreground
  Future<void> _showLocalNotificationFromPush(RemoteMessage message) async {
    print('🔔 PushNotificationService: Mostrando notificación local...');

    try {
      // Crear el canal de notificación para Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'push_notifications', // ID
        'Push Notificaciones', // Nombre visible
        description: 'Notificaciones push de la aplicación',
        importance: Importance.high,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Mostrar la notificación
      await _localNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'push_notifications',
            'Push Notificaciones',
            channelDescription: 'Notificaciones push de la aplicación',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['type'],
      );

      print('✅ PushNotificationService: Notificación local mostrada');
    } catch (e) {
      print(
        '❌ PushNotificationService: Error mostrando notificación local: $e',
      );
    }
  }
}

/// Handler global para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background: Mensaje recibido en background');
  print('📋 Título: ${message.notification?.title}');
  print('💬 Cuerpo: ${message.notification?.body}');
  print('📦 Data: ${message.data}');
}
