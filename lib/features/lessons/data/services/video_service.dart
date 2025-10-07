import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/video.dart';

class VideoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Video>> getVideos() async {
    try {
      // Obtener videos desde Firebase Firestore (sin ordenamiento para evitar índices)
      final QuerySnapshot snapshot = await _firestore
          .collection('videos')
          .get();

      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Video(
          videoId: data['id'] ?? 0,
          leccionId: data['numero_leccion'] ?? 0,
          videoURL: data['url'] ?? '',
          imageName: data['imagen'] ?? '',
          title: data['title'] ?? '',
          description:
              data['title'] ?? '', // Usar el título como descripción por ahora
          duration: Duration(seconds: data['duracion'] ?? 0),
          progress: 0.0,
          isCompleted: false,
        );
      }).toList();

      // Ordenar los videos por lección y luego por ID
      videos.sort((a, b) {
        if (a.leccionId != b.leccionId) {
          return a.leccionId.compareTo(b.leccionId);
        }
        return a.videoId.compareTo(b.videoId);
      });

      return videos;
    } catch (e) {
      print('Error al obtener videos desde Firebase: $e');
      // En caso de error, devolver lista vacía
      return [];
    }
  }

  // Método para obtener videos por lección específica
  static Future<List<Video>> getVideosByLesson(int lessonNumber) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('videos')
          .where('numero_leccion', isEqualTo: lessonNumber)
          .get();

      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Video(
          videoId: data['id'] ?? 0,
          leccionId: data['numero_leccion'] ?? 0,
          videoURL: data['url'] ?? '',
          imageName: data['imagen'] ?? '',
          title: data['title'] ?? '',
          description: data['title'] ?? '',
          duration: Duration(seconds: data['duracion'] ?? 0),
          progress: 0.0,
          isCompleted: false,
        );
      }).toList();

      // Ordenar por ID
      videos.sort((a, b) => a.videoId.compareTo(b.videoId));

      return videos;
    } catch (e) {
      print('Error al obtener videos de la lección $lessonNumber: $e');
      return [];
    }
  }

  // Método para obtener un video específico por ID
  static Future<Video?> getVideoById(int videoId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('videos')
          .where('id', isEqualTo: videoId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return Video(
          videoId: data['id'] ?? 0,
          leccionId: data['numero_leccion'] ?? 0,
          videoURL: data['url'] ?? '',
          imageName: data['imagen'] ?? '',
          title: data['title'] ?? '',
          description: data['title'] ?? '',
          duration: Duration(seconds: data['duracion'] ?? 0),
          progress: 0.0,
          isCompleted: false,
        );
      }
      return null;
    } catch (e) {
      print('Error al obtener video con ID $videoId: $e');
      return null;
    }
  }
}
