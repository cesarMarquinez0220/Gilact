import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/tip_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class TipRemoteDataSource {
  Future<List<TipModel>> getAllTips();
  Future<TipModel> getTipById(String id);
  Future<List<TipModel>> getTipsByCategory(String category);
  Future<List<TipModel>> searchTips(String query);
  Future<void> markTipAsFavorite(String tipId);
  Future<void> unmarkTipAsFavorite(String tipId);
  Future<List<TipModel>> getFavoriteTips();
}

@LazySingleton(as: TipRemoteDataSource)
class TipRemoteDataSourceImpl implements TipRemoteDataSource {
  final FirebaseFirestore _firestore;

  TipRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<TipModel>> getAllTips() async {
    try {
      final querySnapshot = await _firestore
          .collection('tips')
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => TipModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener tips: ${e.toString()}');
    }
  }

  @override
  Future<TipModel> getTipById(String id) async {
    try {
      final doc = await _firestore.collection('tips').doc(id).get();

      if (!doc.exists) {
        throw const ServerException(message: 'Tip no encontrado');
      }

      return TipModel.fromDocument(doc);
    } catch (e) {
      throw ServerException(message: 'Error al obtener tip: ${e.toString()}');
    }
  }

  @override
  Future<List<TipModel>> getTipsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('tips')
          .where('category', isEqualTo: category)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => TipModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener tips por categoría: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<TipModel>> searchTips(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('tips')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => TipModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al buscar tips: ${e.toString()}');
    }
  }

  @override
  Future<void> markTipAsFavorite(String tipId) async {
    try {
      // Aquí necesitarías obtener el usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      await user.collection('favorite_tips').doc(tipId).set({
        'tipId': tipId,
        'markedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(
        message: 'Error al marcar tip como favorito: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unmarkTipAsFavorite(String tipId) async {
    try {
      // Aquí necesitarías obtener el usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      await user.collection('favorite_tips').doc(tipId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al desmarcar tip como favorito: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<TipModel>> getFavoriteTips() async {
    try {
      // Aquí necesitarías obtener el usuario actual
      final user = FirebaseFirestore.instance
          .collection('Users')
          .doc('current_user_id');

      final querySnapshot = await user.collection('favorite_tips').get();

      final tipIds = querySnapshot.docs
          .map((doc) => doc.get('tipId') as String)
          .toList();

      if (tipIds.isEmpty) {
        return [];
      }

      final tipsQuerySnapshot = await _firestore
          .collection('tips')
          .where(FieldPath.documentId, whereIn: tipIds)
          .get();

      return tipsQuerySnapshot.docs
          .map((doc) => TipModel.fromQueryDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener tips favoritos: ${e.toString()}',
      );
    }
  }
}
