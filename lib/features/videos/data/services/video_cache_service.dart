import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VideoCacheService {
  static const String _cacheKey = 'video_cache';
  static const String _progressKey = 'video_progress_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);

  // Cachear información del video
  static Future<void> cacheVideoInfo({
    required int videoId,
    required String title,
    required String thumbnailUrl,
    required int duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final existingCache = prefs.getString(_cacheKey);
      Map<String, dynamic> cache = {};

      if (existingCache != null) {
        cache = jsonDecode(existingCache);
      }

      cache[videoId.toString()] = cacheData;
      await prefs.setString(_cacheKey, jsonEncode(cache));
    } catch (e) {
      print('Error caching video info: $e');
    }
  }

  // Obtener información del video desde caché
  static Future<Map<String, dynamic>?> getCachedVideoInfo(int videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);

      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        final videoData = cache[videoId.toString()];

        if (videoData != null) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            videoData['cachedAt'] as int,
          );

          // Verificar si el caché no ha expirado
          if (DateTime.now().difference(cachedAt) < _cacheExpiration) {
            return videoData;
          } else {
            // Eliminar caché expirado
            cache.remove(videoId.toString());
            await prefs.setString(_cacheKey, jsonEncode(cache));
          }
        }
      }
    } catch (e) {
      print('Error getting cached video info: $e');
    }
    return null;
  }

  // Cachear progreso del video
  static Future<void> cacheVideoProgress({
    required int videoId,
    required double progress,
    required int lastPosition,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'videoId': videoId,
        'progress': progress,
        'lastPosition': lastPosition,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final existingCache = prefs.getString(_progressKey);
      Map<String, dynamic> cache = {};

      if (existingCache != null) {
        cache = jsonDecode(existingCache);
      }

      cache[videoId.toString()] = progressData;
      await prefs.setString(_progressKey, jsonEncode(cache));
    } catch (e) {
      print('Error caching video progress: $e');
    }
  }

  // Obtener progreso del video desde caché
  static Future<Map<String, dynamic>?> getCachedVideoProgress(
    int videoId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_progressKey);

      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        final progressData = cache[videoId.toString()];

        if (progressData != null) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            progressData['cachedAt'] as int,
          );

          // Verificar si el caché no ha expirado (1 hora para progreso)
          if (DateTime.now().difference(cachedAt) < const Duration(hours: 1)) {
            return progressData;
          } else {
            // Eliminar caché expirado
            cache.remove(videoId.toString());
            await prefs.setString(_progressKey, jsonEncode(cache));
          }
        }
      }
    } catch (e) {
      print('Error getting cached video progress: $e');
    }
    return null;
  }

  // Limpiar caché expirado
  static Future<void> cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Limpiar caché de videos
      final videoCacheData = prefs.getString(_cacheKey);
      if (videoCacheData != null) {
        final cache = jsonDecode(videoCacheData) as Map<String, dynamic>;
        final now = DateTime.now();

        cache.removeWhere((key, value) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            value['cachedAt'] as int,
          );
          return now.difference(cachedAt) > _cacheExpiration;
        });

        await prefs.setString(_cacheKey, jsonEncode(cache));
      }

      // Limpiar caché de progreso
      final progressCacheData = prefs.getString(_progressKey);
      if (progressCacheData != null) {
        final cache = jsonDecode(progressCacheData) as Map<String, dynamic>;
        final now = DateTime.now();

        cache.removeWhere((key, value) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            value['cachedAt'] as int,
          );
          return now.difference(cachedAt) > const Duration(hours: 1);
        });

        await prefs.setString(_progressKey, jsonEncode(cache));
      }
    } catch (e) {
      print('Error cleaning expired cache: $e');
    }
  }

  // Limpiar todo el caché
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_progressKey);
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  // Obtener estadísticas del caché
  static Future<Map<String, int>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int videoCacheCount = 0;
      int progressCacheCount = 0;

      final videoCacheData = prefs.getString(_cacheKey);
      if (videoCacheData != null) {
        final cache = jsonDecode(videoCacheData) as Map<String, dynamic>;
        videoCacheCount = cache.length;
      }

      final progressCacheData = prefs.getString(_progressKey);
      if (progressCacheData != null) {
        final cache = jsonDecode(progressCacheData) as Map<String, dynamic>;
        progressCacheCount = cache.length;
      }

      return {
        'videoCacheCount': videoCacheCount,
        'progressCacheCount': progressCacheCount,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {'videoCacheCount': 0, 'progressCacheCount': 0};
    }
  }

  /// Precarga un segmento del video en cache
  static Future<void> preloadVideoSegment(
    int videoId, {
    int duration = 30,
  }) async {
    try {
      print('📹 Precargando segmento de video $videoId (${duration}s)');

      // Simular precarga del segmento
      // En una implementación real, aquí se descargaría el segmento del video
      await Future.delayed(Duration(milliseconds: 500));

      // Guardar información de precarga
      final prefs = await SharedPreferences.getInstance();
      final preloadKey = 'preload_$videoId';
      final preloadData = {
        'videoId': videoId,
        'duration': duration,
        'preloadedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(preloadKey, jsonEncode(preloadData));

      print('✅ Segmento de video $videoId precargado exitosamente');
    } catch (e) {
      print('❌ Error precargando segmento de video $videoId: $e');
    }
  }

  /// Verifica si un video está precargado
  static Future<bool> isVideoPreloaded(int videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preloadKey = 'preload_$videoId';
      final preloadData = prefs.getString(preloadKey);

      if (preloadData == null) return false;

      final data = jsonDecode(preloadData) as Map<String, dynamic>;
      final preloadedAt = DateTime.fromMillisecondsSinceEpoch(
        data['preloadedAt'],
      );
      final now = DateTime.now();

      // Verificar si la precarga no ha expirado (1 hora)
      return now.difference(preloadedAt).inHours < 1;
    } catch (e) {
      return false;
    }
  }
}
