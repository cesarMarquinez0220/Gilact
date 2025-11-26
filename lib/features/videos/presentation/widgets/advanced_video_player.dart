import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/video.dart';
import '../../data/services/video_progress_service.dart';
import '../../data/services/video_cache_service.dart';
import '../../data/services/video_preload_service.dart';
import '../../data/services/image_compression_service.dart';
import '../../data/services/video_interaction_service.dart';
import '../../data/services/video_download_service.dart';
import '../../../../core/services/screen_recording_prevention_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import 'offline_video_player.dart';

// Colores de la aplicación
class AppColors {
  static const Color primary = Color(0xFF4FD1C7);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color error = Color(0xFFF44336);
}

/// Reproductor de video con funcionalidad completa de seguimiento de progreso
/// Soporta modo online (YouTube) y offline (videos descargados)
class AdvancedVideoPlayer extends StatefulWidget {
  final Video video;
  final VoidCallback? onVideoCompleted;
  final VoidCallback? onVideoReady;
  final bool isPreloaded;
  final bool isLastVideoInLesson;
  final bool isFromHistory;

  const AdvancedVideoPlayer({
    super.key,
    required this.video,
    this.onVideoCompleted,
    this.onVideoReady,
    this.isPreloaded = false,
    this.isLastVideoInLesson = false,
    this.isFromHistory = false,
  });

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();

  /// Método estático para acceder al estado y reiniciar el video
  static void replayVideo(GlobalKey key) {
    final state = key.currentState;
    if (state is _AdvancedVideoPlayerState) {
      state._replayVideo();
    }
  }
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  YoutubePlayerController? _controller;
  final VideoProgressService _progressService = VideoProgressService();
  final VideoInteractionService _interactionService =
      GetIt.instance<VideoInteractionService>();
  // Campos no usados - mantenidos para uso futuro
  // ignore: unused_field
  final VideoPreloadService _preloadService = VideoPreloadService();
  // ignore: unused_field
  final ImageCompressionService _compressionService = ImageCompressionService();
  final VideoDownloadService _downloadService = VideoDownloadService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isOfflineMode = false;
  bool _isCheckingDownload = true;

  final int _pauseCount = 0;
  final int _forwardCount = 0;
  bool _duracionImpresa = false;
  Duration _totalDuration = Duration.zero;

  Timer? _progressNotificationTimer;

  // Variables para overlay con animación
  bool _showVideoOverlay = true;
  Timer? _overlayTimer;

  Timer? _seekOverlayTimer;

  Timer? _countdownTimer;
  bool _wasAlreadyCompleted = false;
  StreamSubscription<bool>? _recordingStatusSubscription;

  // Variables para estado del video
  // ignore: unused_field
  bool _isLastVideoInLesson = false;
  // ignore: unused_field
  double _lastSavedProgress = 0.0;
  // ignore: unused_field
  bool _isPaused = false;
  // ignore: unused_field
  bool _isPlaying = false;

  // Key para acceder al OfflineVideoPlayer cuando está en modo offline
  final GlobalKey _offlinePlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Activar prevención de grabación de pantalla
    ScreenRecordingPreventionService.enableScreenProtection();

    // Escuchar cambios en el estado de grabación
    _recordingStatusSubscription =
        ScreenRecordingPreventionService.watchScreenRecordingStatus().listen((
          isRecording,
        ) {
          if (isRecording && mounted) {
            // Pausar el video si se detecta grabación
            _controller?.pause();
            if (kDebugMode) {
              print('⚠️ Grabación de pantalla detectada - Video pausado');
            }
            // Mostrar mensaje al usuario
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La grabación de pantalla no está permitida durante la reproducción',
                ),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        });

