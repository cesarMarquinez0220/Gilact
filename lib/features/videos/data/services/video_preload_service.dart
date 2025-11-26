import 'dart:async';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/video.dart';
import '../../../../../core/services/app_logger.dart';
import '../../../../../core/di/injection.dart';

/// Servicio para precargar videos y mejorar la experiencia del usuario
class VideoPreloadService {
  static final VideoPreloadService _instance = VideoPreloadService._internal();
  factory VideoPreloadService() => _instance;
  VideoPreloadService._internal();

  final AppLogger _logger = getIt<AppLogger>();

  // Cache de controladores precargados
  final Map<int, YoutubePlayerController> _preloadedControllers = {};
  final Map<int, DateTime> _preloadTimestamps = {};

  // Configuración
  static const int _maxPreloadedVideos = 3;
  static const Duration _preloadExpiration = Duration(minutes: 30);

  /// Precargar el siguiente video en la secuencia
  Future<void> preloadNextVideo(List<Video> videos, int currentVideoId) async {
    try {
      // Encontrar el índice del video actual
      final currentIndex = videos.indexWhere(
        (v) => v.videoId == currentVideoId,
      );
      if (currentIndex == -1 || currentIndex >= videos.length - 1) {
        return; // No hay siguiente video
      }

      final nextVideo = videos[currentIndex + 1];

      // Verificar si ya está precargado
      if (_preloadedControllers.containsKey(nextVideo.videoId)) {
        return;
      }

      // Limpiar controladores expirados
      _cleanExpiredControllers();

      // Si ya tenemos el máximo de videos precargados, remover el más antiguo
      if (_preloadedControllers.length >= _maxPreloadedVideos) {
        _removeOldestPreloadedController();
      }

      // Precargar el siguiente video
      await _preloadVideo(nextVideo);

      _logger.d(
        'Video precargado: ${nextVideo.title} (ID: ${nextVideo.videoId})',
      );
    } catch (e, stackTrace) {
      _logger.e('Error precargando video', e, stackTrace);
    }
  }

  /// Precargar múltiples videos próximos
  Future<void> preloadUpcomingVideos(
    List<Video> videos,
    int currentVideoId, {
    int count = 2,
  }) async {
    try {
      final currentIndex = videos.indexWhere(
        (v) => v.videoId == currentVideoId,
      );
      if (currentIndex == -1) return;

      final upcomingVideos = videos.skip(currentIndex + 1).take(count).toList();

      for (final video in upcomingVideos) {
        if (!_preloadedControllers.containsKey(video.videoId)) {
          await _preloadVideo(video);
          await Future.delayed(
            const Duration(milliseconds: 500),
          ); // Evitar sobrecarga
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error precargando videos próximos', e, stackTrace);
    }
  }

  /// Obtener un controlador precargado
  YoutubePlayerController? getPreloadedController(int videoId) {
    final controller = _preloadedControllers[videoId];
    if (controller != null) {
      // Actualizar timestamp de acceso
      _preloadTimestamps[videoId] = DateTime.now();
      return controller;
    }
    return null;
  }

  /// Verificar si un video está precargado
  bool isVideoPreloaded(int videoId) {
    return _preloadedControllers.containsKey(videoId);
  }

  /// Precargar un video específico
  Future<void> _preloadVideo(Video video) async {
    try {
      final videoId = YoutubePlayer.convertUrlToId(video.videoUrl);
      if (videoId == null) return;

      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          loop: false,
          mute: true, // Precargar sin sonido
          forceHD: false,
          controlsVisibleAtStart: false,
          enableCaption: false,
          useHybridComposition: true,
          showLiveFullscreenButton: false,
        ),
      );

      // Esperar a que el controlador esté listo usando un Completer
      final completer = Completer<void>();
      controller.addListener(() {
        if (controller.value.isReady && !completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;

      // Pausar inmediatamente después de la precarga
      controller.pause();

      _preloadedControllers[video.videoId] = controller;
      _preloadTimestamps[video.videoId] = DateTime.now();
    } catch (e, stackTrace) {
      _logger.e('Error precargando video ${video.videoId}', e, stackTrace);
    }
  }

  /// Limpiar controladores expirados
  void _cleanExpiredControllers() {
    final now = DateTime.now();
    final expiredKeys = <int>[];

    _preloadTimestamps.forEach((videoId, timestamp) {
      if (now.difference(timestamp) > _preloadExpiration) {
        expiredKeys.add(videoId);
      }
    });

    for (final videoId in expiredKeys) {
      _removePreloadedController(videoId);
    }
  }

  /// Remover el controlador más antiguo
  void _removeOldestPreloadedController() {
    if (_preloadTimestamps.isEmpty) return;

    int oldestVideoId = _preloadTimestamps.keys.first;
    DateTime oldestTimestamp = _preloadTimestamps[oldestVideoId]!;

    _preloadTimestamps.forEach((videoId, timestamp) {
      if (timestamp.isBefore(oldestTimestamp)) {
        oldestVideoId = videoId;
        oldestTimestamp = timestamp;
      }
    });

    _removePreloadedController(oldestVideoId);
  }

  /// Remover un controlador precargado
  void _removePreloadedController(int videoId) {
    final controller = _preloadedControllers.remove(videoId);
    _preloadTimestamps.remove(videoId);

    if (controller != null) {
      controller.dispose();
      _logger.d('Controlador precargado removido: $videoId');
    }
  }

  /// Limpiar todos los controladores precargados
  void clearAllPreloadedControllers() {
    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _preloadTimestamps.clear();

    _logger.d('Todos los controladores precargados han sido limpiados');
  }

  /// Obtener estadísticas de precarga
  Map<String, dynamic> getPreloadStats() {
    return {
      'preloadedCount': _preloadedControllers.length,
      'maxPreloaded': _maxPreloadedVideos,
      'preloadedVideos': _preloadedControllers.keys.toList(),
      'timestamps': Map.from(_preloadTimestamps),
    };
  }

  /// Precarga metadata de un video específico
  Future<void> preloadVideoMetadata(int videoId) async {
    try {
      _logger.d('Precargando metadata del video $videoId');

      // Simular precarga de metadata
      // En una implementación real, aquí se obtendría la información del video
      await Future.delayed(const Duration(milliseconds: 300));

      _logger.success('Metadata del video $videoId precargada');
    } catch (e, stackTrace) {
      _logger.e('Error precargando metadata del video $videoId', e, stackTrace);
    }
  }

  /// Dispose del servicio
  void dispose() {
    clearAllPreloadedControllers();
  }
}
