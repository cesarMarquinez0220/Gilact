import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_progress.dart';
import '../../domain/entities/video_session.dart';
import '../../domain/entities/video_statistics.dart';
import '../../domain/entities/video_event.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_data_source.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource _remoteDataSource;

  VideoRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Video>>> getAllVideos() async {
    try {
      final videoModels = await _remoteDataSource.getAllVideos();
      return Right(videoModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Video>> getVideoById(String id) async {
    try {
      final videoModel = await _remoteDataSource.getVideoById(id);
      return Right(videoModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByLessonId(
    String lessonId,
  ) async {
    try {
      final videoModels = await _remoteDataSource.getVideosByLessonId(lessonId);
      return Right(videoModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> searchVideos(String query) async {
    try {
      final videoModels = await _remoteDataSource.searchVideos(query);
      return Right(videoModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markVideoAsCompleted(
    String videoId,
    String userId,
  ) async {
    try {
      await _remoteDataSource.markVideoAsCompleted(videoId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCompletedVideoIds(
    String userId,
  ) async {
    try {
      final completedIds = await _remoteDataSource.getCompletedVideoIds();
      return Right(completedIds);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVideoProgress(
    VideoProgress progress,
  ) async {
    try {
      await _remoteDataSource.updateVideoProgress(
        videoId: progress.videoId,
        currentPosition: progress.currentPosition,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  // Métodos faltantes - implementaciones básicas
  @override
  Future<Either<Failure, VideoProgress>> getVideoProgress(
    String videoId,
    String userId,
  ) async {
    try {
      // TODO: Implementar obtención de progreso de video
      return Left(ServerFailure(message: 'Método no implementado'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VideoStatistics>> getVideoStatistics(
    String videoId,
    String userId,
  ) async {
    try {
      // TODO: Implementar obtención de estadísticas de video
      return Left(ServerFailure(message: 'Método no implementado'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VideoSession>> createVideoSession(
    VideoSession session,
  ) async {
    try {
      // TODO: Implementar creación de sesión de video
      return Left(ServerFailure(message: 'Método no implementado'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVideoSession(VideoSession session) async {
    try {
      // TODO: Implementar actualización de sesión de video
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addVideoEvent(VideoEvent event) async {
    try {
      // TODO: Implementar adición de evento de video
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoSession>>> getVideoSessions(
    String videoId,
    String userId,
  ) async {
    try {
      // TODO: Implementar obtención de sesiones de video
      return Left(ServerFailure(message: 'Método no implementado'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
