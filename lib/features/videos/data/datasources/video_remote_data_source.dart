import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/video_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<VideoModel> getVideoById(String id);
  Future<List<VideoModel>> getVideosByLessonId(String lessonId);
  Future<List<VideoModel>> searchVideos(String query);
  Future<void> markVideoAsCompleted(String videoId);
  Future<List<String>> getCompletedVideoIds();
  Future<void> updateVideoProgress({
    required String videoId,
    required Duration currentPosition,
  });
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final FirebaseFirestore _firestore;

  VideoRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .orderBy('numero_leccion')
          .get();

      final videos = querySnapshot.docs
          .map((doc) => VideoModel.fromQueryDocument(doc))
          .toList();

      // Ordenar por número de imagen para mantener el orden correcto
      videos.sort((a, b) {
        double imageNumberA = _extractImageNumber(a.imageName);
        double imageNumberB = _extractImageNumber(b.imageName);
        return imageNumberA.compareTo(imageNumberB);
      });

      return videos;
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener videos: ${e.toString()}',
      );
    }
  }

  @override
  Future<VideoModel> getVideoById(String id) async {
    try {
      final doc = await _firestore.collection('videos').doc(id).get();

      if (!doc.exists) {
        throw const ServerException(message: 'Video no encontrado');
      }

      return VideoModel.fromDocument(doc);
    } catch (e) {
      throw ServerException(message: 'Error al obtener video: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByLessonId(String lessonId) async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .where('numero_leccion', isEqualTo: int.parse(lessonId))
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => VideoModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener videos por lección: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return querySnapshot.docs
          .map((doc) => VideoModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar videos: ${e.toString()}');
    }
  }

  @override
  Future<void> markVideoAsCompleted(String videoId) async {
    try {
      // Aquí necesitarías obtener el usuario actual
      // Por ahora, asumimos que tienes acceso al usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      await user.collection('videos').doc(videoId).set({
        'completado': true,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(
        message: 'Error al marcar video como completado: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getCompletedVideoIds() async {
    try {
      // Aquí necesitarías obtener el usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      final querySnapshot = await user
          .collection('videos')
          .where('completado', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener videos completados: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateVideoProgress({
    required String videoId,
    required Duration currentPosition,
  }) async {
    try {
      // Aquí necesitarías obtener el usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      await user.collection('videos').doc(videoId).update({
        'currentPosition': currentPosition.inSeconds,
        'lastWatched': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar progreso: ${e.toString()}',
      );
    }
  }

  // Método auxiliar para extraer número de imagen
  double _extractImageNumber(String imageName) {
    try {
      String withoutExtension = imageName.replaceAll('.png', '');

      if (withoutExtension.contains('.')) {
        return double.parse(withoutExtension);
      } else {
        return double.parse(withoutExtension);
      }
    } catch (e) {
      return 999.0; // Poner al final si hay error
    }
  }
}
