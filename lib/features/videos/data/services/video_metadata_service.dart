import 'package:get_it/get_it.dart';
import 'dynamic_video_service.dart';

/// Servicio para manejar metadata de videos vistos
class VideoMetadataService {
  final DynamicVideoService _dynamicVideoService;

  VideoMetadataService()
    : _dynamicVideoService = GetIt.instance<DynamicVideoService>();

  /// Registra que un video fue visto
  Future<void> recordVideoWatched(
    String userId,
    String videoId, {
    required int watchTime,
    required bool completed,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _dynamicVideoService.recordVideoWatched(
        userId,
        videoId,
        watchTime: watchTime,
        completed: completed,
        additionalData: additionalData,
      );
    } catch (e) {
      print('❌ Error registrando video visto: $e');
      rethrow;
    }
  }

  /// Registra una pausa en un video
  Future<void> recordVideoPause(
    String userId,
    String videoId, {
    required int pauseTime,
    required int resumeTime,
    String? reason,
  }) async {
    try {
      await _dynamicVideoService.recordVideoPause(
        userId,
        videoId,
        pauseTime: pauseTime,
        resumeTime: resumeTime,
        reason: reason,
      );
    } catch (e) {
      print('❌ Error registrando pausa: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas de videos del usuario
  Future<Map<String, dynamic>> getUserVideoStatistics(String userId) async {
    try {
      return await _dynamicVideoService.getUserVideoStatistics(userId);
    } catch (e) {
      print('❌ Error obteniendo estadísticas de videos: $e');
      return {};
    }
  }

  /// Verifica si un video fue completado
  Future<bool> isVideoCompleted(String userId, String videoId) async {
    try {
      return await _dynamicVideoService.isVideoCompleted(userId, videoId);
    } catch (e) {
      print('❌ Error verificando si video fue completado: $e');
      return false;
    }
  }

  /// Obtiene el progreso de un video específico
  Future<Map<String, dynamic>?> getVideoProgress(
    String userId,
    String videoId,
  ) async {
    try {
      return await _dynamicVideoService.getVideoProgress(userId, videoId);
    } catch (e) {
      print('❌ Error obteniendo progreso del video: $e');
      return null;
    }
  }

  /// Obtiene todos los videos vistos por el usuario
  Future<List<Map<String, dynamic>>> getUserWatchedVideos(String userId) async {
    try {
      return await _dynamicVideoService.getUserWatchedVideos(userId);
    } catch (e) {
      print('❌ Error obteniendo videos vistos: $e');
      return [];
    }
  }
}
