import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/video.dart';
import '../widgets/advanced_video_player.dart';
import '../../data/services/video_cache_service.dart';
import '../../data/services/video_preload_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final String userId;
  final bool isLastVideoInLesson; // Nuevo parámetro
  final bool isFromHistory; // Parámetro para indicar si viene del historial

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.userId,
    this.isLastVideoInLesson = false, // Por defecto false
    this.isFromHistory = false, // Por defecto false
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
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
              true; // Siempre auto-rotar para experiencia fluida
        });

        print(
          '🎬 Video ${widget.video.videoId} precargado: $_isVideoPreloaded',
        );

        // Siempre ir directo al reproductor sin pantalla de carga
        _initializeVideoDirectly();
      }
    } catch (e) {
      print('Error verificando precarga: $e');
      // En caso de error, ir directo al reproductor
      _initializeVideoDirectly();
    }
  }

  Future<void> _initializeVideoDirectly() async {
    // Ir directo al reproductor con auto-rotación
    if (mounted) {
      // Auto-rotar a horizontal para experiencia tipo Netflix
      if (_shouldAutoRotate) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
  }

  void _onVideoReady() {
    if (mounted) {
      print('🎬 Video ${widget.video.videoId} listo para reproducir');
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
    // Siempre mostrar directamente el reproductor sin pantalla de carga
    return AdvancedVideoPlayer(
      video: widget.video,
      onVideoCompleted: () {
        _showCompletionDialog();
      },
      onVideoReady: _onVideoReady,
      isPreloaded: _isVideoPreloaded,
      isLastVideoInLesson: widget.isLastVideoInLesson,
      isFromHistory: widget.isFromHistory,
    );
  }

  void _showCompletionDialog() {
    // Ya no mostramos el diálogo de completado
    // El comportamiento de auto-play se maneja en AdvancedVideoPlayer
  }
}
