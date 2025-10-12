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

  const AdvancedVideoPlayer({
    super.key,
    required this.video,
    this.onVideoCompleted,
    this.onVideoReady,
  });

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late YoutubePlayerController _controller;
  final VideoProgressService _progressService = VideoProgressService();
  final VideoPreloadService _preloadService = VideoPreloadService();
  final ImageCompressionService _compressionService = ImageCompressionService();
  final VideoInteractionService _interactionService =
      GetIt.instance<VideoInteractionService>();

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
  Timer? _inactivityTimer;
  double _playbackSpeed = 1.0;
  bool _isOneHandMode = false;
  final List<double> _completedMilestones = [];
  Timer? _progressNotificationTimer;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
    _getLastPositionFromFirestore();
    _cacheVideoInfo();
    _startInactivityTimer();

    // Inicializar subcolección videos si es necesario
    _initializeVideosSubcollection();

    // Precargar siguiente video
    _preloadNextVideo();

    // Comprimir imagen del video
    _compressVideoThumbnail();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inactivityTimer?.cancel();
    _progressNotificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeYoutubePlayer() async {
    if (mounted) {
      try {
        if (kDebugMode) {
          print(
            'Inicializando Youtube Player para video ID: ${widget.video.videoId}',
          );
        }

        _controller = YoutubePlayerController(
          initialVideoId:
              YoutubePlayer.convertUrlToId(widget.video.videoUrl) ?? '',
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            loop: false,
            mute: false,
            forceHD: false,
            controlsVisibleAtStart: true,
            enableCaption:
                false, // Deshabilitar subtítulos para mejor rendimiento
            hideControls: false,
            showLiveFullscreenButton: false,
            useHybridComposition: true, // Mejor rendimiento en Android
          ),
        );

        _controller.addListener(() async {
          if (_controller.value.isReady) {
            _totalDuration = _controller.metadata.duration;
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

      // Marcar video como completado
      await _progressService.saveVideoProgress(
        videoId: widget.video.videoId,
        pauseCount: _pauseCount,
        forwardCount: _forwardCount,
        lastPosition: _controller.value.position.inSeconds,
        totalDuration: _totalDuration.inSeconds,
        progress: 1.0,
        isCompleted: true,
      );

      // Actualizar el provider de lecciones
      if (mounted) {
        context.read<LeccionesProvider>().marcarLeccionCompletada(
          widget.video.videoId,
        );
      }

      // Llamar callback si existe
      widget.onVideoCompleted?.call();

      // Navegar de vuelta
      if (mounted) {
        Navigator.of(context).pop(true);
      }
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
                visible: orientation != Orientation.landscape,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Al presionar hacia atrás, restaurar la orientación vertical
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    _canPop = true;
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Text(
                widget.video.title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: _showVideoInfo,
                ),
              ],
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
                        // Resetear timer de inactividad al tocar la pantalla
                        _resetInactivityTimer();
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
                // Información del video en la parte inferior
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(_totalDuration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
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

  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.video.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duración: ${_formatDuration(_totalDuration)}'),
              const SizedBox(height: 8),
              Text('Lección: ${widget.video.lessonId}'),
              const SizedBox(height: 8),
              Text('Adelantos: $_forwardCount'),
              const SizedBox(height: 8),
              Text(
                'Progreso: ${(_controller.value.position.inSeconds / _totalDuration.inSeconds * 100).toInt()}%',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
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

  // Timer de inactividad
  void _startInactivityTimer() {
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _handleVideoPaused();
        _showInactivityDialog();
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }

  void _showInactivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Pausado'),
        content: const Text(
          'El video se pausó automáticamente por inactividad. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.play();
              _handleVideoPlay();
              _resetInactivityTimer();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
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
      _showSeekNotification('Retrocedido 10s');
    } else {
      // Adelantar 10 segundos
      final newPosition =
          _controller.value.position + const Duration(seconds: 10);
      _controller.seekTo(newPosition);
      _forwardCount++;
      _showSeekNotification('Adelantado 10s');
    }
  }

  void _showSeekNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}
