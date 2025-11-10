import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para manejar el progreso de videos con Firestore
/// Mantiene la funcionalidad específica del reproductor anterior
class VideoProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Caché para el ID del documento del usuario
  String? _cachedUserDocId;

  /// Obtiene el ID del documento del usuario en Firestore
  /// SIEMPRE busca por email primero para obtener el ID correcto del documento
  /// Solo usa UID como último recurso si no encuentra nada por email
  Future<String?> _getUserDocumentId() async {
    // Si tenemos caché, usarlo
    if (_cachedUserDocId != null) {
      return _cachedUserDocId;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ VideoProgressService: Usuario no autenticado');
        return null;
      }

      // PRIORIDAD 1: Buscar por email (el ID del documento del usuario)
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          _cachedUserDocId = userQuery.docs.first.id;
          print(
            '✅ VideoProgressService: Usuario encontrado por email, ID del documento: $_cachedUserDocId',
          );
          return _cachedUserDocId;
        } else {
          print(
            '⚠️ VideoProgressService: No se encontró usuario por email: ${user.email}',
          );
        }
      } else {
        print('⚠️ VideoProgressService: Usuario no tiene email');
      }

      // PRIORIDAD 2: Intentar con UID solo si no se encontró por email
      // (Esto puede crear documentos en el lugar incorrecto, pero es un fallback)
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        print(
          '⚠️ VideoProgressService: Usando UID como fallback (no recomendado): ${user.uid}',
        );
        _cachedUserDocId = user.uid;
        return user.uid;
      }

      print('❌ VideoProgressService: No se encontró usuario en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
    }
  }

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

      // Obtener el ID del documento del usuario en Firestore (no el UID de Firebase Auth)
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        print(
          '❌ VideoProgressService: No se pudo obtener el ID del documento del usuario',
        );
        return;
      }

      final userDocRef = _firestore.collection('Users').doc(userDocId);
      final videoDocRef = userDocRef
          .collection('videos')
          .doc(videoId.toString());

      print(
        '📊 VideoProgressService: Guardando progreso en /Users/$userDocId/videos/$videoId',
      );

      final videoData = {
        'videoId':
            videoId, // Asegurar que el videoId esté presente para identificarlo
        'contadorPausas': pauseCount,
        'contadorAdelantos': forwardCount,
        'ultimaPosicion': lastPosition,
        'duracion': totalDuration,
        'avance': progress,
        'estaCompletado': isCompleted,
        'fechaActualizacion': FieldValue.serverTimestamp(),
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

      // Obtener el ID del documento del usuario en Firestore (no el UID de Firebase Auth)
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        return {};
      }

      final userDocRef = _firestore.collection('Users').doc(userDocId);
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
    return progress['estaCompletado'] ?? false;
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

      // Obtener el ID del documento del usuario en Firestore (no el UID de Firebase Auth)
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        return {};
      }

      final userDocRef = _firestore.collection('Users').doc(userDocId);

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
        'totalPausas': videoData['contadorPausas'] ?? 0,
        'contadorVisualizaciones': videoData['contadorVisualizaciones'] ?? 0,
        'ultimaPosicion': videoData['ultimaPosicion'] ?? 0,
        'avance': videoData['avance'] ?? 0.0,
        'estaCompletado': videoData['estaCompletado'] ?? false,
      };
    } catch (error) {
      print('Error al obtener estadísticas del video: $error');
      return {};
    }
  }
}
