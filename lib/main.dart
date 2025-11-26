import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/user/presentation/bloc/user_profile_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/lessons/presentation/pages/lessons_page.dart';
import 'features/lessons/presentation/bloc/lesson_bloc.dart';
import 'features/lessons/presentation/providers/lecciones_provider.dart';
import 'features/lessons/presentation/providers/video_images_provider.dart';
import 'features/tips/presentation/pages/tips_page.dart';
import 'features/tips/presentation/bloc/tip_bloc.dart';
import 'features/navigation/presentation/pages/main_navigation_page_refactored.dart';
import 'features/auth/presentation/pages/registration_page.dart';
import 'features/auth/presentation/pages/welcome_screen.dart';
import 'features/videos/presentation/pages/user_videos_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/situation_selection_page.dart';
import 'features/onboarding/presentation/pages/prepartum_form_page.dart';
import 'features/onboarding/presentation/pages/postpartum_form_page.dart';
import 'features/lactation/data/services/sleep_notification_service.dart';
import 'features/lactation/data/services/notification_handler.dart';
import 'features/lactation/data/services/push_notification_service.dart';
import 'features/lactation/presentation/pages/daily_sleep_form_page.dart';
import 'features/lactation/presentation/pages/baby_weight_form_page.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/app_initialization_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

//flutter_native_splash:
// color: "#03A696"
// image: "assets/images/splash.png"
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Crear logger temporal antes de configureDependencies
  late AppLogger logger;
  try {
    final prefs = await SharedPreferences.getInstance();
    logger = AppLogger(prefs);
  } catch (e) {
    // Si falla, crear uno básico sin SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    logger = AppLogger(prefs);
  }

  try {
    // Inicializar Firebase de forma segura
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    logger.success('Firebase inicializado correctamente');
  } catch (e, stackTrace) {
    logger.e('Error al inicializar Firebase', e, stackTrace);
  }

  // Comentamos temporalmente los servicios que pueden causar problemas
  // final performanceService = PerformanceService();
  // final securityService = SecurityAnalysisService();

  // await performanceService.measureAppInitialization();
  // final securityReport = await securityService.analyzeSecurity();

  await updateLastOpened();

  // Configurar inyección de dependencias
  await configureDependencies();
  
  // Usar logger de GetIt después de configureDependencies
  final appLogger = getIt<AppLogger>();

  // Inicializar servicios de notificaciones (no bloquea si falla)
  try {
    await _initializeNotificationServices();
  } catch (e, stackTrace) {
    appLogger.w('Error al inicializar servicios de notificación (no crítico)', e, stackTrace);
  }

  // Registrar handler para mensajes en background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar servicio de notificaciones push (no bloquea si falla)
  try {
    await _initializePushNotificationService();
  } catch (e, stackTrace) {
    appLogger.w('Error al inicializar servicio de push (no crítico)', e, stackTrace);
  }

  // Inicializar el manejador de notificaciones
  NotificationHandler.initialize(navigatorKey);

  // Iniciar verificación periódica de notificaciones (no bloquea si falla)
  try {
    AppInitializationService.startPeriodicNotificationVerification();
  } catch (e, stackTrace) {
    appLogger.w('Error al iniciar verificación periódica de notificaciones (no crítico)', e, stackTrace);
  }

  // Inicializar servicio de sincronización offline con callbacks (no bloquea si falla)
  try {
    final offlineSyncService = getIt<OfflineSyncService>();
    offlineSyncService.startAutoSync(
      onSyncCompleted: (int count) {
        appLogger.success('Sincronización completada: $count operaciones');
        // Mostrar notificación de sincronización completada
        _showSyncNotification(count, true);
      },
      onSyncFailed: (int count) {
        appLogger.w('Sincronización fallida: $count operaciones');
        // Mostrar notificación de error
        _showSyncNotification(count, false);
      },
    );

    appLogger.success('Servicio de sincronización offline iniciado');
  } catch (e, stackTrace) {
    appLogger.w('Error al inicializar servicio de sincronización (no crítico)', e, stackTrace);
  }

  runApp(const MyApp());
}

/// Muestra una notificación de sincronización
void _showSyncNotification(int count, bool success) {
  // Usar SchedulerBinding para asegurarnos de que estamos en el hilo principal
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      try {
        final logger = getIt<AppLogger>();
        logger.w('No se puede mostrar notificación: contexto no disponible');
      } catch (_) {
        // Si GetIt no está disponible, ignorar
      }
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? '$count operación${count > 1 ? 'es' : ''} sincronizada${count > 1 ? 's' : ''} exitosamente'
                      : '$count operación${count > 1 ? 'es' : ''} falló${count > 1 ? 'ron' : ''} al sincronizar',
                  style: GoogleFonts.quicksand(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e, stackTrace) {
      try {
        final logger = getIt<AppLogger>();
        logger.e('Error mostrando notificación de sincronización', e, stackTrace);
      } catch (_) {
        // Si GetIt no está disponible, ignorar
      }
    }
  });
}

