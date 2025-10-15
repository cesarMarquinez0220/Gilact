import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para manejar las interacciones del usuario con los videos
class VideoInteractionService {
  final FirebaseFirestore _firestore;

  VideoInteractionService(this._firestore);

  /// Crea la subcolección videos cuando el usuario inicia su primera lección
  Future<void> initializeVideosSubcollection(String userId, int videoId) async {
    try {
      print(
        '🎬 Inicializando subcolección videos para usuario: $userId, video: $videoId',
      );

      // Verificar si ya existe algún documento en la subcolección videos
      final videosCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos');

      final existingDocs = await videosCollection.limit(1).get();

      if (existingDocs.docs.isEmpty) {
        // Es la primera vez que el usuario inicia una lección
        print('🎬 Primera lección detectada, creando subcolección videos');

        // La subcolección se creará automáticamente al agregar el primer documento

        // Crear el primer registro de interacción
        await _createFirstVideoInteraction(userId, videoId);
      } else {
        print('ℹ️ Subcolección videos ya existe');
      }
    } catch (e) {
      print('❌ Error inicializando subcolección videos: $e');
      rethrow;
    }
  }

  /// Maneja la primera pausa de un video (actualiza registro existente)
  Future<void> handleFirstVideoPause(String userId, int videoId) async {
    try {
      print(
        '⏸️ Manejando primera pausa del video $videoId para usuario $userId',
      );

      // Verificar si ya existe algún documento en la subcolección videos
      final videosCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos');

      final existingDocs = await videosCollection.limit(1).get();

      if (existingDocs.docs.isEmpty) {
        // Si no existe, crear la subcolección (fallback)
        await initializeVideosSubcollection(userId, videoId);
      } else {
        print('ℹ️ Subcolección videos ya existe, registrando pausa');
        await _recordVideoInteraction(userId, videoId);
      }
    } catch (e) {
      print('❌ Error manejando primera pausa: $e');
      rethrow;
    }
  }

  /// Crea el primer registro de interacción con video
  Future<void> _createFirstVideoInteraction(String userId, int videoId) async {
    try {
      final videosCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos');

      // Usar el videoId como ID del documento (no 'video_$videoId')
      await videosCollection.doc(videoId.toString()).set({
        'videoId': videoId,
        'primeraPausa': Timestamp.fromDate(DateTime.now()),
        'contadorPausas': 1,
        'tiempoTotalVisto': 0,
        'ultimaPausa': Timestamp.fromDate(DateTime.now()),
        'estaCompletado': false,
        'fechaCreacion': Timestamp.fromDate(DateTime.now()),
        'fechaActualizacion': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Primer registro de interacción creado para video $videoId');
    } catch (e) {
      print('❌ Error creando primer registro de interacción: $e');
      rethrow;
    }
  }

  /// Registra una interacción con video (pausa, reanudación, etc.)
  Future<void> _recordVideoInteraction(String userId, int videoId) async {
    try {
      final videoDoc = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId.toString()); // Usar videoId como ID del documento

      final doc = await videoDoc.get();

      if (doc.exists) {
        // Actualizar registro existente
        final data = doc.data()!;
        final currentPauseCount = (data['contadorPausas'] as int? ?? 0) + 1;

        await videoDoc.update({
          'contadorPausas': currentPauseCount,
          'ultimaPausa': Timestamp.fromDate(DateTime.now()),
          'fechaActualizacion': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Crear nuevo registro
        await _createFirstVideoInteraction(userId, videoId);
      }

      print('📊 Interacción registrada para video $videoId');
    } catch (e) {
      print('❌ Error registrando interacción: $e');
      rethrow;
    }
  }

  /// Marca un video como completado con todos los campos necesarios
  Future<void> markVideoAsCompleted(String userId, int videoId) async {
    try {
      final videoDoc = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId.toString());

      // Obtener el documento actual para preservar campos existentes
      final currentDoc = await videoDoc.get();
      final currentData = currentDoc.data() ?? {};

      // Preparar datos completos para el video completado
      final now = DateTime.now();
      final videoData = {
        'videoId': videoId,
        'estaCompletado': true,
        'fechaCompletado': Timestamp.fromDate(now),
        'fechaActualizacion': Timestamp.fromDate(now),

        // Preservar campos existentes o usar valores por defecto
        'primeraPausa': currentData['primeraPausa'] ?? Timestamp.fromDate(now),
        'ultimaPausa': currentData['ultimaPausa'] ?? Timestamp.fromDate(now),
        'tiempoTotalVisto': currentData['tiempoTotalVisto'] ?? 0,
        'fechaCreacion':
            currentData['fechaCreacion'] ?? Timestamp.fromDate(now),
        'contadorPausas': currentData['contadorPausas'] ?? 0,
        'contadorAdelantos': currentData['contadorAdelantos'] ?? 0,
        'ultimaPosicion': currentData['ultimaPosicion'] ?? 0,
        'duracion': currentData['duracion'] ?? 0,
        'avance': currentData['avance'] ?? 1.0,
      };

      await videoDoc.set(videoData, SetOptions(merge: true));

      print('✅ Video $videoId marcado como completado con todos los campos');
    } catch (e) {
      print('❌ Error marcando video como completado: $e');
      rethrow;
    }
  }

  /// Obtiene el progreso de un video específico
  Future<Map<String, dynamic>?> getVideoProgress(
    String userId,
    int videoId,
  ) async {
    try {
      final doc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .doc(videoId.toString()) // Usar videoId como ID del documento
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo progreso del video: $e');
      return null;
    }
  }

  /// Obtiene todos los videos completados por el usuario
  Future<List<int>> getCompletedVideos(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos')
          .where('estaCompletado', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['videoId'] as int)
          .toList();
    } catch (e) {
      print('❌ Error obteniendo videos completados: $e');
      return [];
    }
  }

  /// Limpia documentos duplicados en la subcolección videos (solo para usuarios existentes)
  Future<void> cleanupDuplicateDocuments(String userId) async {
    try {
      print('🧹 Verificando documentos duplicados para usuario: $userId');

      final videosCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos');

      // Obtener todos los documentos
      final allDocs = await videosCollection.get();

      // Encontrar documentos duplicados y metadata
      final duplicatesToDelete = <String>[];

      for (final doc in allDocs.docs) {
        final docId = doc.id;

        if (docId.startsWith('video_') || docId == 'metadata') {
          // Es un documento duplicado o metadata innecesario
          duplicatesToDelete.add(docId);
        }
      }

      if (duplicatesToDelete.isNotEmpty) {
        // Solo eliminar si hay documentos duplicados
        for (final duplicateId in duplicatesToDelete) {
          await videosCollection.doc(duplicateId).delete();
          print('🗑️ Documento duplicado eliminado: $duplicateId');
        }
        print('✅ Limpieza de documentos duplicados completada');
      } else {
        print('ℹ️ No se encontraron documentos duplicados para limpiar');
      }
    } catch (e) {
      print('❌ Error limpiando documentos duplicados: $e');
    }
  }
}
