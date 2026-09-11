import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ui_entities.dart';
import '../../domain/repositories/ui_repository.dart';
import '../datasources/ui_local_data_source.dart';

@LazySingleton(as: UIRepository)
class UIRepositoryImpl implements UIRepository {
  final UILocalDataSource _localDataSource;

  UIRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<SplashPage>>> getSplashPages() async {
    try {
      final splashPages = await _localDataSource.getSplashPages();
      return Right(splashPages);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> getLessonProgressState() async {
    try {
      final progressState = await _localDataSource.getLessonProgressState();
      return Right(progressState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> updateLessonProgress(
    int lessonId,
    bool isCompleted,
  ) async {
    try {
      final updatedState = await _localDataSource.updateLessonProgress(
        lessonId,
        isCompleted,
      );
      return Right(updatedState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> updateVideoProgress(
    int videoId,
    double progress,
  ) async {
    try {
      final updatedState = await _localDataSource.updateVideoProgress(
        videoId,
        progress,
      );
      return Right(updatedState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> markVideoAsWatched(
    int videoId,
  ) async {
    try {
      final updatedState = await _localDataSource.markVideoAsWatched(videoId);
      return Right(updatedState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> updateCompletedVideosList(
    List<int> completedVideoIds,
  ) async {
    try {
      final updatedState = await _localDataSource.updateCompletedVideosList(
        completedVideoIds,
      );
      return Right(updatedState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LessonProgressState>> updateLastCompletedLesson(
    int lessonNumber,
  ) async {
    try {
      final updatedState = await _localDataSource.updateLastCompletedLesson(
        lessonNumber,
      );
      return Right(updatedState);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