Future<void> updateLastOpened() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  await prefs.setString('last_opened', now.toString());
}

/// Inicializar servicios de notificaciones
Future<void> _initializeNotificationServices() async {
  try {
    final notificationService = getIt<SleepNotificationService>();
    await notificationService.initialize();

    // NO programar automáticamente aquí porque el usuario aún no está autenticado
    // La notificación se programará después de que el usuario inicie sesión
    // y se verifique que es postparto (en WelcomeScreen o similar)

    final logger = getIt<AppLogger>();
    logger.success('Servicios de notificación inicializados correctamente');
  } catch (e, stackTrace) {
    try {
      final logger = getIt<AppLogger>();
      logger.e('Error al inicializar servicios de notificación', e, stackTrace);
    } catch (_) {
      // Si GetIt no está disponible, ignorar
    }
  }
}

/// Inicializar servicio de notificaciones push
Future<void> _initializePushNotificationService() async {
  try {
    final pushService = PushNotificationService();
    await pushService.initialize();

    final logger = getIt<AppLogger>();
    logger.success('Servicio de notificaciones push inicializado');
  } catch (e, stackTrace) {
    try {
      final logger = getIt<AppLogger>();
      logger.e('Error al inicializar servicio de push', e, stackTrace);
    } catch (_) {
      // Si GetIt no está disponible, ignorar
    }
  }
}

/// Clave global de navegación para el manejo de notificaciones
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeccionesProvider(), lazy: false),
        ChangeNotifierProvider(
          create: (_) => VideoImagesProvider(),
          lazy: false,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
          BlocProvider<UserProfileBloc>(
            create: (context) => getIt<UserProfileBloc>(),
          ),
          BlocProvider<TipBloc>(create: (context) => getIt<TipBloc>()),
          BlocProvider<LessonBloc>(create: (context) => getIt<LessonBloc>()),
          BlocProvider<GamificationBloc>(
            create: (context) => getIt<GamificationBloc>(),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => getIt<SettingsBloc>(),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (previous, current) =>
              current is LocalSettingUpdated || current is LocalSettingsLoaded,
          builder: (context, state) {
            final localizationService = getIt<LocalizationService>();
            final savedLocale = localizationService.getLocale();

            return EasyLocalization(
              // Idiomas soportados: Español e Inglés
              supportedLocales: const [
                Locale('es'), // Español
                Locale('en'), // Inglés
              ],
              // Ruta donde están los archivos de traducción
              path: 'assets/translations',
              // Idioma de respaldo: si el dispositivo está en un idioma no soportado,
              // se mostrará inglés (más universal que español)
              fallbackLocale: const Locale('en'),
              // Si el usuario ya cambió el idioma manualmente, usar su preferencia guardada
              // Si es null, easy_localization detectará automáticamente el idioma del dispositivo
              startLocale: savedLocale,
              // Guardar la preferencia del usuario cuando cambie el idioma manualmente
              // Esto permite que la app recuerde la selección del usuario
              saveLocale: true,
              child: Builder(
                builder: (context) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData.light(),
                  navigatorKey: navigatorKey,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: const LoginPage(),
                  routes: {
                    '/login': (context) => const LoginPage(),
                    '/welcome': (context) => const WelcomeScreen(),
                    '/home': (context) => const MainNavigationPage(),
                    '/register': (context) => const RegistrationPage(),
                    '/onboarding': (context) => const OnboardingPage(),
                    '/situation': (context) => const SituationSelectionPage(),
                    '/prepartum-form': (context) => const PrepartumFormPage(),
                    '/postpartum-form': (context) => const PostpartumFormPage(),
                    '/configuracion': (context) => const SettingsPage(),
                    '/perfil': (context) => const MainNavigationPage(),
                    '/lecciones': (context) => const LessonsPage(),
                    '/secciones': (context) => const MainNavigationPage(),
                    '/historial': (context) => const UserVideosPage(),
                    '/edicion': (context) => const MainNavigationPage(),
                    '/tips': (context) => const TipsPage(),
                    '/Onboar_Info': (context) => const MainNavigationPage(),
                    '/daily-sleep-form': (context) =>
                        const DailySleepFormPage(),
                    '/baby-weight-form': (context) =>
                        const BabyWeightFormPage(),
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
