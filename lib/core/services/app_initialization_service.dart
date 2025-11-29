import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../features/auth/domain/services/credentials_cache_service.dart';
import '../../features/onboarding/data/services/user_subcollections_service.dart';
import '../../features/lactation/data/services/sleep_notification_service.dart';
import '../../features/lactation/data/services/lactation_notification_service.dart';
import 'package:get_it/get_it.dart';
import '../../features/user/presentation/bloc/user_profile_bloc.dart';
import '../../features/lactation/presentation/providers/lactation_provider.dart';
import '../../main.dart' show navigatorKey;
import 'app_logger.dart';
import '../di/injection.dart';

/// Servicio para refrescar el estado de la aplicación (perfil, situación,
/// notificaciones) y navegar a Home sin pasar por la pantalla de Welcome.
class AppInitializationService {
  /// Clave global de navegación para acceder al contexto desde cualquier lugar
  static GlobalKey<NavigatorState> get navigationKey => navigatorKey;

  /// Realiza la misma lógica clave que `WelcomeScreen` pero sin animaciones.
  /// - Sincroniza onboarding desde Firestore -> SharedPreferences
  /// - Carga perfil completo y situación del usuario en el `UserProfileBloc`
  /// - Programa notificación diaria si corresponde
  /// - Navega a `/home` cuando termina
  static Future<void> refreshAndGoHome(BuildContext context) async {
    try {
      // Guardar referencia al bloc antes de operaciones asíncronas
      if (!context.mounted) return;
      final userProfileBloc = context.read<UserProfileBloc>();

      // 1) Obtener email
      final email = await _getUserEmail();
      if (!context.mounted) return;
      if (email.isEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        return;
      }

      // 2) Buscar usuario por email
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout buscando usuario por email');
            },
          );

      if (!context.mounted) return;
      if (userQuery.docs.isEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        return;
      }

      final userId = userQuery.docs.first.id;

      // 3) Reiniciar y cargar perfil en el BLoC
      userProfileBloc.add(const ResetUserProfileRequested());
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      userProfileBloc.add(GetUserProfileRequested(userId: userId));
      await _waitForUserProfileToLoad(context, userProfileBloc);

      // 4) Cargar situación y actualizar BLoC
      final userSubcollectionsService = UserSubcollectionsService(
        FirebaseFirestore.instance,
        getIt<AppLogger>(),
      );
      final situationData = await userSubcollectionsService
          .getUserSituationData(userId);

      if (!context.mounted) return;
      if (situationData != null) {
        final situationType = situationData['situationType'] as String?;
        final isPrePartum = situationType == 'preparto';
        final isPostPartum = situationType == 'postparto';

        userProfileBloc.add(
          UpdateUserSituationRequested(
            userId: userId,
            isPrePartum: isPrePartum,
            isPostPartum: isPostPartum,
            situationData: situationData,
          ),
        );

        // 5) Notificación diaria si es postparto
        if (isPostPartum) {
          try {
            final notificationService =
                GetIt.instance<SleepNotificationService>();
            await notificationService.scheduleDailySleepNotification();
          } catch (_) {
            // Ignorar errores de programación de notificación para no bloquear la navegación
          }
        }
      }

      // 6) Verificar y reprogramar notificaciones eliminadas
      try {
        final lactationNotificationService = LactationNotificationService();
        await lactationNotificationService.verifyAndRescheduleNotifications();

        // Diagnosticar problemas con notificaciones de sueño
        final sleepNotificationService =
            GetIt.instance<SleepNotificationService>();
        await sleepNotificationService.diagnoseNotificationIssue();
      } catch (_) {
        // Ignorar errores de verificación de notificaciones
      }

