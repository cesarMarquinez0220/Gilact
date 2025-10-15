import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/video.dart';
import '../../data/services/video_progress_service.dart';
import '../../data/services/video_cache_service.dart';
import '../../data/services/video_preload_service.dart';
import '../../data/services/image_compression_service.dart';
import '../../data/services/video_interaction_service.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Colores de la aplicación
class AppColors {
  static const Color primary = Color(0xFF4FD1C7);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color error = Color(0xFFF44336);
}

/// Reproductor de video con funcionalidad completa de seguimiento de progreso
class AdvancedVideoPlayer extends StatefulWidget {
  final Video video;
  final VoidCallback? onVideoCompleted;
  final VoidCallback? onVideoReady;
  final bool isPreloaded; // Nuevo parámetro para indicar si está precargado
  final bool
  isLastVideoInLesson; // Nuevo parámetro para saber si es el último video

  const AdvancedVideoPlayer({
    super.key,
    required this.video,
    this.onVideoCompleted,
    this.onVideoReady,
    this.isPreloaded = false, // Por defecto false
    this.isLastVideoInLesson = false, // Por defecto false
  });

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late YoutubePlayerController _controller;
  final VideoProgressService _progressService = VideoProgressService();
  final VideoInteractionService _interactionService =
      GetIt.instance<VideoInteractionService>();
  final VideoPreloadService _preloadService = VideoPreloadService();
  final ImageCompressionService _compressionService = ImageCompressionService();

  bool _isPaused = false;
  int _pauseCount = 0;
  int _forwardCount = 0;
  bool _canPop = true;
  bool _guardadoRealizado = false;
  bool _duracionImpresa = false;
  bool _isSavingProgress = false;
  double _lastSavedProgress = 0.0;
  Duration _totalDuration = Duration.zero;

  // Variables para mejoras de UX
  double _playbackSpeed = 1.0;
  bool _isOneHandMode = false;
  final List<double> _completedMilestones = [];
  Timer? _progressNotificationTimer;

  // Variables para overlay con animación
  bool _showVideoOverlay = true;
  Timer? _overlayTimer;

  // Variables para overlay de doble tap estilo Netflix
  bool _showSeekOverlay = false;
  String _seekMessage = '';
  bool _isSeekingForward = false;
  Timer? _seekOverlayTimer;

  // Variables para auto-play del siguiente video
  bool _showAutoPlayCountdown = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  bool _isLastVideoInLesson = false;

  // Variable para controlar estado de reproducción
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
    _getLastPositionFromFirestore();
    _cacheVideoInfo();

    // Inicializar subcolección videos si es necesario
    _initializeVideosSubcollection();

    // Precargar siguiente video
    _preloadNextVideo();

    // Comprimir imagen del video
    _compressVideoThumbnail();

    // Auto-rotar a horizontal si está precargado (experiencia tipo Netflix)
    if (widget.isPreloaded) {
      _autoRotateToLandscape();
    }

    // Iniciar timer para ocultar overlay después de unos segundos
    _startOverlayTimer();

