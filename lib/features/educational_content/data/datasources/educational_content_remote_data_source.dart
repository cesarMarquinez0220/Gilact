import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/educational_content_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class EducationalContentRemoteDataSource {
  Future<List<EducationalContentModel>> getAllContent();
  Future<EducationalContentModel> getContentById(String id);
  Future<List<EducationalContentModel>> getContentByCategory(String category);
  Future<List<EducationalContentModel>> searchContent(String query);
  Future<void> markContentAsCompleted(String contentId);
  Future<List<String>> getCompletedContentIds();
  Future<Map<String, dynamic>> getContentStatistics();
}

@LazySingleton(as: EducationalContentRemoteDataSource)
class EducationalContentRemoteDataSourceImpl implements EducationalContentRemoteDataSource {
  final FirebaseFirestore _firestore;

  EducationalContentRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<EducationalContentModel>> getAllContent() async {
    try {
    try {
      // 1. Intentar obtener de caché primero
      try {
        final cacheSnapshot = await _firestore
            .collection('educational_content')
            .orderBy('order')
            .get(const GetOptions(source: Source.cache));

        if (cacheSnapshot.docs.isNotEmpty) {
          return cacheSnapshot.docs
              .map((doc) => EducationalContentModel.fromQueryDocument(doc))
              .toList();
        }
      } catch (_) {}

      // 2. Si hay fallo o está vacío, ir al servidor
      final querySnapshot = await _firestore
          .collection('educational_content')
          .orderBy('order')
          .get(const GetOptions(source: Source.server));

      return querySnapshot.docs
          .map((doc) => EducationalContentModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener contenido educativo: ${e.toString()}');
    }
  }

  @override
  Future<EducationalContentModel> getContentById(String id) async {
    try {
      final doc = await _firestore.collection('educational_content').doc(id).get();
      
      if (!doc.exists) {
        throw const ServerException(message: 'Contenido educativo no encontrado');
      }

      return EducationalContentModel.fromDocument(doc);
    } catch (e) {
      throw ServerException(message: 'Error al obtener contenido educativo: ${e.toString()}');
    }
  }

  @override
  Future<List<EducationalContentModel>> getContentByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('educational_content')
          .where('category', isEqualTo: category)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => EducationalContentModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener contenido por categoría: ${e.toString()}');
    }
  }

  @override
  Future<List<EducationalContentModel>> searchContent(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('educational_content')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => EducationalContentModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar contenido: ${e.toString()}');
    }
  }

  @override
  Future<void> markContentAsCompleted(String contentId) async {
    try {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw const ServerException(message: 'Usuario no autenticado');
      }

      final user = _firestore.collection('Users').doc(userId);
      
      await user.collection('completed_content').doc(contentId).set({
        'contentId': contentId,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(message: 'Error al marcar contenido como completado: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCompletedContentIds() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw const ServerException(message: 'Usuario no autenticado');
      }

      final user = _firestore.collection('Users').doc(userId);
      
      final querySnapshot = await user
          .collection('completed_content')
          .get();

      return querySnapshot.docs.map((doc) => doc.get('contentId') as String).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener contenido completado: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      // Obtener estadísticas del contenido educativo
      // Usar agregación `count()` si es posible para ahorrar lecturas, pero SDK base a veces no lo tiene expuesto simple.
      // Por ahora, usamos caché para obtener la lista sin costo si ya la tenemos.
      final totalContent = await _firestore
          .collection('educational_content')
          .get(const GetOptions(source: Source.cache));

      final completedContent = await getCompletedContentIds();

      return {
        'totalContent': totalContent.docs.length,
        'completedContent': completedContent.length,
        'completionRate': totalContent.docs.isNotEmpty 
            ? (completedContent.length / totalContent.docs.length * 100).round()
            : 0,
        'categories': _getCategoriesFromContent(totalContent.docs),
      };
    } catch (e) {
      throw ServerException(message: 'Error al obtener estadísticas: ${e.toString()}');
    }
  }

  List<String> _getCategoriesFromContent(List<QueryDocumentSnapshot> docs) {
    final categories = <String>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String?;
      if (category != null) {
        categories.add(category);
      }
    }
    return categories.toList();
  }
}
