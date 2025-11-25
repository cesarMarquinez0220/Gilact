import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import '../../../videos/data/services/video_preload_service.dart';
import '../../../videos/data/services/video_cache_service.dart';
import '../../../videos/data/services/video_interaction_service.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../onboarding/data/services/user_subcollections_service.dart';
import '../../../auth/domain/services/credentials_cache_service.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Páginas refactorizadas
import 'home_page_wrapper.dart';
import 'companion_page.dart';
import 'health_page.dart';
import '../../../settings/presentation/pages/profile_settings_page.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../../core/di/injection.dart';

// Widgets refactorizados
import '../widgets/modern_bottom_navigation_bar.dart';

/// Página principal de navegación con arquitectura limpia y modular
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  // Animación controllers
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Inicializar animaciones
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Inicializar datos de la aplicación
    _initializeAppData();

    _backgroundController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Permite que el contenido se extienda detrás de la navegación
      body: Stack(
        children: [
          // Gradiente de fondo que ocupa toda la pantalla
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                const HomePageWrapper(),
                const CompanionPage(),
                const HealthPage(),
                BlocProvider<SettingsBloc>(
                  create: (context) => getIt<SettingsBloc>(),
                  child: const ProfileSettingsPage(),
                ),
              ],
            ),
          ),
          // Navegación flotante sobre el contenido
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ModernBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                // Solo actualizar si es diferente del índice actual
                if (index == _currentIndex) return;

                // Si el salto es de más de 1 página, hacer jumpToPage para evitar pasar por páginas intermedias
                final distance = (index - _currentIndex).abs();
                if (distance > 1) {
                  _pageController.jumpToPage(index);
                  // Actualizar índice después del jump
                  Future.microtask(() {
                    setState(() {
                      _currentIndex = index;
                    });
                  });
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Los datos del usuario ahora se cargan en WelcomeScreen antes de navegar aquí

  /// Inicializa los datos de la aplicación: precarga videos y configura providers
  Future<void> _initializeAppData() async {
    print('🚀 MainNavigationPage: Inicializando datos de la aplicación...');

    try {
      // Obtener el usuario actual - usar FirebaseAuth directamente para evitar problemas con AuthBloc
      final currentUser = FirebaseAuth.instance.currentUser;
      String? userId;

      if (currentUser == null) {
        // Si no hay usuario en FirebaseAuth, verificar AuthBloc como fallback
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          print('❌ Usuario no autenticado, saltando precarga');
          return;
        }
        userId = authState.user.id;
        print('👤 Usuario autenticado desde AuthBloc: $userId');
      } else {
        // Intentar primero con UID de FirebaseAuth
        final uid = currentUser.uid;
        print(
          '🔍 MainNavigationPage: Verificando si existe documento con UID: $uid',
        );

        // Verificar si el documento con este UID existe
        final docExists = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        if (docExists.exists) {
          userId = uid;
          print('✅ MainNavigationPage: Usuario encontrado con UID: $userId');
        } else {
          // Si no existe con UID, buscar por email (como lo hace LactationService)
          final email =
              currentUser.email ??
              await CredentialsCacheService.loadCredentialsFromCache();

          if (email.isNotEmpty) {
            print(
              '🔄 MainNavigationPage: UID no coincide, buscando por email...',
            );
            userId = await _findUserByEmail(email);
            if (userId != null) {
              print(
                '✅ MainNavigationPage: Usuario encontrado por email: $userId',
              );
            } else {
              print('❌ MainNavigationPage: Usuario no encontrado por email');
              return;
            }
          } else {
            print('❌ MainNavigationPage: No hay email disponible');
            return;
          }
        }

        // Asegurar que AuthBloc esté sincronizado
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          print(
            '🔄 MainNavigationPage: Sincronizando AuthBloc con FirebaseAuth...',
          );
          context.read<AuthBloc>().add(const GetCurrentUserRequested());
        }
      }

      // Validación defensiva: userId debería estar asignado aquí
      // El linter indica que userId no puede ser null en este punto debido al flujo anterior
      // Usar ! para indicar que sabemos que no es null
      final finalUserId = userId;
      if (finalUserId.isEmpty) {
        print('❌ MainNavigationPage: Error crítico - userId es vacío');
        return;
      }

      // Cargar perfil del usuario si no está cargado (importante cuando se navega desde notificación)
      await _ensureUserProfileLoaded(finalUserId);

      // Inicializar providers con datos limpios para cuenta nueva
      await _initializeProvidersForNewUser();

      // Limpiar documentos duplicados en subcolección videos (solo si existen)
      await _cleanupDuplicateDocumentsIfNeeded(finalUserId);

      // Precargar videos en cache
      await _preloadVideosInCache();

      // Inicializar caché del LactationService para reducir consultas a Firebase
      await _initializeLactationServiceCache();

      // Configurar estado inicial de lecciones (solo primera habilitada)
      _setupInitialLessonState();

      print('✅ MainNavigationPage: Datos inicializados correctamente');
    } catch (e) {
      print('❌ Error inicializando datos: $e');
    }
  }

  /// Busca el userId del usuario por email (como lo hace LactationService)
  Future<String?> _findUserByEmail(String email) async {
    try {
      print('🔍 MainNavigationPage: Buscando usuario por email: $email');

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

      if (userQuery.docs.isEmpty) {
        print('❌ MainNavigationPage: Usuario no encontrado por email');
        return null;
      }

      final userId = userQuery.docs.first.id;
      print('✅ MainNavigationPage: Usuario encontrado con ID: $userId');
      return userId;
    } catch (e) {
      print('❌ MainNavigationPage: Error buscando usuario por email: $e');
      return null;
    }
  }

  /// Asegura que el perfil del usuario esté cargado (importante cuando se navega desde notificación)
  Future<void> _ensureUserProfileLoaded(String userId) async {
    try {
      final userProfileBloc = context.read<UserProfileBloc>();
      final currentState = userProfileBloc.state;

      // Si el perfil ya está cargado, no hacer nada
      if (currentState is UserProfileLoaded ||
          currentState is UserProfileUpdated) {
        print('✅ MainNavigationPage: Perfil del usuario ya está cargado');
        return;
      }

      // Si está en estado inicial, cargar el perfil
      print('🔄 MainNavigationPage: Cargando perfil del usuario...');
      userProfileBloc.add(GetUserProfileRequested(userId: userId));

      // Esperar a que se cargue el perfil (máximo 5 segundos)
      int attempts = 0;
      const maxAttempts = 10;
      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        final state = userProfileBloc.state;
        if (state is UserProfileLoaded || state is UserProfileUpdated) {
          print(
            '✅ MainNavigationPage: Perfil del usuario cargado exitosamente',
          );

          // Cargar situación del usuario si no está cargada
          await _ensureUserSituationLoaded(userId);
          return;
        }
        if (state is UserProfileFailure) {
          print(
            '⚠️ MainNavigationPage: Error cargando perfil: ${state.message}',
          );
          return;
        }
        attempts++;
      }
      print('⚠️ MainNavigationPage: Timeout cargando perfil del usuario');
    } catch (e) {
      print('❌ MainNavigationPage: Error cargando perfil del usuario: $e');
    }
  }

  /// Asegura que la situación del usuario esté cargada
  Future<void> _ensureUserSituationLoaded(String userId) async {
    try {
      final userProfileBloc = context.read<UserProfileBloc>();
      final currentState = userProfileBloc.state;

      // Si ya tiene situación cargada, no hacer nada
      if (currentState is UserProfileLoaded ||
          currentState is UserProfileUpdated) {
        final profile = (currentState as dynamic).profile;
        if (profile.situationData != null && profile.situationData.isNotEmpty) {
          print('✅ MainNavigationPage: Situación del usuario ya está cargada');
          return;
        }
      }

      print('🔄 MainNavigationPage: Cargando situación del usuario...');
      final userSubcollectionsService = UserSubcollectionsService(
        FirebaseFirestore.instance,
      );
      final situationData = await userSubcollectionsService
          .getUserSituationData(userId);

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
        print(
          '✅ MainNavigationPage: Situación del usuario cargada exitosamente',
        );
      }
    } catch (e) {
      print('❌ MainNavigationPage: Error cargando situación del usuario: $e');
    }
  }

  /// Inicializa los providers con estado limpio para cuenta nueva
  Future<void> _initializeProvidersForNewUser() async {
    final leccionesProvider = Provider.of<LeccionesProvider>(
      context,
      listen: false,
    );

    // Verificar si es usuario nuevo o existente
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;

      // Verificar si el usuario tiene progreso previo
      final hasPreviousProgress = await _checkIfUserHasProgress(userId);

      if (hasPreviousProgress) {
        // Cargar progreso existente
        await leccionesProvider.loadProgressFromFirestore(userId);
        print('📊 Progreso existente cargado para usuario: $userId');
      } else {
        // Limpiar progreso para cuenta nueva
        await leccionesProvider.clearProgress();
        print('🧹 Progreso limpiado para cuenta nueva');
      }
    }

    print('📋 Providers inicializados');
  }

  /// Verifica si el usuario tiene progreso previo en Firestore
  Future<bool> _checkIfUserHasProgress(String userId) async {
    try {
      print('🔍 Verificando progreso previo para usuario: $userId');

      // Consultar la subcolección de videos del usuario
      final videosCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('videos');

      final querySnapshot = await videosCollection.get();

      // Si hay documentos en la subcolección videos, el usuario tiene progreso
      final hasProgress = querySnapshot.docs.isNotEmpty;

      if (hasProgress) {
        print(
          '✅ Usuario tiene progreso previo: ${querySnapshot.docs.length} videos encontrados',
        );

        // Mostrar detalles del progreso encontrado
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final videoId = data['videoId'];
          final estaCompletado = data['estaCompletado'] ?? false;
          print('📹 Video $videoId - Completado: $estaCompletado');
        }
      } else {
        print('🆕 Usuario nuevo sin progreso previo');
      }

      return hasProgress;
    } catch (e) {
      print('❌ Error verificando progreso del usuario: $e');
      // En caso de error, asumir que es usuario nuevo para evitar problemas
      return false;
    }
  }

  /// Precarga los primeros videos en cache para mejor rendimiento
  Future<void> _preloadVideosInCache() async {
    try {
      final videoPreloadService = VideoPreloadService();

      // Precargar solo los primeros 2 videos inicialmente
      final videosToPreload = [1, 2];

      for (int videoId in videosToPreload) {
        try {
          // Precargar metadata del video
          await videoPreloadService.preloadVideoMetadata(videoId);

          // Precargar video en cache (solo los primeros segundos)
          await VideoCacheService.preloadVideoSegment(videoId, duration: 30);

          print('📹 Video $videoId precargado en cache');
        } catch (e) {
          print('⚠️ Error precargando video $videoId: $e');
        }
      }

      print('✅ Precarga inicial de videos completada (videos 1-2)');
    } catch (e) {
      print('❌ Error en precarga de videos: $e');
    }
  }

  /// Configura el estado inicial de las lecciones (solo primera habilitada)
  void _setupInitialLessonState() {
    // Para cuenta nueva, solo la primera lección está habilitada
    // No hay progreso previo, por lo que el estado inicial es correcto
    print(
      '🎯 Estado inicial de lecciones configurado (solo primera habilitada)',
    );
  }

  /// Limpia documentos duplicados en la subcolección videos (solo si existen)
  Future<void> _cleanupDuplicateDocumentsIfNeeded(String userId) async {
    try {
      final videoInteractionService = GetIt.instance<VideoInteractionService>();
      await videoInteractionService.cleanupDuplicateDocuments(userId);
    } catch (e) {
      print('❌ Error limpiando documentos duplicados: $e');
    }
  }

  /// Precarga progresiva del siguiente video cuando el usuario avanza
  Future<void> preloadNextVideo(int currentVideoId) async {
    try {
      final nextVideoId = currentVideoId + 1;
      final videoPreloadService = VideoPreloadService();

      // Verificar si ya está precargado
      final isPreloaded = await VideoCacheService.isVideoPreloaded(nextVideoId);
      if (isPreloaded) {
        print('ℹ️ Video $nextVideoId ya está precargado');
        return;
      }

      print('📹 Precargando video $nextVideoId progresivamente...');

      // Precargar metadata del video
      await videoPreloadService.preloadVideoMetadata(nextVideoId);

      // Precargar video en cache
      await VideoCacheService.preloadVideoSegment(nextVideoId, duration: 30);

      print('✅ Video $nextVideoId precargado progresivamente');
    } catch (e) {
      print('❌ Error en precarga progresiva: $e');
    }
  }

  /// Inicializa el caché del LactationService para reducir consultas a Firebase
  Future<void> _initializeLactationServiceCache() async {
    try {
      print(
        '🔍 MainNavigationPage: Inicializando caché del LactationService...',
      );
      final lactationService = GetIt.instance<LactationService>();
      await lactationService.initializeUserCache();
      print('✅ MainNavigationPage: Caché del LactationService inicializado');
    } catch (e) {
      print('❌ Error inicializando caché del LactationService: $e');
    }
  }
}
