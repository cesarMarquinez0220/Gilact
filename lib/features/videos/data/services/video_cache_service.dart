import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for compute
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

class VideoCacheService {
  static const String _cacheKey = 'video_cache';
  static const String _progressKey = 'video_progress_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);

  // Helper functions for compute
  static Map<String, dynamic> _decodeMap(String json) => jsonDecode(json) as Map<String, dynamic>;
  static String _encodeMap(Map<String, dynamic> map) => jsonEncode(map);

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
        cache = await compute(_decodeMap, existingCache);
      }

      cache[videoId.toString()] = cacheData;
      await prefs.setString(_cacheKey, await compute(_encodeMap, cache));
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error caching video info', e, stackTrace);
    }
  }

  // Obtener información del video desde caché
  static Future<Map<String, dynamic>?> getCachedVideoInfo(int videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);

      if (cacheData != null) {
        final cache = await compute(_decodeMap, cacheData);
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
            await prefs.setString(_cacheKey, await compute(_encodeMap, cache));
          }
        }
      }
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error getting cached video info', e, stackTrace);
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
        cache = await compute(_decodeMap, existingCache);
      }

      cache[videoId.toString()] = progressData;
      await prefs.setString(_progressKey, await compute(_encodeMap, cache));
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error caching video progress', e, stackTrace);
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
        final cache = await compute(_decodeMap, cacheData);
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
            await prefs.setString(_progressKey, await compute(_encodeMap, cache));
          }
        }
      }
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error getting cached video progress', e, stackTrace);
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
        final cache = await compute(_decodeMap, videoCacheData);
        final now = DateTime.now();

        cache.removeWhere((key, value) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            value['cachedAt'] as int,
          );
          return now.difference(cachedAt) > _cacheExpiration;
        });

        await prefs.setString(_cacheKey, await compute(_encodeMap, cache));
      }

      // Limpiar caché de progreso
      final progressCacheData = prefs.getString(_progressKey);
      if (progressCacheData != null) {
        final cache = await compute(_decodeMap, progressCacheData);
        final now = DateTime.now();

        cache.removeWhere((key, value) {
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(
            value['cachedAt'] as int,
          );
          return now.difference(cachedAt) > const Duration(hours: 1);
        });

        await prefs.setString(_progressKey, await compute(_encodeMap, cache));
      }
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error cleaning expired cache', e, stackTrace);
    }
  }

  // Limpiar todo el caché
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_progressKey);
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error clearing all cache', e, stackTrace);
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
        final cache = await compute(_decodeMap, videoCacheData);
        videoCacheCount = cache.length;
      }

      final progressCacheData = prefs.getString(_progressKey);
      if (progressCacheData != null) {
        final cache = await compute(_decodeMap, progressCacheData);
        progressCacheCount = cache.length;
      }

      return {
        'videoCacheCount': videoCacheCount,
        'progressCacheCount': progressCacheCount,
      };
    } catch (e, stackTrace) {
      final logger = getIt<AppLogger>();
      logger.e('Error getting cache stats', e, stackTrace);
      return {'videoCacheCount': 0, 'progressCacheCount': 0};
    }
  }

  /// Precarga un video de YouTube resolviendo su URL directa
  static Future<void> preloadVideoSegment(
    int videoId,
    String videoUrl, {
    int duration = 30,
  }) async {
    final logger = getIt<AppLogger>();
    try {
      if (videoUrl.isEmpty) return;
      
      logger.d('Iniciando precarga para video $videoId ($videoUrl)');

      // 1. Extraer ID y obtener URL del stream directo
      final ytId = yt.VideoId(videoUrl);
      final ytExplode = yt.YoutubeExplode();
      
      try {
        final manifest = await ytExplode.videos.streamsClient.getManifest(ytId);
        final streamInfo = manifest.muxed.withHighestBitrate();
        final streamUrl = streamInfo.url.toString();

        logger.d('URL directa obtenida, iniciando descarga..');

        // 2. Descargar y cachear usando videoId como key
        await DefaultCacheManager().getSingleFile(streamUrl, key: videoId.toString());

        // 3. Guardar metadatos
        final prefs = await SharedPreferences.getInstance();
        final preloadKey = 'preload_$videoId';
        final preloadData = {
          'videoId': videoId,
          'originalUrl': videoUrl,
          'streamUrl': streamUrl,
          'preloadedAt': DateTime.now().millisecondsSinceEpoch,
          'isFullDownload': true,
        };

        await prefs.setString(preloadKey, jsonEncode(preloadData));

        logger.success('Video $videoId precargado exitosamente en cache');
      } finally {
        ytExplode.close();
      }
    } catch (e, stackTrace) {
      logger.e('Error precargando video $videoId', e, stackTrace);
    }
  }

  /// Obtiene el archivo de video desde el cache usando el videoId como key
  static Future<FileInfo?> getCachedVideoFile(int videoId) async {
    try {
      return await DefaultCacheManager().getFileFromCache(videoId.toString());
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un video está precargado
  static Future<bool> isVideoPreloaded(int videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preloadKey = 'preload_$videoId';
      final preloadData = prefs.getString(preloadKey);

      if (preloadData == null) return false;

      final data = await compute(_decodeMap, preloadData);
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
