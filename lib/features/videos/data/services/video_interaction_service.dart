import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Servicio para manejar las interacciones del usuario con los videos
class VideoInteractionService {
  final FirebaseFirestore _firestore;
  final AppLogger _logger = getIt<AppLogger>();

  VideoInteractionService(this._firestore);

  /// Crea la subcolección videos cuando el usuario inicia su primera lección
  Future<void> initializeVideosSubcollection(String userId, int videoId) async {
    try {
      _logger.d(
        'Inicializando subcolección videos para usuario: $userId, video: $videoId',
      );

      // Verificar si ya existe algún documento en la subcolección videos
      final videosCollection = _firestore
          .collection('Users')
          .doc(userId)
          .collection('videos');

      final existingDocs = await videosCollection.limit(1).get();

      if (existingDocs.docs.isEmpty) {
        // Es la primera vez que el usuario inicia una lección
        _logger.d('Primera lección detectada, creando subcolección videos');

        // La subcolección se creará automáticamente al agregar el primer documento

        // Crear el primer registro de interacción
        await _createFirstVideoInteraction(userId, videoId);
      } else {
        _logger.d('Subcolección videos ya existe');
      }
    } catch (e, stackTrace) {
      _logger.e('Error inicializando subcolección videos', e, stackTrace);
      rethrow;
    }
  }

  /// Maneja la primera pausa de un video (actualiza registro existente)
  Future<void> handleFirstVideoPause(String userId, int videoId) async {
    try {
      _logger.d(
        'Manejando primera pausa del video $videoId para usuario $userId',
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
        _logger.d('Subcolección videos ya existe, registrando pausa');
        await _recordVideoInteraction(userId, videoId);
      }
    } catch (e, stackTrace) {
      _logger.e('Error manejando primera pausa', e, stackTrace);
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

      _logger.success(
        'Primer registro de interacción creado para video $videoId',
      );
    } catch (e, stackTrace) {
      _logger.e('Error creando primer registro de interacción', e, stackTrace);
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

      _logger.d('Interacción registrada para video $videoId');
    } catch (e, stackTrace) {
      _logger.e('Error registrando interacción', e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene el ID del documento del usuario en Firestore
  /// Usa SharedPreferences como caché persistente para que funcione offline
  Future<String?> _getUserDocumentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.e('VideoInteractionService: Usuario no autenticado');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'cached_user_doc_id_${user.uid}';
      final cachedId = prefs.getString(cacheKey);

      try {
        // PRIORIDAD 1: Buscar por email (el ID del documento del usuario)
        if (user.email != null) {
          final userQuery = await _firestore
              .collection('Users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final userDocId = userQuery.docs.first.id;
            await prefs.setString(cacheKey, userDocId);
            _logger.d(
              'VideoInteractionService: Usuario encontrado por email, ID: $userDocId',
            );
            return userDocId;
          }
        }

        // PRIORIDAD 2: Intentar con UID
        final docSnapshot = await _firestore
            .collection('Users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          await prefs.setString(cacheKey, user.uid);
          return user.uid;
        }

        if (cachedId != null) {
          return cachedId;
        }

        _logger.e('VideoInteractionService: No se encontró usuario en Firestore ni en caché');
        return null;
      } catch (e) {
        if (cachedId != null) {
          return cachedId;
        }
        _logger.e('Error en query, intentando caché falló', e, null);
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo ID del usuario', e, stackTrace);
      return null;
    }
  }

  /// Marca un video como completado con todos los campos necesarios
  /// Ahora obtiene automáticamente el ID correcto del documento del usuario
  Future<void> markVideoAsCompleted(String userId, int videoId) async {
    try {
      // Obtener el ID correcto del documento del usuario (ignorar el userId pasado)
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        _logger.e(
          'VideoInteractionService: No se pudo obtener el ID del documento del usuario',
        );
        return;
      }

      final videoDoc = _firestore
          .collection('Users')
          .doc(userDocId) // Usar el ID correcto del documento
          .collection('videos')
          .doc(videoId.toString());

      _logger.d(
        'VideoInteractionService: Marcando video como completado en /Users/$userDocId/videos/$videoId',
      );

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

      _logger.success(
        'Video $videoId marcado como completado con todos los campos',
      );
    } catch (e, stackTrace) {
      _logger.e('Error marcando video como completado', e, stackTrace);
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
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo progreso del video', e, stackTrace);
      return null;
    }
  }

  /// Obtiene todos los videos completados por el usuario
  /// Ahora obtiene automáticamente el ID correcto del documento del usuario
  Future<List<int>> getCompletedVideos(String userId) async {
    try {
      // Obtener el ID correcto del documento del usuario (ignorar el userId pasado)
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        _logger.e(
          'VideoInteractionService: No se pudo obtener el ID del documento del usuario',
        );
        return [];
      }

      _logger.d(
        'VideoInteractionService: Obteniendo videos completados de /Users/$userDocId/videos',
      );

      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userDocId) // Usar el ID correcto del documento
          .collection('videos')
          .where('estaCompletado', isEqualTo: true)
          .get();

      final completedVideos = querySnapshot.docs
          .map((doc) {
            final videoId = doc.data()['videoId'];
            if (videoId == null) {
              // Si no hay videoId en el documento, usar el ID del documento
              return int.tryParse(doc.id) ?? 0;
            }
            return videoId is int
                ? videoId
                : int.tryParse(videoId.toString()) ?? 0;
          })
          .where((id) => id > 0) // Filtrar IDs inválidos
          .toList();

      _logger.d(
        'VideoInteractionService: Encontrados ${completedVideos.length} videos completados: $completedVideos',
      );

      return completedVideos;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo videos completados', e, stackTrace);
      return [];
    }
  }

  /// Limpia documentos duplicados en la subcolección videos (solo para usuarios existentes)
  Future<void> cleanupDuplicateDocuments(String userId) async {
    try {
      _logger.d('Verificando documentos duplicados para usuario: $userId');

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
          _logger.d('Documento duplicado eliminado: $duplicateId');
        }
        _logger.success('Limpieza de documentos duplicados completada');
      } else {
        _logger.d('No se encontraron documentos duplicados para limpiar');
      }
    } catch (e, stackTrace) {
      _logger.e('Error limpiando documentos duplicados', e, stackTrace);
    }
  }
}
