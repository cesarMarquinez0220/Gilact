import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../../main.dart';
import '../../../lessons/presentation/pages/lesson_videos_page.dart';
import '../../presentation/pages/lactation_flow_page_enhanced.dart';
import '../../presentation/pages/lactation_record_page.dart';
import '../../presentation/pages/daily_sleep_form_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/services/pending_notification_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

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
  final ConnectivityService _connectivityService = ConnectivityService();
  final AppLogger _logger = getIt<AppLogger>();
  bool _isLocalNotificationsInitialized = false;

  /// Inicializar el servicio de notificaciones push
  Future<void> initialize() async {
    try {
      _logger.d('PushNotificationService: Inicializando...');

      // Solicitar permisos
      await _requestPermission();

      // Obtener token del dispositivo (solo si hay conexión)
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        await _saveTokenToFirestore();
      } else {
        _logger.d(
          'PushNotificationService: Sin conexión, token se guardará cuando haya conexión',
        );
      }

      // Escuchar cambios en el token
      _messaging.onTokenRefresh.listen((newToken) async {
        _logger.d('PushNotificationService: Token actualizado: $newToken');
        // Verificar conectividad antes de guardar
        final connected = await _connectivityService.isConnected();
        if (connected) {
          await _saveTokenToFirestore();
        }
      });

      // Configurar handlers para diferentes estados de la app
      _setupMessageHandlers();

      // Configurar listener para toques en notificaciones locales
      _setupLocalNotificationHandlers();

      _logger.success('PushNotificationService: Inicializado correctamente');
    } catch (e, stackTrace) {
      // No bloquear el inicio de la app si falla la inicialización
      _logger.w(
        'PushNotificationService: Error en inicialización (no crítico)',
        e,
        stackTrace,
      );
    }
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
          _logger.d('PushNotificationService: Notificación local tocada');
          _logger.d('Payload: ${response.payload}');

          if (response.payload != null) {
            final type = response.payload!;
            _logger.d(
              'PushNotificationService: Tipo de notificación local: $type',
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
                _logger.w('PushNotificationService: Tipo desconocido: $type');
            }
          }
        },
      );
      _isLocalNotificationsInitialized = true;
    }
  }

  /// Solicitar permisos para notificaciones
  Future<void> _requestPermission() async {
    _logger.d('PushNotificationService: Solicitando permisos...');

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.success('PushNotificationService: Permisos concedidos');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      _logger.w('PushNotificationService: Permisos provisionales');
    } else {
      _logger.e('PushNotificationService: Permisos denegados');
    }
  }

  /// Obtiene el ID del documento del usuario en Firestore
  /// Usa la misma lógica que VideoProgressService y VideoInteractionService
  Future<String?> _getUserDocumentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.e('PushNotificationService: Usuario no autenticado');
        return null;
      }

      // PRIORIDAD 1: Buscar por email (el ID del documento del usuario)
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          _logger.success(
            'PushNotificationService: Usuario encontrado por email, ID del documento: $userDocId',
          );
          return userDocId;
        } else {
          _logger.w(
            'PushNotificationService: No se encontró usuario por email: ${user.email}',
          );
        }
      } else {
        _logger.w('PushNotificationService: Usuario no tiene email');
      }

      // PRIORIDAD 2: Intentar con UID solo si no se encontró por email
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        _logger.w(
          'PushNotificationService: Usando UID como fallback (no recomendado): ${user.uid}',
        );
        return user.uid;
      }

      _logger.e('PushNotificationService: No se encontró usuario en Firestore');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo ID del usuario', e, stackTrace);
      return null;
    }
  }

  /// Guardar el token FCM en Firestore
  Future<void> _saveTokenToFirestore() async {
    // Verificar conectividad primero
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      _logger.d(
        'PushNotificationService: Sin conexión, no se puede guardar token',
      );
      return;
    }

    // Obtener el ID correcto del documento del usuario en Firestore
    final userDocId = await _getUserDocumentId();
    if (userDocId == null) {
      _logger.e(
        'PushNotificationService: No se pudo obtener el ID del documento del usuario',
      );
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        _logger.w('PushNotificationService: No se pudo obtener token');
        return;
      }

      _logger.d(
        'PushNotificationService: Guardando token en Firestore para usuario: $userDocId',
      );

      // Guardar el token en la colección del usuario usando el ID correcto del documento
      await _firestore
          .collection('Users')
          .doc(
            userDocId,
          ) // Usar el ID correcto del documento, no el UID de Firebase Auth
          .collection('device_tokens')
          .doc(token)
          .set({
            'token': token,
            'platform': 'android', // o 'ios'
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      _logger.success(
        'PushNotificationService: Token guardado en /Users/$userDocId/device_tokens/$token',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'PushNotificationService: Error guardando token',
        e,
        stackTrace,
      );
    }
  }

  /// Configurar handlers para mensajes
  void _setupMessageHandlers() {
    // Cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.d('PushNotificationService: Mensaje recibido en foreground');
      _logger.d('Título: ${message.notification?.title}');
      _logger.d('Cuerpo: ${message.notification?.body}');
      _logger.d('Data: ${message.data}');

      // MOSTRAR NOTIFICACIÓN VISUALMENTE
      try {
        _logger.d('DEBUG: Llamando a _showLocalNotificationFromPush...');
        await _showLocalNotificationFromPush(message);
      } catch (e, stackTrace) {
        _logger.e(
          'DEBUG: Error llamando a _showLocalNotificationFromPush',
          e,
          stackTrace,
        );
      }
    });

    // Cuando la app está en BACKGROUND y se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.d('PushNotificationService: Mensaje abierto desde background');

      // Verificar si el usuario está autenticado
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Usuario no autenticado: guardar notificación pendiente
        final data = message.data;
        final type = data['type'] as String?;
        if (type != null) {
          _logger.d(
            'PushNotificationService: Guardando notificación pendiente (background): $type',
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
        _logger.d('PushNotificationService: App abierta desde notificación');

        // Verificar si el usuario está autenticado
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Usuario no autenticado: guardar notificación pendiente
          final data = message.data;
          final type = data['type'] as String?;
          if (type != null) {
            _logger.d(
              'PushNotificationService: Guardando notificación pendiente: $type',
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

    _logger.d('PushNotificationService: Tipo de notificación: $type');

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
        _logger.w('PushNotificationService: Tipo de notificación desconocido');
    }
  }

  void _navigateToLessons() {
    _logger.d('PushNotificationService: Navegando a lecciones...');

    final context = navigatorKey.currentContext;
    if (context == null) {
      _logger.e(
        'PushNotificationService: Context no disponible para navegación',
      );
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _logger.w(
        'PushNotificationService: Usuario no autenticado, redirigiendo a login...',
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

    _logger.d(
      'PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    // Pasar lista vacía de videos porque se cargan en initState del LessonVideosPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const LessonVideosPage(videos: [], fromNotification: true),
      ),
    );

    _logger.success(
      'PushNotificationService: Navegación a lecciones completada',
    );
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
    _logger.d(
      'PushNotificationService: Navegando a registro rápido de lactancia...',
    );

    final context = navigatorKey.currentContext;
    if (context == null) {
      _logger.e(
        'PushNotificationService: Context no disponible para navegación',
      );
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _logger.w(
        'PushNotificationService: Usuario no autenticado, redirigiendo a login...',
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

    _logger.d(
      'PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LactationFlowPage()));

    _logger.success(
      'PushNotificationService: Navegación a registro rápido completada',
    );
  }

  void _navigateToLactationComplete() {
    _logger.d(
      'PushNotificationService: Navegando a registro completo de lactancia...',
    );

    final context = navigatorKey.currentContext;
    if (context == null) {
      _logger.e(
        'PushNotificationService: Context no disponible para navegación',
      );
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _logger.w(
        'PushNotificationService: Usuario no autenticado, redirigiendo a login...',
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

    _logger.d(
      'PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LactationRecordPage()));

    _logger.success(
      'PushNotificationService: Navegación a registro completo completada',
    );
  }

  void _navigateToDailySleep() {
    _logger.d('PushNotificationService: Navegando a registro de sueño...');

    final context = navigatorKey.currentContext;
    if (context == null) {
      _logger.e(
        'PushNotificationService: Context no disponible para navegación',
      );
      return;
    }

    // Verificar autenticación antes de navegar
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _logger.w(
        'PushNotificationService: Usuario no autenticado, redirigiendo a login...',
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

    _logger.d(
      'PushNotificationService: Usuario autenticado (${currentUser.uid})',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DailySleepFormPage(cameFromNotification: true),
      ),
    );

    _logger.success(
      'PushNotificationService: Navegación a registro de sueño completada',
    );
  }

  /// Suscribir a un tema (opcional)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.success('PushNotificationService: Suscrito al tema: $topic');
    } catch (e, stackTrace) {
      _logger.e(
        'PushNotificationService: Error suscribiendo al tema',
        e,
        stackTrace,
      );
    }
  }

  /// Desuscribir de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.success('PushNotificationService: Desuscrito del tema: $topic');
    } catch (e, stackTrace) {
      _logger.e(
        'PushNotificationService: Error desuscribiendo del tema',
        e,
        stackTrace,
      );
    }
  }

  /// Manejar notificación pendiente después del login
  /// Este método debe ser llamado después de que el usuario inicia sesión
  static Future<void> handlePendingNotification(BuildContext? context) async {
    final logger = getIt<AppLogger>();
    logger.d('PushNotificationService: Verificando notificación pendiente...');

    final pendingNotification =
        await PendingNotificationService.getPendingNotification();
    if (pendingNotification == null) {
      logger.d('PushNotificationService: No hay notificación pendiente');
      return;
    }

    final type = pendingNotification['type'] as String?;
    if (type == null) {
      logger.w(
        'PushNotificationService: Tipo de notificación pendiente no válido',
      );
      await PendingNotificationService.clearPendingNotification();
      return;
    }

    logger.success(
      'PushNotificationService: Notificación pendiente encontrada: $type',
    );

    // Limpiar la notificación pendiente
    await PendingNotificationService.clearPendingNotification();

    // Navegar según el tipo de notificación
    if (context == null) {
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext == null) {
        logger.e('PushNotificationService: Context no disponible para navegar');
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
        logger.w(
          'PushNotificationService: Tipo de notificación pendiente desconocido: $type',
        );
    }
  }

  /// Mostrar notificación localmente cuando la app está en foreground
  Future<void> _showLocalNotificationFromPush(RemoteMessage message) async {
    _logger.d('PushNotificationService: Mostrando notificación local...');

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

      _logger.success('PushNotificationService: Notificación local mostrada');
    } catch (e, stackTrace) {
      _logger.e(
        'PushNotificationService: Error mostrando notificación local',
        e,
        stackTrace,
      );
    }
  }
}

/// Logger estático para usar en el background handler
/// (no podemos usar DI en isolates separados)
final _backgroundLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

/// Handler global para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // En background handler, no podemos usar DI, así que creamos una instancia del logger directamente
  // ya que este handler se ejecuta en un isolate separado
  _backgroundLogger.d('Background: Mensaje recibido en background');
  _backgroundLogger.d('Título: ${message.notification?.title}');
  _backgroundLogger.d('Cuerpo: ${message.notification?.body}');
  _backgroundLogger.d('Data: ${message.data}');
}
