import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/video.dart';
import '../entities/video_progress.dart';
import '../repositories/video_repository.dart';

@injectable
class GetAllVideosUseCase implements UseCaseNoParams<List<Video>> {
  final VideoRepository repository;

  GetAllVideosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call() async {
    return await repository.getAllVideos();
  }
}

@injectable
class GetVideoByIdUseCase implements UseCase<Video, GetVideoByIdParams> {
  final VideoRepository repository;

  GetVideoByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Video>> call(GetVideoByIdParams params) async {
    return await repository.getVideoById(params.id);
  }
}

@injectable
class GetVideosByLessonIdUseCase
    implements UseCase<List<Video>, GetVideosByLessonIdParams> {
  final VideoRepository repository;

  GetVideosByLessonIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(
    GetVideosByLessonIdParams params,
  ) async {
    return await repository.getVideosByLessonId(params.lessonId);
  }
}

@injectable
class SearchVideosUseCase implements UseCase<List<Video>, SearchVideosParams> {
  final VideoRepository repository;

  SearchVideosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(SearchVideosParams params) async {
    return await repository.searchVideos(params.query);
  }
}

@injectable
class MarkVideoAsCompletedUseCase
    implements UseCase<void, MarkVideoAsCompletedParams> {
  final VideoRepository repository;

  MarkVideoAsCompletedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkVideoAsCompletedParams params) async {
    return await repository.markVideoAsCompleted(params.videoId, params.userId);
  }
}

@injectable
class GetCompletedVideoIdsUseCase
    implements UseCase<List<String>, GetCompletedVideoIdsParams> {
  final VideoRepository repository;

  GetCompletedVideoIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(
    GetCompletedVideoIdsParams params,
  ) async {
    return await repository.getCompletedVideoIds(params.userId);
  }
}

@injectable
class UpdateVideoProgressUseCase
    implements UseCase<void, UpdateVideoProgressParams> {
  final VideoRepository repository;

  UpdateVideoProgressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateVideoProgressParams params) async {
    return await repository.updateVideoProgress(params.progress);
  }
}

// Parámetros para los casos de uso
class GetVideoByIdParams {
  final String id;

  GetVideoByIdParams({required this.id});
}

class GetVideosByLessonIdParams {
  final String lessonId;

  GetVideosByLessonIdParams({required this.lessonId});
}

class SearchVideosParams {
  final String query;

  SearchVideosParams({required this.query});
}

class MarkVideoAsCompletedParams {
  final String videoId;
  final String userId;

  MarkVideoAsCompletedParams({required this.videoId, required this.userId});
}

class GetCompletedVideoIdsParams {
  final String userId;

  GetCompletedVideoIdsParams({required this.userId});
}

class UpdateVideoProgressParams {
  final VideoProgress progress;

  UpdateVideoProgressParams({required this.progress});
}
