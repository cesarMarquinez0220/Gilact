import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import '../../../videos/data/services/video_preload_service.dart';
import '../../../videos/data/services/video_cache_service.dart';
import '../../../videos/data/services/video_interaction_service.dart';
import '../../../lactation/data/services/lactation_service.dart';
import 'package:get_it/get_it.dart';

// Páginas refactorizadas
import 'home_page.dart';
import 'health_page.dart';
import 'profile_page.dart';

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
              children: const [HomePage(), HealthPage(), ProfilePage()],
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
                setState(() {
                  _currentIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
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
      // Obtener el usuario actual
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        print('❌ Usuario no autenticado, saltando precarga');
        return;
      }

      final userId = authState.user.id;
      print('👤 Usuario autenticado: $userId');

      // Inicializar providers con datos limpios para cuenta nueva
      await _initializeProvidersForNewUser();

      // Limpiar documentos duplicados en subcolección videos (solo si existen)
      await _cleanupDuplicateDocumentsIfNeeded(userId);

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
