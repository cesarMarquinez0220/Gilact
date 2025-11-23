import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para manejar el guardado automático de progreso
@singleton
class AutoSaveService {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
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
      print('⏸️ Guardado automático deshabilitado, omitiendo guardado');
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Usuario no autenticado, no se puede guardar progreso');
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

      print('✅ Progreso guardado automáticamente para video $videoId');
    } catch (e) {
      print('❌ Error en guardado automático: $e');
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

      print('✅ Progreso de lección guardado automáticamente para lección $lessonId');
    } catch (e) {
      print('❌ Error guardando progreso de lección: $e');
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

      print('✅ Datos guardados automáticamente en $collection/$documentId');
    } catch (e) {
      print('❌ Error guardando datos genéricos: $e');
    }
  }
}