      // 7) Navegar a Home
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (_) {
      // Fallback defensivo
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    }
  }

  static Future<void> _waitForUserProfileToLoad(
    BuildContext context,
    UserProfileBloc userProfileBloc,
  ) async {
    int attempts = 0;
    const maxAttempts = 20; // ~10s
    while (attempts < maxAttempts) {
      if (!context.mounted) return;
      final state = userProfileBloc.state;
      if (state is UserProfileLoaded || state is UserProfileUpdated) {
        return;
      }
      if (state is UserProfileFailure) return;
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
  }

  static Future<String> _getUserEmail() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.email != null && firebaseUser!.email!.isNotEmpty) {
        return firebaseUser.email!;
      }
      final cached = await CredentialsCacheService.loadCredentialsFromCache();
      return cached;
    } catch (_) {
      return '';
    }
  }

  /// Refresca solo los datos de lactancia sin recargar todo el perfil del usuario
  /// Esto es más rápido y mantiene el timer funcionando correctamente
  static Future<void> refreshLactationDataOnly() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      // Esperar un poco para que HomePageWrapper termine de construir el Provider
      await Future.delayed(const Duration(milliseconds: 200));

      // Verificar que el contexto sigue montado después del delay
      final currentContext = navigatorKey.currentContext;
      if (currentContext == null || !currentContext.mounted) return;

      // Intentar obtener el LactationProvider del contexto actual
      final logger = getIt<AppLogger>();
      LactationProvider? lactationProvider;

      try {
        lactationProvider = Provider.of<LactationProvider>(
          currentContext,
          listen: false,
        );
      } catch (e) {
        // Provider no disponible en el contexto actual
        // Esto es normal cuando se llama desde una ruta diferente
        // Esperar un poco más e intentar nuevamente
        logger.d(
          'AppInitializationService: Provider no encontrado, esperando...',
        );

        await Future.delayed(const Duration(milliseconds: 500));

        // Verificar nuevamente que el contexto sigue montado
        final retryContext = navigatorKey.currentContext;
        if (retryContext == null || !retryContext.mounted) {
          logger.d(
            'AppInitializationService: Contexto no disponible después del retry',
          );
          return;
        }

        try {
          lactationProvider = Provider.of<LactationProvider>(
            retryContext,
            listen: false,
          );
        } catch (e2) {
          // Si aún no está disponible, simplemente retornar sin error
          // HomePage se encargará de refrescar en su initState
          logger.d(
            'AppInitializationService: Provider aún no disponible, HomePage refrescará en initState',
          );
          return;
        }
      }

      // Si llegamos aquí, el provider está disponible (si no, habríamos hecho return)
      logger.d('AppInitializationService: Refrescando datos de lactancia...');
      try {
        await lactationProvider.refreshTodayData();
        await lactationProvider.loadWeekData();
        logger.success(
          'AppInitializationService: Datos de lactancia refrescados',
        );
      } catch (e, stackTrace) {
        logger.w(
          'AppInitializationService: Error al refrescar datos',
          e,
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.w(
        'AppInitializationService: Error refrescando datos de lactancia',
        e,
        stackTrace,
      );
    }
  }

  /// Inicia la verificación periódica de notificaciones
  /// Verifica cada 3 minutos si las notificaciones fueron eliminadas y las reprograma
  static void startPeriodicNotificationVerification() {
    _NotificationVerificationManager.start();
  }

  static void stopPeriodicNotificationVerification() {
    _NotificationVerificationManager.stop();
  }
}

/// Clase privada para manejar el timer de verificación de notificaciones
class _NotificationVerificationManager {
  static Timer? _timer;

  static void start() {
    // Cancelar timer anterior si existe
    _timer?.cancel();

    // Verificar inmediatamente al iniciar
    _verifyNotifications();

    // Verificar cada 3 minutos
    _timer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => _verifyNotifications(),
    );

    final logger = getIt<AppLogger>();
    logger.success(
      'AppInitializationService: Verificación periódica de notificaciones iniciada',
    );
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    final logger = getIt<AppLogger>();
    logger.d(
      'AppInitializationService: Verificación periódica de notificaciones detenida',
    );
  }

  static Future<void> _verifyNotifications() async {
    try {
      final lactationNotificationService = LactationNotificationService();
      await lactationNotificationService.verifyAndRescheduleNotifications();

      // Verificar también notificaciones de sueño
      try {
        final sleepNotificationService =
            GetIt.instance<SleepNotificationService>();
        await sleepNotificationService.verifyAndRescheduleIfNeeded();
      } catch (e, stackTrace) {
        final logger = getIt<AppLogger>();
        logger.w(
          'AppInitializationService: Error verificando notificaciones de sueño',
          e,
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.w(
        'AppInitializationService: Error verificando notificaciones',
        e,
        stackTrace,
      );
    }
  }
}
