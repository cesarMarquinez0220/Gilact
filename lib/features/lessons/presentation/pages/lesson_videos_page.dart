import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/app_initialization_service.dart' as app_init;

import '../../domain/entities/video.dart';
import '../../data/services/video_service.dart';
import '../providers/lecciones_provider.dart';
import '../providers/video_images_provider.dart';
import '../../../videos/presentation/pages/video_player_page.dart';
import '../../../videos/domain/entities/video.dart' as video_entity;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../gamification/presentation/widgets/lesson_trivia_widget.dart';
import '../../../gamification/domain/services/gamification_service.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/presentation/widgets/baby_stage_upgrade_dialog.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

class LessonVideosPage extends StatefulWidget {
  final List<Video> videos;
  final bool fromNotification;

  const LessonVideosPage({
    super.key,
    required this.videos,
    this.fromNotification = false,
  });

  @override
  State<LessonVideosPage> createState() => _LessonVideosPageState();
}

class _LessonVideosPageState extends State<LessonVideosPage>
    with WidgetsBindingObserver {
  final AppLogger _logger = getIt<AppLogger>();
  List<Video>? _videos;
  int lastCompletedLesson = 0;
  DateTime? _lastProgressLoad;
  bool _isInitialLoad = true;
  bool _isLoadingProgress = false;
  static const _progressLoadCooldown = Duration(seconds: 3);
  // Estado de trivias completadas para cada lección (IDs de lecciones)
  Set<int> _completedTriviaLessons = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeProviders();
    _loadVideos();
    // Cargar progreso y estado de trivias solo si no se ha cargado antes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isInitialLoad) {
        _loadProgressIfNeeded();
      }
      _loadTriviaStatus();
    });
  }

  /// Carga de una sola vez qué lecciones ya tienen trivia completada
  /// Para usuarios preparto, no carga trivias completadas para permitir repetición
  Future<void> _loadTriviaStatus() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _completedTriviaLessons = {};
        });
        return;
      }

      final userId = authState.user.id;

      // Verificar si el usuario es preparto
      final userProfileBloc = context.read<UserProfileBloc>();
      final userProfileState = userProfileBloc.state;
      final isPrePartum = userProfileState is UserProfileLoaded
          ? userProfileState.profile.isPrePartum
          : (userProfileState is UserProfileUpdated
                ? userProfileState.profile.isPrePartum
                : false);

      // Si es preparto, no cargar trivias completadas para permitir repetición
      if (isPrePartum) {
        if (!mounted) return;
        setState(() {
          _completedTriviaLessons = {};
        });
        _logger.d(
          'Usuario preparto: trivias siempre disponibles para repetición',
        );
        return;
      }

      final gamificationService = GetIt.instance<GamificationService>();

      final completedLessonIdsStr = await gamificationService
          .getCompletedTriviaLessonIds(userId);

      final completedLessonIds = completedLessonIdsStr
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toSet();

      if (!mounted) return;

      setState(() {
        _completedTriviaLessons = completedLessonIds;
      });

      _logger.d(
        'Trivias completadas cargadas: ${_completedTriviaLessons.toList()..sort()}',
      );
    } catch (e, stackTrace) {
      _logger.w('Error cargando estado de trivias completadas', e, stackTrace);
      if (mounted) {
        setState(() {
          _completedTriviaLessons = {};
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Recargar progreso cuando la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      _loadProgressFromFirestore();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // NO recargar automáticamente aquí - solo cuando realmente se regresa desde otra página
    // La recarga se hará cuando se regrese del reproductor de video o desde historial
  }

  Future<void> _initializeProviders() async {
    // Inicializar el provider de imágenes de videos
    final videoImagesProvider = Provider.of<VideoImagesProvider>(
      context,
      listen: false,
    );
    await videoImagesProvider.initialize();
    // No se usa context después del await, así que no se necesita verificación
  }

  /// Verifica si el progreso ya está cargado y lo carga si es necesario
  Future<void> _loadProgressIfNeeded() async {
    try {
      final leccionesProvider = context.read<LeccionesProvider>();

      // Verificar si ya hay progreso cargado (videos completados o progreso guardado)
      final hasProgress =
          leccionesProvider.ultimaLeccionCompletada > 0 ||
          leccionesProvider.getProgresoVideo(1) > 0;

      if (hasProgress) {
        _logger.d('Progreso de lecciones ya está cargado, omitiendo carga');
        return;
      }

      // Si no hay progreso, cargarlo desde Firestore
      await _loadProgressFromFirestore(force: true);
    } catch (e, stackTrace) {
      _logger.w('Error verificando progreso', e, stackTrace);
      // Si hay error, intentar cargar de todas formas
      await _loadProgressFromFirestore(force: true);
    }
  }

  /// Carga el progreso desde Firestore al entrar a la página
  Future<void> _loadProgressFromFirestore({bool force = false}) async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoadingProgress && !force) {
      _logger.d('Carga de progreso ya en curso, omitiendo...');
      return;
    }

    try {
      final now = DateTime.now();

      // Si no es forzado, verificar cooldown
      if (!force) {
        if (_lastProgressLoad != null &&
            now.difference(_lastProgressLoad!) < _progressLoadCooldown) {
          _logger.d(
            'Recarga de progreso omitida (cooldown activo: ${now.difference(_lastProgressLoad!).inSeconds}s)',
          );
          return;
        }
      }

      _isLoadingProgress = true;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final userId = authState.user.id;
        final leccionesProvider = context.read<LeccionesProvider>();

        _logger.d('Iniciando carga de progreso desde Firestore...');

        await leccionesProvider.loadProgressFromFirestore(userId);

        if (!mounted) return;

        _lastProgressLoad = now;
        _isInitialLoad = false;

        if (mounted) {
          setState(() {}); // Forzar actualización de la UI
        }
        _logger.success(
          'Progreso cargado desde Firestore (${force ? "forzado" : "normal"})',
        );
      }
    } catch (e, stackTrace) {
      _logger.w('Error cargando progreso al entrar a lecciones', e, stackTrace);
    } finally {
      _isLoadingProgress = false;
    }
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await VideoService.getVideos();
      setState(() {
        _videos = videos;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los videos: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToReproductorVideoHelper(
    int videoId,
    int duracionId,
    String videoURL,
  ) async {
    _logger.d("ID del video enviado al reproductor es: $videoId");

    // Obtener el nombre de imagen correcto usando el Provider
    final videoImagesProvider = Provider.of<VideoImagesProvider>(
      context,
      listen: false,
    );
    final imageName = videoImagesProvider.getImageNameForVideo(videoId);

    _logger.d("Imagen seleccionada para video $videoId: $imageName");

    // Convertir Video de lessons a Video de videos
    final video = video_entity.Video(
      id: videoId.toString(),
      title: 'Video $videoId',
      description: 'Lección de lactancia materna',
      videoUrl: videoURL,
      imageUrl: '',
      imageName: imageName, // Usar la imagen correcta del Provider
      videoId: videoId,
      order: videoId,
      duration: const Duration(minutes: 5), // Duración por defecto
      lessonId: duracionId,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Determinar si es el último video de la lección
    final isLastVideoInLesson = _isLastVideoInLesson(videoId, duracionId);

    // Obtener userId del AuthBloc
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => VideoPlayerPage(
          video: video,
          userId: userId,
          isLastVideoInLesson:
              isLastVideoInLesson, // Pasar flag de último video
        ),
        transitionsBuilder: (context, animation1, animation2, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation1.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    if (!mounted) return;

    // Verifica si se completó una lección y actualiza lastCompletedLesson
    if (result != null && result is bool && result) {
      setState(() {
        lastCompletedLesson = videoId;
      });
      // Obtener el perfil actual antes de actualizar para comparar la etapa
      final gamificationBloc = context.read<GamificationBloc>();
      final currentState = gamificationBloc.state;
      String? previousStage;
      if (currentState is GamificationLoaded) {
        previousStage = currentState.profile.babyStage;
      }

      // Actualizar el provider y obtener el perfil actualizado si la etapa cambió
      final updatedProfile = await context
          .read<LeccionesProvider>()
          .marcarLeccionCompletadaWithProfileUpdate(videoId);

      // Si la etapa del bebé cambió, actualizar el GamificationBloc y mostrar diálogo
      if (updatedProfile != null && mounted) {
        final newStage = updatedProfile.babyStage;

        // Verificar si la etapa realmente cambió
        if (previousStage != null && previousStage != newStage) {
          // Actualizar el bloc
          gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
          _logger.d('Etapa del bebé actualizada: $previousStage -> $newStage');

          // Mostrar diálogo de celebración después de un pequeño delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          // Obtener el conteo de lecciones únicas (no videos)
          final completedLessons = await context
              .read<LeccionesProvider>()
              .getCompletedLessonsCountUnique();

          // Verificar que el contexto sigue siendo válido después del gap asíncrono
          if (!mounted) return;

          BabyStageUpgradeDialog.show(
            context,
            newStage: newStage,
            previousStage: previousStage,
            completedLessons: completedLessons,
          );
        } else {
          // Solo actualizar el bloc sin mostrar diálogo
          gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
        }
      }
    } else if (result == false) {
      // Si result es false, significa que se presionó "Reproducir siguiente"
      // Asegurar que la orientación landscape se mantenga durante la transición
      // Hacer esto ANTES de buscar el siguiente video para evitar cualquier cambio
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Pequeño delay para asegurar que la orientación se establezca
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Buscar el siguiente video disponible
      final nextVideo = _findNextVideo(videoId);
      if (nextVideo != null) {
        // Asegurar landscape nuevamente antes de navegar
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        // Reproducir el siguiente video automáticamente
        _navigateToReproductorVideoHelper(
          nextVideo.videoId,
          nextVideo.leccionId,
          nextVideo.videoURL,
        );
      }
    } else {
      // Si el usuario retrocedió sin completar, recargar el progreso desde Firestore
      // para actualizar el CircularProgressIndicator
      await _refreshVideoProgress();
    }
  }

  /// Recarga el progreso del video desde Firestore para actualizar el indicador
  Future<void> _refreshVideoProgress() async {
    // Recargar el progreso completo desde Firestore cuando se regresa del reproductor
    await _loadProgressFromFirestore(force: true);
    _logger.d('Progreso recargado desde Firestore después de ver video');
  }

  @override
  Widget build(BuildContext context) {
    // Usar watch en lugar de read para que el widget se reconstruya cuando cambie el provider
    final avancesProvider = context.watch<LeccionesProvider>();
    if (kDebugMode) {
      avancesProvider.imprimirAvancesMap();
    }

    return PopScope(
      canPop: !widget.fromNotification,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (widget.fromNotification && !didPop) {
          final currentContext = context;
          await app_init.AppInitializationService.refreshAndGoHome(
            currentContext,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C5F5D), // Azul teal oscuro
                Color(0xFF1A365D), // Azul marino oscuro
                Color(0xFF4FD1C7), // Verde azulado vibrante
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header con navegación
                _buildHeader(),

                // Contenido principal - Camino de lecciones
                // Ya no mostramos un loader explícito aquí; la página entra de inmediato.
                // El camino se dibuja en cuanto haya datos en memoria.
                Expanded(child: _buildLessonPath()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              'lessons.pathTitle'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('lessons.pathTitle'.tr()),
                    content: Text('lessons.pathDescription'.tr()),
                    actions: <Widget>[
                      TextButton(
                        child: Text('common.close'.tr()),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.help, size: 24, color: Color(0xFF2C5F5D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPath() {
    // Mientras los videos se cargan en background, mostramos un contenedor vacío
    // para que la transición sea inmediata y sin indicadores de carga.
    if (_videos == null) {
      return const SizedBox.shrink();
    }

    if (_videos!.isEmpty) {
      return const Center(
        child: Text(
          'No hay lecciones disponibles',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    // Agrupar videos por lección
    Map<int, List<Video>> lessonsMap = {};
    for (var video in _videos!) {
      lessonsMap.putIfAbsent(video.leccionId, () => []).add(video);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: lessonsMap.entries.map((entry) {
          final lessonId = entry.key;
          final videos = entry.value;
          return _buildLessonSection(lessonId, videos);
        }).toList(),
      ),
    );
  }

  Widget _buildLessonSection(int lessonId, List<Video> videos) {
    // La primera lección siempre está disponible
    final bool isLocked =
        lessonId > 1 && !_completedTriviaLessons.contains(lessonId - 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la lección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isLocked
                    ? Colors.grey.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${'lessons.lesson'.tr()} $lessonId',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey[300] : Colors.white,
                        ),
                      ),
                    ),
                    if (isLocked)
                      const Icon(Icons.lock, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _getSubtitleForLesson(lessonId),
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: isLocked
                        ? Colors.grey[400]
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'trivia.completePrevious'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.orange[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Indicador de desbloqueo de bebé (se muestra siempre para lecciones 7 y 14)
          _buildBabyUnlockIndicator(lessonId),

          const SizedBox(height: 20),

          // Camino de videos (bloqueado si la lección está bloqueada)
          Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: IgnorePointer(
              ignoring: isLocked,
              child: _buildVideoPath(videos),
            ),
          ),

          const SizedBox(height: 20),

          // Botón de trivia (requisito antes de avanzar)
          if (!isLocked) _buildTriviaButton(lessonId, videos),
        ],
      ),
    );
  }

  Widget _buildVideoPath(List<Video> videos) {
    return CustomPaint(
      painter: LessonPathPainter(videos.length),
      child: Column(
        children: videos.asMap().entries.map((entry) {
          final index = entry.key;
          final video = entry.value;

          return Column(
            children: [
              // Nodo del video con posición personalizada
              SizedBox(
                height: 100,
                child: Center(child: _buildVideoNode(video, index)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoNode(Video video, int index) {
    // Usar el estado real de estaCompletado desde Firestore
    final isCompleted = _isVideoCompletedFromFirestore(video.videoId);

    // Obtener el progreso del video - usar watch para que se reconstruya cuando cambie
    final leccionesProvider = context.watch<LeccionesProvider>();
    final progress = leccionesProvider.getProgresoVideo(video.videoId);

    // Lógica de disponibilidad: solo el primer video de la primera lección está disponible inicialmente
    // Después, solo se habilita el siguiente video cuando el anterior está completado
    final isAvailable = _isVideoAvailable(video, index);

    // Log para debugging del progreso (más detallado)
    _logger.d(
      'Video ${video.videoId}: Disponible=$isAvailable, Completado=$isCompleted, Progreso=${progress.toStringAsFixed(1)}%',
    );

    // Tamaño dinámico del nodo
    final nodeSize = isCompleted
        ? 90.0
        : isAvailable
        ? 85.0
        : 75.0;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              _navigateToReproductorVideoHelper(
                video.videoId,
                video.leccionId,
                video.videoURL,
              );
            }
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CircularProgressIndicator como borde exterior (detrás del círculo)
          // Mostrar si hay progreso > 0.01% (incluso progreso muy bajo) para que se vea el indicador
          // Mostrar incluso si el video no está disponible, siempre que tenga progreso
          if (!isCompleted && progress > 0.01)
            SizedBox(
              width:
                  nodeSize +
                  12, // Más grande para que se vea como borde exterior
              height: nodeSize + 12,
              child: CircularProgressIndicator(
                value:
                    progress /
                    100.0, // El progreso ya viene como porcentaje del provider
                strokeWidth: 4,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF9800), // Naranja vibrante para mejor visibilidad
                ),
              ),
            ),

          // Contenedor principal del nodo
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isAvailable
                  ? Colors.white
                  : Colors.grey.withValues(alpha: 0.3),
              border: Border.all(
                color: isCompleted
                    ? Colors.green
                    : isAvailable
                    ? const Color(0xFF4FD1C7)
                    : Colors.grey,
                width: isCompleted ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.4)
                      : isAvailable
                      ? const Color(0xFF4FD1C7).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: isCompleted ? 12 : 8,
                  spreadRadius: isCompleted ? 2 : 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Imagen del video como fondo
                if (isAvailable || isCompleted)
                  Positioned.fill(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/lecciones_camino/${video.pathImageName}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForVideo(video),
                              color: Colors.grey,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Overlay verde con checkmark para videos completados
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.9),
                            Colors.green.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 35),
                      ),
                    ),
                  ),

                // Icono de candado para videos bloqueados
                if (!isAvailable && !isCompleted)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 25,
                      ),
                    ),
                  ),

                // Efecto de pulso para videos disponibles (solo si no hay progreso)
                if (isAvailable && !isCompleted && progress == 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4FD1C7).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Video? _findNextVideo(int currentVideoId) {
    if (_videos == null) return null;

    // Ordenar todos los videos por videoId
    final sortedVideos = List<Video>.from(_videos!);
    sortedVideos.sort((a, b) => a.videoId.compareTo(b.videoId));

    // Encontrar el índice del video actual
    final currentIndex = sortedVideos.indexWhere(
      (v) => v.videoId == currentVideoId,
    );
    if (currentIndex == -1 || currentIndex >= sortedVideos.length - 1) {
      return null; // No hay siguiente video
    }

    // Retornar el siguiente video
    return sortedVideos[currentIndex + 1];
  }

  bool _isVideoCompletedFromFirestore(int videoId) {
    // Verificar tanto el progreso como el estado completado en el provider
    final leccionesProvider = context.watch<LeccionesProvider>();
    final progress = leccionesProvider.getProgresoVideo(videoId);
    final isCompleted = leccionesProvider.isLeccionCompletada(videoId);

    // Un video está completado si:
    // 1. Tiene progreso >= 100% O
    // 2. Está marcado como completado en Firestore (estaCompletado: true)
    return progress >= 100.0 || isCompleted;
  }

  bool _isLastVideoInLesson(int videoId, int lessonId) {
    if (_videos == null) return false;

    // Obtener todos los videos de la misma lección
    final lessonVideos = _videos!
        .where((v) => v.leccionId == lessonId)
        .toList();

    // Ordenar por videoId para encontrar el último
    lessonVideos.sort((a, b) => a.videoId.compareTo(b.videoId));

    // Verificar si es el último video de la lección
    return lessonVideos.isNotEmpty && lessonVideos.last.videoId == videoId;
  }

  bool _isVideoAvailable(Video video, int index) {
    if (_videos == null) return false;

    // Solo el primer video (videoId = 1) está disponible inicialmente
    if (video.videoId == 1) {
      return true;
    }

    // Para videos posteriores, verificar si el video anterior en secuencia está completado
    final previousVideoId = video.videoId - 1;
    return _isVideoCompletedFromFirestore(previousVideoId);
  }

  IconData _getIconForVideo(Video video) {
    // Asignar iconos diferentes según el tipo de contenido
    switch (video.videoId % 4) {
      case 0:
        return Icons.play_circle_filled;
      case 1:
        return Icons.video_library;
      case 2:
        return Icons.school;
      case 3:
        return Icons.quiz;
      default:
        return Icons.play_circle_filled;
    }
  }

  Widget _buildTriviaButton(int lessonId, List<Video> videos) {
    // Verificar si el usuario es preparto
    final userProfileBloc = context.read<UserProfileBloc>();
    final userProfileState = userProfileBloc.state;
    final isPrePartum = userProfileState is UserProfileLoaded
        ? userProfileState.profile.isPrePartum
        : (userProfileState is UserProfileUpdated
              ? userProfileState.profile.isPrePartum
              : false);

    // Para preparto, siempre permitir hacer trivias (repetibles)
    // Para postparto, verificar si está completada
    final isCompleted =
        !isPrePartum && _completedTriviaLessons.contains(lessonId);
    final allVideosCompleted = videos.every(
      (video) => _isVideoCompletedFromFirestore(video.videoId),
    );

    // Solo mostrar el botón si todos los videos están completados
    if (!allVideosCompleted) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => _showTrivia(lessonId),
        icon: Icon(
          isCompleted ? Icons.check_circle : Icons.quiz,
          color: Colors.white,
        ),
        label: Text(
          isPrePartum
              ? 'trivia.repeatTrivia'.tr()
              : (isCompleted
                    ? 'trivia.completed'.tr()
                    : 'trivia.completeToAdvance'.tr()),
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? Colors.green.withValues(alpha: 0.8)
              : const Color(0xFF3498DB),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Future<void> _showTrivia(int lessonId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;
    final lessonIdStr = lessonId.toString();

    // Verificar si el usuario es preparto
    final userProfileBloc = context.read<UserProfileBloc>();
    final userProfileState = userProfileBloc.state;
    final isPrePartum = userProfileState is UserProfileLoaded
        ? userProfileState.profile.isPrePartum
        : (userProfileState is UserProfileUpdated
              ? userProfileState.profile.isPrePartum
              : false);

    // Verificar si ya está completada (solo para postparto)
    final isCompleted =
        !isPrePartum && _completedTriviaLessons.contains(lessonId);

    if (!mounted) return;

    // Para preparto, siempre permitir hacer trivias (repetibles)
    // Para postparto, mostrar mensaje si ya está completada
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trivia.alreadyCompleted'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    await LessonTriviaWidget.show(
      context,
      lessonId: lessonIdStr,
      userId: userId,
      onComplete: () {
        // Marcar trivia como completada en memoria y refrescar UI
        // Solo para postparto (preparto puede repetir)
        if (mounted) {
          setState(() {
            // Solo agregar a completadas si NO es preparto
            if (!isPrePartum) {
              _completedTriviaLessons.add(lessonId);
            }
          });
        }
      },
    );
  }

  String _getSubtitleForLesson(int lessonNumber) {
    switch (lessonNumber) {
      case 1:
        return 'lessons.subtitles.lesson1'.tr();
      case 2:
        return 'lessons.subtitles.lesson2'.tr();
      case 3:
        return 'lessons.subtitles.lesson3'.tr();
      case 4:
        return 'lessons.subtitles.lesson4'.tr();
      case 5:
        return 'lessons.subtitles.lesson5'.tr();
      case 6:
        return 'lessons.subtitles.lesson6'.tr();
      case 7:
        return 'lessons.subtitles.lesson7'.tr();
      case 8:
        return 'lessons.subtitles.lesson8'.tr();
      case 9:
        return 'lessons.subtitles.lesson9'.tr();
      case 10:
        return 'lessons.subtitles.lesson10'.tr();
      case 11:
        return 'lessons.subtitles.lesson11'.tr();
      case 12:
        return 'lessons.subtitles.lesson12'.tr();
      case 13:
        return 'lessons.subtitles.lesson13'.tr();
      case 14:
        return 'lessons.subtitles.lesson14'.tr();
      default:
        return '';
    }
  }

  /// Construye el indicador de desbloqueo de bebé para lecciones específicas
  Widget _buildBabyUnlockIndicator(int lessonId) {
    // Solo mostrar en lecciones 7 y 14 (donde se desbloquean nuevos bebés)
    if (lessonId != 7 && lessonId != 14) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<int>(
      future: _getCompletedLessonsCount(),
      builder: (context, snapshot) {
        final completedLessons = snapshot.data ?? 0;

        // Determinar si mostrar el indicador basándose directamente en la lección y lecciones completadas
        bool shouldShow = false;
        if (lessonId == 7 && completedLessons < 7) {
          // Mostrar en lección 7 si el usuario tiene menos de 7 lecciones completadas
          shouldShow = true;
        } else if (lessonId == 14 && completedLessons < 14) {
          // Mostrar en lección 14 si el usuario tiene menos de 14 lecciones completadas
          shouldShow = true;
        }

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        String message;
        IconData icon;
        if (lessonId == 7) {
          message = 'lessons.babyUnlock.3months'.tr();
          icon = Icons.child_care; // Bebé de 3 meses
        } else {
          message = 'lessons.babyUnlock.6months'.tr();
          icon = Icons.child_friendly; // Bebé de 6 meses
        }

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFf093fb).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFf093fb).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFf093fb).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFFf093fb)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFf093fb),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: const Color(0xFFf093fb).withValues(alpha: 0.6),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Obtiene el conteo de lecciones completadas
  Future<int> _getCompletedLessonsCount() async {
    try {
      final leccionesProvider = context.read<LeccionesProvider>();
      return await leccionesProvider.getCompletedLessonsCountUnique();
    } catch (e) {
      _logger.w('Error obteniendo conteo de lecciones: $e');
      return 0;
    }
  }
}

// Pintor personalizado para crear el camino curvo y dinámico
class LessonPathPainter extends CustomPainter {
  final int nodeCount;

  LessonPathPainter(this.nodeCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    const nodeSpacing = 100.0; // Espaciado entre nodos

    // Dibujar el camino curvo
    for (int i = 0; i < nodeCount - 1; i++) {
      final startY = (i * nodeSpacing) + 50;
      final endY = ((i + 1) * nodeSpacing) + 50;

      // Crear curva suave entre nodos
      final controlPoint1 = Offset(
        centerX + (i % 2 == 0 ? 20 : -20),
        startY + 30,
      );
      final controlPoint2 = Offset(
        centerX + (i % 2 == 0 ? -20 : 20),
        endY - 30,
      );

      final path = Path();
      path.moveTo(centerX, startY);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        centerX,
        endY,
      );

      // Dibujar sombra primero
      canvas.drawPath(path, shadowPaint);
      // Dibujar línea principal
      canvas.drawPath(path, paint);

      // Agregar puntos decorativos en la curva
      _drawDecorativeDots(canvas, path, i);
    }
  }

  void _drawDecorativeDots(Canvas canvas, Path path, int segmentIndex) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Calcular puntos a lo largo de la curva
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final length = pathMetric.length;
      const dotCount = 3;

      for (int i = 1; i < dotCount; i++) {
        final distance = (length * i) / dotCount;
        final tangent = pathMetric.getTangentForOffset(distance);

        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LessonPathPainter extends CustomPainter {
  final List<Video> videos;
  final Map<int, double> progressMap;
  final Function(int) onVideoTap;
  final Function(int) onTriviaTap;
  final Set<int> completedTriviaLessons;
  final int? lastCompletedLesson;

  _LessonPathPainter({
    required this.videos,
    required this.progressMap,
    required this.onVideoTap,
    required this.onTriviaTap,
    required this.completedTriviaLessons,
    this.lastCompletedLesson,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ... existing code ...
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