    // Configurar si es el último video de la lección
    _isLastVideoInLesson = widget.isLastVideoInLesson;
  }

  /// Inicia el timer para ocultar el overlay después de unos segundos
  void _startOverlayTimer() {
    _overlayTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showVideoOverlay = false;
        });
      }
    });
  }

  /// Auto-rota a horizontal para videos precargados (experiencia tipo Netflix)
  Future<void> _autoRotateToLandscape() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (kDebugMode) {
        print('🔄 Auto-rotación a horizontal activada para video precargado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en auto-rotación: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressNotificationTimer?.cancel();
    _overlayTimer?.cancel();
    _seekOverlayTimer?.cancel();
    _countdownTimer?.cancel();

    // Restaurar orientación vertical al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  Future<void> _initializeYoutubePlayer() async {
    if (mounted) {
      try {
        if (kDebugMode) {
          print(
            'Inicializando Youtube Player para video ID: ${widget.video.videoId} (Precargado: ${widget.isPreloaded})',
          );
        }

        // Intentar usar controlador precargado si está disponible
        if (widget.isPreloaded) {
          final preloadedController = _preloadService.getPreloadedController(
            widget.video.videoId,
          );
          if (preloadedController != null) {
            _controller = preloadedController;
            if (kDebugMode) {
              print(
                '✅ Usando controlador precargado para video ${widget.video.videoId}',
              );
            }
          } else {
            // Si no hay controlador precargado, crear uno nuevo
            _controller = _createNewController();
          }
        } else {
          // Crear controlador nuevo para videos no precargados
          _controller = _createNewController();
        }

        _controller.addListener(() async {
          if (_controller.value.isReady) {
            _totalDuration = _controller.metadata.duration;

            // Actualizar estado de reproducción
            if (mounted) {
              setState(() {
                _isPlaying = _controller.value.isPlaying;
              });
            }

            if (_totalDuration.inSeconds > 0) {
              // Si la duración total del video es mayor que 0 y la duración no se ha impreso, entonces imprímela
              if (!_duracionImpresa) {
                if (kDebugMode) {
                  print(
                    'Duración total del video: ${_totalDuration.inSeconds}',
                  );
                }
                _duracionImpresa = true;

                // Notificar que el video está listo
                widget.onVideoReady?.call();
              }

              // Si la duración del video es mayor que 0 y el guardado no se ha realizado, entonces realiza el guardado
              if (!_guardadoRealizado) {
                await _saveVideoProgress();
                _guardadoRealizado = true;
              }
            } else {
              // Si la duración total del video es 0, reinicia la bandera de duración impresa
              _duracionImpresa = false;
              _guardadoRealizado = false;
            }
          }
        });
      } catch (error) {
        if (kDebugMode) {
          print('Error al inicializar el reproductor: $error');
        }
      }
    }
  }

  /// Crea un nuevo controlador de YouTube
  YoutubePlayerController _createNewController() {
    return YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.video.videoUrl) ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: widget.isPreloaded, // Auto-play solo si está precargado
        loop: false,
        mute: false,
        forceHD: false,
        controlsVisibleAtStart: true,
        enableCaption: false, // Deshabilitar subtítulos para mejor rendimiento
        hideControls: false,
        showLiveFullscreenButton: false,
        useHybridComposition: true, // Mejor rendimiento en Android
        startAt: 0, // Siempre empezar desde el inicio para videos ya vistos
      ),
    );
  }

  Future<void> _getLastPositionFromFirestore() async {
    if (mounted) {
      try {
        // Primero intentar obtener desde caché
        final cachedProgress = await VideoCacheService.getCachedVideoProgress(
          widget.video.videoId,
        );

        if (cachedProgress != null) {
          final lastPosition = cachedProgress['lastPosition'] as int;
          if (lastPosition > 0) {
            _controller.seekTo(Duration(seconds: lastPosition));
            _lastSavedProgress = cachedProgress['progress'] as double;
            if (kDebugMode) {
              print(
                'Última posición restaurada desde caché: $lastPosition segundos',
              );
            }
            return;
          }
        }

        // Si no hay caché, obtener desde Firestore
        final lastPosition = await _progressService.getLastPosition(
          widget.video.videoId,
        );
        if (lastPosition > 0) {
          _controller.seekTo(Duration(seconds: lastPosition));
          if (kDebugMode) {
            print(
              'Última posición restaurada desde Firestore: $lastPosition segundos',
            );
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error al obtener la última posición: $error');
        }
      }
    }
  }

  Future<void> _cacheVideoInfo() async {
    try {
      await VideoCacheService.cacheVideoInfo(
        videoId: widget.video.videoId,
        title: widget.video.title,
        thumbnailUrl:
            'assets/images/lecciones_camino/${widget.video.imageName}',
        duration: widget.video.duration.inSeconds,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error caching video info: $e');
      }
    }
  }

  /// Inicializa la subcolección videos cuando se inicia el video
  void _initializeVideosSubcollection() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final userId = authState.user.id;
        await _interactionService.initializeVideosSubcollection(
          userId,
          widget.video.videoId,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando subcolección videos: $e');
      }
    }
  }

  void _handleVideoPaused() async {
    if (!_isPaused) {
      _pauseCount++;
      if (kDebugMode) {
        print('Número de veces que se ha realizado pausa: $_pauseCount');
      }

      // Registrar la pausa en la subcolección videos
      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          final userId = authState.user.id;
          await _interactionService.handleFirstVideoPause(
            userId,
            widget.video.videoId,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error registrando pausa: $e');
        }
      }
    }
    _isPaused = true;
  }

  void _handleVideoPlay() {
    _isPaused = false;
  }

  void _onVideoEnded() async {
    if (mounted) {
      if (kDebugMode) {
        print('Video terminado. Incrementando contador de visualizaciones...');
      }

      // Marcar video como completado en ambos servicios
      await _progressService.saveVideoProgress(
        videoId: widget.video.videoId,
        pauseCount: _pauseCount,
        forwardCount: _forwardCount,
        lastPosition: _controller.value.position.inSeconds,
        totalDuration: _totalDuration.inSeconds,
        progress: 1.0,
        isCompleted: true,
      );

      // También marcar como completado en el servicio de interacción
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        await _interactionService.markVideoAsCompleted(
          authState.user.id,
          widget.video.videoId,
        );
      }

      // Actualizar el provider de lecciones
      if (mounted) {
        context.read<LeccionesProvider>().marcarLeccionCompletada(
          widget.video.videoId,
        );
      }

      // Llamar callback si existe
      widget.onVideoCompleted?.call();

      // Lógica de navegación según si es el último video de la lección
      if (_isLastVideoInLesson) {
        // Si es el último video de la lección, retroceder después de un delay
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Si no es el último video, mostrar countdown para auto-play
        _startAutoPlayCountdown();
      }
    }
  }

  void _startAutoPlayCountdown() {
    if (mounted) {
      setState(() {
        _showAutoPlayCountdown = true;
        _countdownSeconds = 5;
      });

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _countdownSeconds--;
          });

          if (_countdownSeconds <= 0) {
            timer.cancel();
            _playNextVideo();
          }
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _playNextVideo() {
    if (mounted) {
      // NO cambiar la orientación aquí, mantener landscape
      // La orientación se mantendrá automáticamente

      // Cerrar el reproductor actual y permitir que la página padre maneje el siguiente video
      Navigator.of(
        context,
      ).pop(false); // false indica que no se completó la lección completa
    }
  }

  void _cancelAutoPlay() {
    _countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        _showAutoPlayCountdown = false;
      });
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _saveVideoProgress() async {
    if (mounted && !_isSavingProgress) {
      _isSavingProgress = true;
      try {
        final currentPosition = _controller.value.position;
        final progress = currentPosition.inSeconds / _totalDuration.inSeconds;
        final clampedProgress = progress.clamp(0.0, 1.0);

        // Solo guardar si hay un cambio significativo (5% o más)
        final progressDifference = (clampedProgress - _lastSavedProgress).abs();

        if (progressDifference >= 0.05 || currentPosition.inSeconds == 0) {
          // Guardar en caché primero (más rápido)
          await VideoCacheService.cacheVideoProgress(
            videoId: widget.video.videoId,
            progress: clampedProgress,
            lastPosition: currentPosition.inSeconds,
          );

          // Guardar en Firestore (más lento pero persistente)
          await _progressService.saveVideoProgress(
            videoId: widget.video.videoId,
            pauseCount: _pauseCount,
            forwardCount: _forwardCount,
            lastPosition: currentPosition.inSeconds,
            totalDuration: _totalDuration.inSeconds,
            progress: clampedProgress,
            isCompleted: false,
          );

          // Actualizar el provider de lecciones
          if (mounted) {
            context.read<LeccionesProvider>().actualizarProgresoVideo(
              widget.video.videoId,
              clampedProgress * 100,
            );
          }

          _lastSavedProgress = clampedProgress;
          if (kDebugMode) {
            print('Progreso guardado: ${(clampedProgress * 100).toInt()}%');
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error al guardar progreso: $error');
        }
      } finally {
        _isSavingProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return PopScope(
          canPop: _canPop,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Visibility(
                visible:
                    orientation != Orientation.portrait &&
                    _showVideoOverlay, // Solo mostrar cuando los controles están visibles
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Transición fluida al presionar atrás
                    Navigator.of(context).pop();
                  },
                ),
              ),
              title: null, // Sin título
              actions: [], // Sin botones adicionales
            ),
            body: Stack(
              children: [
                // Fondo con gradiente
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2C5F5D),
                        Color(0xFF1A365D),
                        Color(0xFF4FD1C7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onDoubleTapDown: _handleDoubleTap,
                      onTap: () {
                        // Mostrar overlay temporalmente al tocar
                        _showOverlayTemporarily();
                      },
                      child: YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: const Color(0xFF4FD1C7),
                        onReady: () {
                          _getLastPositionFromFirestore();
                        },
                        onEnded: (metaData) {
                          _saveVideoProgress();
                          _onVideoEnded();
                        },
                      ),
                    ),
                  ),
                ),

                // Overlay con título y subtítulo estilo Netflix (inferior izquierda)
                if (_showVideoOverlay)
                  Positioned(
                    left: 20,
                    bottom: 100, // Posición estilo Netflix
                    child: AnimatedOpacity(
                      opacity: _showVideoOverlay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.video.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.video.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Botón de pausa/reproducción invisible
                Center(
                  child: InkWell(
                    onTap: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                        _handleVideoPaused();
                        _saveVideoProgress();
                      } else {
                        _controller.play();
                        _handleVideoPlay();
                      }
                    },
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(0, 188, 11, 11),
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Información del video en la parte inferior (solo controles básicos)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        if (_pauseCount > 0)
                          Text(
                            'Pausas: $_pauseCount',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Overlay de countdown para auto-play
                if (_showAutoPlayCountdown)
                  Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Siguiente video en:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_countdownSeconds',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: _cancelAutoPlay,
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _playNextVideo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4FD1C7),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Reproducir ahora'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Overlay estilo Netflix para doble tap
                if (_showSeekOverlay)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSeekingForward
                                ? Icons.fast_forward
                                : Icons.fast_rewind,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _seekMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // ========== MÉTODOS PARA MEJORAS DE UX ==========

  // Precarga progresiva del siguiente video
  Future<void> _preloadNextVideo() async {
    try {
      final currentVideoId = widget.video.videoId;
      final nextVideoId = currentVideoId + 1;

      // Verificar si ya está precargado
      final isPreloaded = await VideoCacheService.isVideoPreloaded(nextVideoId);
      if (isPreloaded) {
        if (kDebugMode) {
          print('ℹ️ Video $nextVideoId ya está precargado');
        }
        return;
      }

      if (kDebugMode) {
        print('📹 Precargando video $nextVideoId progresivamente...');
      }

      // Precargar metadata del video
      await _preloadService.preloadVideoMetadata(nextVideoId);

      // Precargar video en cache
      await VideoCacheService.preloadVideoSegment(nextVideoId, duration: 30);

      if (kDebugMode) {
        print('✅ Video $nextVideoId precargado progresivamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en precarga progresiva: $e');
      }
    }
  }

  // Compresión de imágenes
  Future<void> _compressVideoThumbnail() async {
    try {
      final assetPath =
          'assets/images/lecciones_camino/${widget.video.imageName}';
      final compressedImage = await _compressionService.compressAssetImage(
        assetPath,
        quality: 80,
        maxWidth: 400,
        maxHeight: 300,
      );

      if (compressedImage != null) {
        // Guardar imagen comprimida en caché
        await VideoCacheService.cacheVideoInfo(
          videoId: widget.video.videoId,
          title: widget.video.title,
          thumbnailUrl: assetPath,
          duration: widget.video.duration.inSeconds,
        );

        if (kDebugMode) {
          print('Imagen comprimida para video: ${widget.video.title}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error comprimiendo imagen: $e');
      }
    }
  }

  // Gestos de control
  void _handleDoubleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;

    if (tapPosition < screenWidth / 2) {
      // Retroceder 10 segundos
      final newPosition =
          _controller.value.position - const Duration(seconds: 10);
      _controller.seekTo(newPosition);
      _forwardCount++;
      _showNetflixSeekOverlay('Retroceder 10s', false);
    } else {
      // Adelantar 10 segundos
      final newPosition =
          _controller.value.position + const Duration(seconds: 10);
      _controller.seekTo(newPosition);
      _forwardCount++;
      _showNetflixSeekOverlay('Adelantar 10s', true);
    }
  }

  void _showNetflixSeekOverlay(String message, bool isForward) {
    if (mounted) {
      setState(() {
        _showSeekOverlay = true;
        _seekMessage = message;
        _isSeekingForward = isForward;
      });

      // Cancelar timer anterior si existe
      _seekOverlayTimer?.cancel();

      // Ocultar overlay después de 1 segundo
      _seekOverlayTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _showSeekOverlay = false;
          });
        }
      });
    }
  }

  /// Muestra el overlay temporalmente cuando el usuario toca la pantalla
  void _showOverlayTemporarily() {
    if (mounted) {
      setState(() {
        _showVideoOverlay = true;
      });

      // Cancelar timer anterior si existe
      _overlayTimer?.cancel();

      // Reiniciar timer para ocultar después de 3 segundos
      _overlayTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showVideoOverlay = false;
          });
        }
      });
    }
  }
}
