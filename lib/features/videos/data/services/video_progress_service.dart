import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para manejar el progreso de videos con Firestore
/// Mantiene la funcionalidad específica del reproductor anterior
class VideoProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Guarda información detallada del video en Firestore
  Future<void> saveVideoProgress({
    required int videoId,
    required int pauseCount,
    required int forwardCount,
    required int lastPosition,
    required int totalDuration,
    required double progress,
    required bool isCompleted,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDocRef = _firestore.collection('Users').doc(user.uid);
      final videoDocRef = userDocRef
          .collection('videos')
          .doc(videoId.toString());

      final videoData = {
        'pausas': pauseCount,
        'adelantos': forwardCount,
        'ultimaPosicion': lastPosition,
        'duracion': totalDuration,
        'avance': progress,
        'completado': isCompleted,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      };

      // Si el video está completado, incrementar contador de visualizaciones
      if (isCompleted) {
        final videoDoc = await videoDocRef.get();
        final currentCount = videoDoc.data()?['contadorVisualizaciones'] ?? 0;
        videoData['contadorVisualizaciones'] = currentCount + 1;
      }

      await videoDocRef.set(videoData, SetOptions(merge: true));

      // Guardar información de adelantos en colección separada
      if (forwardCount > 0) {
        await userDocRef.collection('adelantosvideo').add({
          'videoId': videoId,
          'adelantos': forwardCount,
          'milisegundoRetrocedido': lastPosition,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      print('Información del video guardada con éxito en Firestore');
    } catch (error) {
      print('Error al guardar información en Firestore: $error');
    }
  }

  /// Obtiene la información del progreso del video desde Firestore
  Future<Map<String, dynamic>> getVideoProgress(int videoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final userDocRef = _firestore.collection('Users').doc(user.uid);
      final videoDoc = await userDocRef
          .collection('videos')
          .doc(videoId.toString())
          .get();

      if (videoDoc.exists) {
        return videoDoc.data() as Map<String, dynamic>;
      }
    } catch (error) {
      print('Error al obtener información del video en Firestore: $error');
    }

    return {};
  }

  /// Obtiene la última posición del video
  Future<int> getLastPosition(int videoId) async {
    final progress = await getVideoProgress(videoId);
    return progress['ultimaPosicion'] ?? 0;
  }

  /// Verifica si el video está completado
  Future<bool> isVideoCompleted(int videoId) async {
    final progress = await getVideoProgress(videoId);
    return progress['completado'] ?? false;
  }

  /// Obtiene el progreso del video como porcentaje
  Future<double> getVideoProgressPercentage(int videoId) async {
    final progress = await getVideoProgress(videoId);
    return (progress['avance'] ?? 0.0).toDouble();
  }

  /// Obtiene estadísticas del video
  Future<Map<String, dynamic>> getVideoStatistics(int videoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final userDocRef = _firestore.collection('Users').doc(user.uid);

      // Obtener información del video
      final videoDoc = await userDocRef
          .collection('videos')
          .doc(videoId.toString())
          .get();

      // Obtener información de adelantos
      final adelantosQuery = await userDocRef
          .collection('adelantosvideo')
          .where('videoId', isEqualTo: videoId)
          .get();

      final videoData = videoDoc.exists ? videoDoc.data()! : {};
      final adelantosData = adelantosQuery.docs
          .map((doc) => doc.data())
          .toList();

      return {
        'videoData': videoData,
        'adelantosData': adelantosData,
        'totalAdelantos': adelantosData.length,
        'totalPausas': videoData['pausas'] ?? 0,
        'contadorVisualizaciones': videoData['contadorVisualizaciones'] ?? 0,
        'ultimaPosicion': videoData['ultimaPosicion'] ?? 0,
        'avance': videoData['avance'] ?? 0.0,
        'completado': videoData['completado'] ?? false,
      };
    } catch (error) {
      print('Error al obtener estadísticas del video: $error');
      return {};
    }
  }
}
