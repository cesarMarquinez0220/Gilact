import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/video.dart';
import '../widgets/advanced_video_player.dart';
import '../widgets/video_loading_widget.dart';
import '../../data/services/video_cache_service.dart';
import '../../data/services/video_preload_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final String userId;
  final bool isLastVideoInLesson; // Nuevo parámetro

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.userId,
    this.isLastVideoInLesson = false, // Por defecto false
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isLoading = true;
  bool _isVideoReady = false;
  bool _hasInitialized = false;
  bool _isVideoPreloaded = false;
  bool _shouldAutoRotate = false;

  @override
  void initState() {
    super.initState();
    // Verificar si el video está precargado
    _checkVideoPreloadStatus();
  }

  Future<void> _checkVideoPreloadStatus() async {
    try {
      // Verificar si el video está precargado en cache
      final isPreloaded = await VideoCacheService.isVideoPreloaded(
        widget.video.videoId,
      );

      // Verificar si hay un controlador precargado
      final preloadService = VideoPreloadService();
      final hasPreloadedController = preloadService.isVideoPreloaded(
        widget.video.videoId,
      );

      if (mounted) {
        setState(() {
          _isVideoPreloaded = isPreloaded || hasPreloadedController;
          _shouldAutoRotate =
              _isVideoPreloaded; // Solo auto-rotar si está precargado
        });

        print(
          '🎬 Video ${widget.video.videoId} precargado: $_isVideoPreloaded',
        );

        if (_isVideoPreloaded) {
          // Si está precargado, ir directo al reproductor sin pantalla de carga
          _initializeVideoDirectly();
        } else {
          // Si no está precargado, mostrar pantalla de carga
          _initializeVideoWithLoading();
        }
      }
    } catch (e) {
      print('Error verificando precarga: $e');
      // En caso de error, usar el flujo normal con carga
      _initializeVideoWithLoading();
    }
  }

  Future<void> _initializeVideoDirectly() async {
    // Para videos precargados, ir directo al reproductor
    if (mounted) {
      setState(() {
        _hasInitialized = true;
        _isLoading = false;
      });

      // Auto-rotar a horizontal para experiencia tipo Netflix
      if (_shouldAutoRotate) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
  }

  Future<void> _initializeVideoWithLoading() async {
    // Tiempo mínimo de carga para UX (1 segundo)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _hasInitialized = true;
      });

      // Timeout de seguridad: si después de 10 segundos no se ha recibido onVideoReady,
      // forzar la transición
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          print('Timeout: Forzando transición a video player');
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _onVideoReady() {
    if (mounted) {
      setState(() {
        _isVideoReady = true;
      });

      // Solo esperar transición si no está precargado
      if (!_isVideoPreloaded) {
        // Esperar un poco más para asegurar transición suave
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Restaurar orientación vertical al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si está precargado, mostrar directamente el reproductor
    if (_isVideoPreloaded) {
      return AdvancedVideoPlayer(
        video: widget.video,
        onVideoCompleted: () {
          _showCompletionDialog();
        },
        onVideoReady: _onVideoReady,
        isPreloaded: true, // Pasar flag de precargado
        isLastVideoInLesson:
            widget.isLastVideoInLesson, // Pasar flag de último video
      );
    }

    // Flujo normal para videos no precargados
    if (_isLoading) {
      return Stack(
        children: [
          // Pantalla de carga visible
          VideoLoadingWidget(
            videoTitle: widget.video.title,
            thumbnailUrl: 'assets/mini_videos/${widget.video.imageName}',
            onVideoReady: _isVideoReady,
          ),

          // Reproductor inicializándose en segundo plano (invisible)
          if (_hasInitialized)
            Positioned(
              left: -1000, // Fuera de la pantalla
              child: SizedBox(
                width: 1,
                height: 1,
                child: AdvancedVideoPlayer(
                  video: widget.video,
                  onVideoCompleted: () {
                    _showCompletionDialog();
                  },
                  onVideoReady: _onVideoReady,
                  isPreloaded: false,
                  isLastVideoInLesson:
                      widget.isLastVideoInLesson, // Pasar flag de último video
                ),
              ),
            ),
        ],
      );
    }

    return AdvancedVideoPlayer(
      video: widget.video,
      onVideoCompleted: () {
        _showCompletionDialog();
      },
      onVideoReady: _onVideoReady,
      isPreloaded: false,
      isLastVideoInLesson:
          widget.isLastVideoInLesson, // Pasar flag de último video
    );
  }

  void _showCompletionDialog() {
    // Ya no mostramos el diálogo de completado
    // El comportamiento de auto-play se maneja en AdvancedVideoPlayer
  }
}
