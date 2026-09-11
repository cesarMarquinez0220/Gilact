import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_logger.dart';
import '../di/injection.dart';

/// Servicio para manejar el guardado automático de progreso
@singleton
class AutoSaveService {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AppLogger _logger = getIt<AppLogger>();
  static const String _keyAutoSaveProgress = 'autoSaveProgress';

  AutoSaveService(this._prefs, this._firestore, this._auth);

  /// Verifica si el guardado automático está habilitado
  bool isAutoSaveEnabled() {
    return _prefs.getBool(_keyAutoSaveProgress) ?? true;
  }

  /// Guarda el progreso de un video automáticamente
  /// Solo guarda si el guardado automático está habilitado
  Future<void> saveVideoProgress({
    required int videoId,
    required int lastPosition,
    required int totalDuration,
    required double progress,
    bool isCompleted = false,
  }) async {
    if (!isAutoSaveEnabled()) {
      _logger.d('Guardado automático deshabilitado, omitiendo guardado');
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('Usuario no autenticado, no se puede guardar progreso');
        return;
      }

      // Obtener el ID del documento del usuario
      String? userDocId;
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userDocId = userQuery.docs.first.id;
        }
      }
      userDocId ??= user.uid;

      final videoDocRef = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('videos')
          .doc(videoId.toString());

      await videoDocRef.set({
        'videoId': videoId,
        'ultimaPosicion': lastPosition,
        'duracion': totalDuration,
        'avance': progress,
        'estaCompletado': isCompleted,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _logger.success('Progreso guardado automáticamente para video $videoId');
    } catch (e, stackTrace) {
      _logger.e('Error en guardado automático', e, stackTrace);
      // No lanzar excepción, solo registrar el error
    }
  }

  /// Guarda el progreso de una lección automáticamente
  Future<void> saveLessonProgress({
    required int lessonId,
    required double progress,
    bool isCompleted = false,
  }) async {
    if (!isAutoSaveEnabled()) {
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String? userDocId;
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userDocId = userQuery.docs.first.id;
        }
      }
      userDocId ??= user.uid;

      final lessonDocRef = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('lessons')
          .doc(lessonId.toString());

      await lessonDocRef.set({
        'lessonId': lessonId,
        'progreso': progress,
        'estaCompletado': isCompleted,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _logger.success(
        'Progreso de lección guardado automáticamente para lección $lessonId',
      );
    } catch (e, stackTrace) {
      _logger.e('Error guardando progreso de lección', e, stackTrace);
    }
  }

  /// Guarda cualquier dato genérico automáticamente
  Future<void> saveGenericData({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!isAutoSaveEnabled()) {
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      String? userDocId;
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userDocId = userQuery.docs.first.id;
        }
      }
      userDocId ??= user.uid;

      final docRef = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection(collection)
          .doc(documentId);

      await docRef.set({
        ...data,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _logger.success(
        'Datos guardados automáticamente en $collection/$documentId',
      );
    } catch (e, stackTrace) {
      _logger.e('Error guardando datos genéricos', e, stackTrace);
    }
  }
}
