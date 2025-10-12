import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Servicio para manejar la subcolección de videos dinámicamente
@singleton
class DynamicVideoService {
  final FirebaseFirestore _firestore;

  DynamicVideoService(this._firestore);

  /// Inicializa la subcolección de videos para un usuario (se llama la primera vez que ve un video)
  Future<void> _initializeVideosSubcollection(String userId) async {
    try {
      // Verificar si ya existe la subcolección
      final metadataDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc('metadata')
          .get();

      if (!metadataDoc.exists) {
        // Crear metadata inicial
        await _firestore
            .collection('Users')
            .doc(userId)
            .collection('videos')
            .doc('metadata')
            .set({
              'createdAt': Timestamp.fromDate(DateTime.now()),
              'type': 'metadata',
              'description': 'Metadata de videos vistos por el usuario',
              'totalVideosWatched': 0,
              'lastVideoWatched': null,
              'totalWatchTime': 0, // en segundos
              'firstVideoWatchedAt': null,
            });

        print('📹 Subcolección videos inicializada para usuario: $userId');
      }
    } catch (e) {
      print('❌ Error inicializando subcolección de videos: $e');
      rethrow;
    }
  }

  /// Registra que un video fue visto (crea la subcolección si no existe)
  Future<void> recordVideoWatched(
    String userId,
    String videoId, {
    required int watchTime,
    required bool completed,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Inicializar subcolección si no existe
      await _initializeVideosSubcollection(userId);

      final batch = _firestore.batch();

      // Crear/actualizar documento del video visto
      final videoRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId);

      // Verificar si ya existe el documento del video
      final existingVideo = await videoRef.get();

      if (existingVideo.exists) {
        // Actualizar documento existente
        final existingData = existingVideo.data()!;
        final currentWatchTime = existingData['watchTime'] as int? ?? 0;
        final currentCompleted = existingData['completed'] as bool? ?? false;

        batch.update(videoRef, {
          'watchTime': currentWatchTime + watchTime,
          'completed': currentCompleted || completed,
          'lastWatchedAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'additionalData': {
            ...existingData['additionalData'] as Map<String, dynamic>? ?? {},
            ...additionalData ?? {},
          },
        });
      } else {
        // Crear nuevo documento
        batch.set(videoRef, {
          'videoId': videoId,
          'firstWatchedAt': Timestamp.fromDate(DateTime.now()),
          'lastWatchedAt': Timestamp.fromDate(DateTime.now()),
          'watchTime': watchTime,
          'completed': completed,
          'additionalData': additionalData ?? {},
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // Actualizar metadata general
      final metadataRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc('metadata');

      // Obtener metadata actual para actualizar contadores
      final metadataDoc = await metadataRef.get();
      final currentMetadata = metadataDoc.data() ?? {};
      final currentTotalWatchTime =
          currentMetadata['totalWatchTime'] as int? ?? 0;
      final currentTotalVideos =
          currentMetadata['totalVideosWatched'] as int? ?? 0;

      batch.update(metadataRef, {
        'lastVideoWatched': videoId,
        'lastWatchTime': Timestamp.fromDate(DateTime.now()),
        'totalWatchTime': currentTotalWatchTime + watchTime,
        'totalVideosWatched': existingVideo.exists
            ? currentTotalVideos
            : currentTotalVideos + 1,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (!existingVideo.exists)
          'firstVideoWatchedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
      print('✅ Video registrado exitosamente: $videoId (${watchTime}s)');
    } catch (e) {
      print('❌ Error registrando video: $e');
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
      await _initializeVideosSubcollection(userId);

      final pauseRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId)
          .collection('pauses')
          .doc();

      await pauseRef.set({
        'pauseTime': pauseTime,
        'resumeTime': resumeTime,
        'duration': resumeTime - pauseTime,
        'reason': reason,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      print('⏸️ Pausa registrada para video: $videoId');
    } catch (e) {
      print('❌ Error registrando pausa: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas de videos del usuario
  Future<Map<String, dynamic>> getUserVideoStatistics(String userId) async {
    try {
      final metadataDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc('metadata')
          .get();

      if (!metadataDoc.exists) {
        return {
          'totalVideosWatched': 0,
          'totalWatchTime': 0,
          'lastVideoWatched': null,
          'lastWatchTime': null,
          'completionRate': 0,
        };
      }

      final metadata = metadataDoc.data()!;

      // Obtener videos completados
      final completedVideos = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .where('completed', isEqualTo: true)
          .get();

      return {
        'totalVideosWatched': metadata['totalVideosWatched'] ?? 0,
        'totalWatchTime': metadata['totalWatchTime'] ?? 0,
        'lastVideoWatched': metadata['lastVideoWatched'],
        'lastWatchTime': metadata['lastWatchTime'],
        'firstVideoWatchedAt': metadata['firstVideoWatchedAt'],
        'completedVideos': completedVideos.docs.length,
        'completionRate': completedVideos.docs.length,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas de videos: $e');
      return {};
    }
  }

  /// Verifica si un video fue completado
  Future<bool> isVideoCompleted(String userId, String videoId) async {
    try {
      final videoDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId)
          .get();

      if (videoDoc.exists) {
        return videoDoc.data()?['completed'] as bool? ?? false;
      }
      return false;
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
      final videoDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId)
          .get();

      if (videoDoc.exists) {
        final data = videoDoc.data()!;
        return {
          'videoId': videoId,
          'watchTime': data['watchTime'] ?? 0,
          'completed': data['completed'] ?? false,
          'firstWatchedAt': data['firstWatchedAt'],
          'lastWatchedAt': data['lastWatchedAt'],
          'additionalData': data['additionalData'] ?? {},
        };
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo progreso del video: $e');
      return null;
    }
  }

  /// Obtiene todos los videos vistos por el usuario
  Future<List<Map<String, dynamic>>> getUserWatchedVideos(String userId) async {
    try {
      final videosSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .where('videoId', isNotEqualTo: null)
          .orderBy('lastWatchedAt', descending: true)
          .get();

      return videosSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'videoId': data['videoId'],
          'watchTime': data['watchTime'] ?? 0,
          'completed': data['completed'] ?? false,
          'firstWatchedAt': data['firstWatchedAt'],
          'lastWatchedAt': data['lastWatchedAt'],
          'additionalData': data['additionalData'] ?? {},
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo videos vistos: $e');
      return [];
    }
  }
}
