import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_profile_entities.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String username) async {
    try {
      final userProfile = await _remoteDataSource.getUserProfile(username);
      return Right(userProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile userProfile,
  ) async {
    try {
      final updatedProfile = await _remoteDataSource.updateUserProfile(
        userProfile,
      );
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BabyInfo?>> getBabyInfo(String username) async {
    try {
      final babyInfo = await _remoteDataSource.getBabyInfo(username);
      return Right(babyInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BabyInfo>> updateBabyInfo(
    String username,
    BabyInfo babyInfo,
  ) async {
    try {
      final updatedBabyInfo = await _remoteDataSource.updateBabyInfo(
        username,
        babyInfo,
      );
      return Right(updatedBabyInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LessonProgress>>> getLessonProgress(
    String username,
  ) async {
    try {
      final progressList = await _remoteDataSource.getLessonProgress(username);
      return Right(progressList);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgress>> updateLessonProgress(
    String username,
    String lessonId,
    double progress,
  ) async {
    try {
      final updatedProgress = await _remoteDataSource.updateLessonProgress(
        username,
        lessonId,
        progress,
      );
      return Right(updatedProgress);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getLastCompletedLesson(String username) async {
    try {
      final lastLesson = await _remoteDataSource.getLastCompletedLesson(
        username,
      );
      return Right(lastLesson);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, bool>>> checkUserSituation(
    String username,
  ) async {
    try {
      final situation = await _remoteDataSource.checkUserSituation(username);
      return Right(situation);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  // Métodos legacy para compatibilidad
  @override
  Future<Either<Failure, UserProfile>> createProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? location,
    DateTime? birthDate,
    int? age,
    String? idNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Implementar creación de perfil si es necesario
      throw UnimplementedError('createProfile not implemented');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final userProfile = await _remoteDataSource.getUserProfile(userId);
      return Right(userProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? location,
    DateTime? birthDate,
    int? age,
    String? idNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Implementar actualización de perfil si es necesario
      throw UnimplementedError('updateProfile not implemented');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile(String userId) async {
    try {
      // Implementar eliminación de perfil si es necesario
      throw UnimplementedError('deleteProfile not implemented');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> profileExists(String userId) async {
    try {
      // Implementar verificación de existencia de perfil si es necesario
      throw UnimplementedError('profileExists not implemented');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
