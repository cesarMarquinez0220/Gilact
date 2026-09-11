import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/prepartum_info.dart';
import '../../domain/entities/postpartum_info.dart';
import '../models/prepartum_info_model.dart';
import '../models/postpartum_info_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<void> savePrepartumInfo(PrepartumInfo prepartumInfo);
  Future<PrepartumInfo?> getPrepartumInfo(String userId);
  Future<void> savePostpartumInfo(PostpartumInfo postpartumInfo);
  Future<PostpartumInfo?> getPostpartumInfo(String userId);
}

@LazySingleton(as: OnboardingRemoteDataSource)
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore;

  OnboardingRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> savePrepartumInfo(PrepartumInfo prepartumInfo) async {
    try {
      final model = PrepartumInfoModel.fromEntity(prepartumInfo);

      await _firestore
          .collection('Users')
          .doc(prepartumInfo.userId)
          .collection('situacion')
          .doc('preparto')
          .set(model.toFirestore());
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar información de preparto: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrepartumInfo?> getPrepartumInfo(String userId) async {
    try {
      final doc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('preparto')
          .get();

      if (doc.exists) {
        return PrepartumInfoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener información de preparto: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> savePostpartumInfo(PostpartumInfo postpartumInfo) async {
    try {
      final model = PostpartumInfoModel.fromEntity(postpartumInfo);

      await _firestore
          .collection('Users')
          .doc(postpartumInfo.userId)
          .collection('situacion')
          .doc('postparto')
          .set(model.toFirestore());
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar información de postparto: ${e.toString()}',
      );
    }
  }

  @override
  Future<PostpartumInfo?> getPostpartumInfo(String userId) async {
    try {
      final doc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('postparto')
          .get();

      if (doc.exists) {
        return PostpartumInfoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener información de postparto: ${e.toString()}',
      );
    }
  }
}