    _checkIfVideoIsDownloaded();
  }

  /// Verifica si el video está descargado y decide qué reproductor usar
  /// Lógica: Si hay internet -> YouTube player, Si no hay internet pero está descargado -> Offline player
  Future<void> _checkIfVideoIsDownloaded() async {
    try {
      // Verificar conectividad primero
      final isConnected = await _connectivityService.isConnected();

      // Verificar si el video está descargado
      final isDownloaded = await _downloadService.isVideoDownloaded(
        widget.video.id,
      );

      if (kDebugMode) {
        print('📡 Conectividad: ${isConnected ? "En línea" : "Sin conexión"}');
        print('💾 Video descargado: ${isDownloaded ? "Sí" : "No"}');
      }

      if (mounted) {
        // LÓGICA ROBUSTA: Decidir qué reproductor usar
        // PRIORIDAD 1: Si hay internet -> SIEMPRE usar YouTube player (aunque esté descargado)
        // PRIORIDAD 2: Si NO hay internet PERO está descargado -> usar offline player
        // PRIORIDAD 3: Si NO hay internet Y NO está descargado -> intentar YouTube player (fallará)

        bool shouldUseOffline = false;

        if (isConnected) {
          // HAY INTERNET: Siempre usar YouTube player
          shouldUseOffline = false;
          if (kDebugMode) {
            print(
              '🌐 CON INTERNET: Forzando uso de YouTube player (aunque esté descargado)',
            );
          }
        } else {
          // NO HAY INTERNET: Solo usar offline si está descargado
          shouldUseOffline = isDownloaded;
          if (kDebugMode) {
            if (shouldUseOffline) {
              print(
                '📴 SIN INTERNET + Video descargado: Usando reproductor offline',
              );
            } else {
              print(
                '⚠️ SIN INTERNET + Video NO descargado: Intentando YouTube player (puede fallar)',
              );
            }
          }
        }

        setState(() {
          _isOfflineMode = shouldUseOffline;
          _isCheckingDownload = false;
        });

        if (shouldUseOffline) {
          // Sin conexión pero video descargado: usar offline player
          widget.onVideoReady?.call();
        } else {
          // Hay conexión: usar YouTube player
          _initializeYoutubePlayer();
          _getLastPositionFromFirestore();
          _cacheVideoInfo();
          _initializeVideosSubcollection();
          _preloadNextVideo();
          _compressVideoThumbnail();

          if (widget.isPreloaded) {
            _autoRotateToLandscape();
          }

          _startOverlayTimer();
          _isLastVideoInLesson = widget.isLastVideoInLesson;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando descarga/conectividad: $e');
      }
      if (mounted) {
        setState(() {
          _isOfflineMode = false;
          _isCheckingDownload = false;
        });
        // En caso de error, intentar usar YouTube player
        _initializeYoutubePlayer();
        _getLastPositionFromFirestore();
        _cacheVideoInfo();
        _initializeVideosSubcollection();
        _preloadNextVideo();
        _compressVideoThumbnail();

        if (widget.isPreloaded) {
          _autoRotateToLandscape();
        }

        _startOverlayTimer();
        _isLastVideoInLesson = widget.isLastVideoInLesson;
      }
    }
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

  /// Auto-rota a horizontal para videos precargados
  Future<void> _autoRotateToLandscape() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (kDebugMode) {
        print('🔄 Auto-rotación a horizontal activada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en auto-rotación: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _progressNotificationTimer?.cancel();
    _overlayTimer?.cancel();
    _seekOverlayTimer?.cancel();
    _countdownTimer?.cancel();
    _recordingStatusSubscription?.cancel();

    // Desactivar prevención de grabación de pantalla
    ScreenRecordingPreventionService.disableScreenProtection();

    // NO restaurar orientación aquí - dejar que VideoPlayerPage lo maneje
    // Esto permite mantener landscape cuando se navega al siguiente video
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    super.dispose();
  }

  Future<void> _initializeYoutubePlayer() async {
    if (mounted) {
      try {
        if (kDebugMode) {
          print(
            '🎬 Inicializando YouTube Player para video: ${widget.video.videoId}',
          );
        }

        _controller = _createNewController();

        _controller!.addListener(() {
          if (_controller!.value.isReady) {
            if (!_duracionImpresa) {
              _totalDuration = _controller!.value.metaData.duration;
              _duracionImpresa = true;
              if (kDebugMode) {
                print(
                  '⏱️ Duración del video: ${_totalDuration.inMinutes} minutos',
                );
              }
            }
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error inicializando YouTube Player: $e');
        }
      }
    }
  }

  /// Crea un nuevo controlador de YouTube
  YoutubePlayerController _createNewController() {
    return YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.video.videoUrl) ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: widget.isPreloaded,
        loop: false,
        mute: false,
        forceHD: false,
        controlsVisibleAtStart: true,
        enableCaption: false,
        hideControls: false,
        showLiveFullscreenButton: false,
        useHybridComposition: true,
        startAt: 0,
      ),
    );
  }

  Future<void> _getLastPositionFromFirestore() async {
    if (mounted && _controller != null) {
      try {
        if (widget.isFromHistory) {
          final wasCompleted = await _progressService.isVideoCompleted(
            widget.video.videoId,
          );
          _wasAlreadyCompleted = wasCompleted;
          if (kDebugMode) {
            print('📚 Video desde historial: estaba completado: $wasCompleted');
          }
          return;
        }

        final cachedProgress = await VideoCacheService.getCachedVideoProgress(
          widget.video.videoId,
        );

        if (cachedProgress != null) {
          final lastPosition = cachedProgress['lastPosition'] as int;
          if (lastPosition > 0) {
            _controller!.seekTo(Duration(seconds: lastPosition));
            _lastSavedProgress = cachedProgress['progress'] as double;
            if (kDebugMode) {
              print(
                'Última posición restaurada desde caché: $lastPosition segundos',
              );
            }
            return;
          }
        }

        final lastPosition = await _progressService.getLastPosition(
          widget.video.videoId,
        );

        if (lastPosition > 0) {
          _controller!.seekTo(Duration(seconds: lastPosition));
          if (kDebugMode) {
            print(
              'Última posición restaurada desde Firestore: $lastPosition segundos',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error obteniendo última posición: $e');
        }
      }
    }
  }

  Future<void> _cacheVideoInfo() async {
    try {
      await VideoCacheService.cacheVideoInfo(
        videoId: widget.video.videoId,
        title: widget.video.title,
        thumbnailUrl: widget.video.imageUrl.isNotEmpty
            ? widget.video.imageUrl
            : widget.video.imageName,
        duration: widget.video.duration.inSeconds,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error guardando info en caché: $e');
      }
    }
  }

  Future<void> _initializeVideosSubcollection() async {
    try {
      final user = context.read<AuthBloc>().state;
      if (user is AuthAuthenticated) {
        await _interactionService.initializeVideosSubcollection(
          user.user.id,
          widget.video.videoId,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando subcolección: $e');
      }
    }
  }

  Future<void> _preloadNextVideo() async {
    // Implementación de precarga del siguiente video
  }

  Future<void> _compressVideoThumbnail() async {
    // Implementación de compresión de thumbnail
  }

  @override
  Widget build(BuildContext context) {
    // Si está verificando descarga, mostrar loading
    if (_isCheckingDownload) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FD1C7)),
          ),
        ),
      );
    }

    // Si el video está descargado, usar reproductor offline
    if (_isOfflineMode) {
      return OfflineVideoPlayer(
        key: _offlinePlayerKey,
        video: widget.video,
        onVideoCompleted: widget.onVideoCompleted,
        onVideoReady: widget.onVideoReady,
        isFromHistory: widget.isFromHistory,
      );
    }

    // Si no está descargado, usar YouTube player
    if (_controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FD1C7)),
          ),
        ),
      );
    }

    return _buildYoutubePlayer();
  }

  Widget _buildYoutubePlayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Reproductor de YouTube
          Center(
            child: YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator:
                  false, // Desactivar el indicador de progreso nativo de YouTube
              progressIndicatorColor: const Color(0xFF4FD1C7),
              onReady: () {
                _getLastPositionFromFirestore();
                widget.onVideoReady?.call();
              },
              onEnded: (metaData) {
                _saveVideoProgress();
                _onVideoEnded();
              },
            ),
          ),

          // Overlay con título y subtítulo estilo Netflix
          if (_showVideoOverlay)
            Positioned(
              left: 20,
              bottom: 100,
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
            child: GestureDetector(
              onTap: () {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                  _handleVideoPaused();
                  _saveVideoProgress();
                } else {
                  _controller!.play();
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
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVideoPaused() {
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
  }

  void _handleVideoPlay() {
    setState(() {
      _isPaused = false;
      _isPlaying = true;
    });
  }

  Future<void> _saveVideoProgress() async {
    if (_controller == null || !_controller!.value.isReady) return;

    try {
      final position = _controller!.value.position;
      final duration = _controller!.value.metaData.duration;
      final progress = position.inSeconds / duration.inSeconds;

      // Si el video se está viendo desde historial y ya estaba completado,
      // preservar el estado de completado para no afectar el progreso en lecciones
      final shouldPreserveCompleted =
          widget.isFromHistory && _wasAlreadyCompleted;

      // Si el video ya estaba completado, preservar el progreso al 100%
      final finalProgress = shouldPreserveCompleted ? 1.0 : progress;

      await _progressService.saveVideoProgress(
        videoId: widget.video.videoId,
        pauseCount: _pauseCount,
        forwardCount: _forwardCount,
        lastPosition: position.inSeconds,
        totalDuration: duration.inSeconds,
        progress: finalProgress,
        isCompleted: shouldPreserveCompleted ? true : false,
      );

      if (!mounted) return;

      // Si el video se está viendo desde historial y ya estaba completado,
      // NO actualizar el LeccionesProvider para no afectar el estado de completado
      if (shouldPreserveCompleted) {
        if (kDebugMode) {
          print(
            '📚 Video desde historial ya estaba completado - preservando estado, no actualizando LeccionesProvider',
          );
        }
      } else {
        // Actualizar el LeccionesProvider con el progreso actualizado
        // El progreso viene como valor entre 0 y 1, necesitamos convertirlo a porcentaje (0-100)
        final progressPercentage = progress * 100.0;
        try {
          final leccionesProvider = Provider.of<LeccionesProvider>(
            context,
            listen: false,
          );
          leccionesProvider.actualizarProgresoVideo(
            widget.video.videoId,
            progressPercentage,
          );
          if (kDebugMode) {
            print(
              '📊 Progreso actualizado en LeccionesProvider: ${progressPercentage.toStringAsFixed(1)}%',
            );
          }
        } catch (e) {
          // Si no hay provider disponible (puede pasar en algunos contextos), ignorar
          if (kDebugMode) {
            print('⚠️ No se pudo actualizar LeccionesProvider: $e');
          }
        }
      }

      _lastSavedProgress = progress;
    } catch (e) {
      if (kDebugMode) {
        print('Error guardando progreso: $e');
      }
    }
  }

  Future<void> _onVideoEnded() async {
    if (_wasAlreadyCompleted) return;

    try {
      // markVideoAsCompleted ahora obtiene automáticamente el ID correcto del usuario
      // El primer parámetro (userId) se ignora, pero lo mantenemos por compatibilidad
      await _interactionService.markVideoAsCompleted(
        '', // Se ignora, el servicio obtiene el ID correcto automáticamente
        widget.video.videoId,
      );
      widget.onVideoCompleted?.call();
    } catch (e) {
      if (kDebugMode) {
        print('Error marcando video como completado: $e');
      }
    }
  }

  /// Reinicia el video desde el principio
  void _replayVideo() {
    try {
      if (_isOfflineMode) {
        // Para modo offline, usar el método estático de OfflineVideoPlayer
        if (kDebugMode) {
          print('🔄 Reiniciando video offline desde el principio');
        }
        OfflineVideoPlayer.replayVideo(_offlinePlayerKey);
      } else if (_controller != null) {
        // Para YouTube player, reiniciar desde el principio
        _controller!.seekTo(const Duration(seconds: 0));
        _controller!.play();
        if (kDebugMode) {
          print('🔄 Reiniciando video de YouTube desde el principio');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reiniciando video: $e');
      }
    }
  }
}
