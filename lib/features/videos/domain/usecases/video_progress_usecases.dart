import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/video_progress.dart';
import '../entities/video_session.dart';
import '../entities/video_statistics.dart';
import '../entities/video_event.dart';
import '../repositories/video_repository.dart';

@injectable
class GetVideoProgressUseCase
    implements UseCase<VideoProgress, GetVideoProgressParams> {
  final VideoRepository repository;

  GetVideoProgressUseCase(this.repository);

  @override
  Future<Either<Failure, VideoProgress>> call(
    GetVideoProgressParams params,
  ) async {
    return await repository.getVideoProgress(params.videoId, params.userId);
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
class GetVideoStatisticsUseCase
    implements UseCase<VideoStatistics, GetVideoStatisticsParams> {
  final VideoRepository repository;

  GetVideoStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, VideoStatistics>> call(
    GetVideoStatisticsParams params,
  ) async {
    return await repository.getVideoStatistics(params.videoId, params.userId);
  }
}

@injectable
class CreateVideoSessionUseCase
    implements UseCase<VideoSession, CreateVideoSessionParams> {
  final VideoRepository repository;

  CreateVideoSessionUseCase(this.repository);

  @override
  Future<Either<Failure, VideoSession>> call(
    CreateVideoSessionParams params,
  ) async {
    return await repository.createVideoSession(params.session);
  }
}

@injectable
class UpdateVideoSessionUseCase
    implements UseCase<void, UpdateVideoSessionParams> {
  final VideoRepository repository;

  UpdateVideoSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateVideoSessionParams params) async {
    return await repository.updateVideoSession(params.session);
  }
}

@injectable
class AddVideoEventUseCase implements UseCase<void, AddVideoEventParams> {
  final VideoRepository repository;

  AddVideoEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddVideoEventParams params) async {
    return await repository.addVideoEvent(params.event);
  }
}

@injectable
class GetVideoSessionsUseCase
    implements UseCase<List<VideoSession>, GetVideoSessionsParams> {
  final VideoRepository repository;

  GetVideoSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VideoSession>>> call(
    GetVideoSessionsParams params,
  ) async {
    return await repository.getVideoSessions(params.videoId, params.userId);
  }
}

// Parámetros para los casos de uso
class GetVideoProgressParams {
  final String videoId;
  final String userId;

  GetVideoProgressParams({required this.videoId, required this.userId});
}

class UpdateVideoProgressParams {
  final VideoProgress progress;

  UpdateVideoProgressParams({required this.progress});
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

class GetVideoStatisticsParams {
  final String videoId;
  final String userId;

  GetVideoStatisticsParams({required this.videoId, required this.userId});
}

class CreateVideoSessionParams {
  final VideoSession session;

  CreateVideoSessionParams({required this.session});
}

class UpdateVideoSessionParams {
  final VideoSession session;

  UpdateVideoSessionParams({required this.session});
}

class AddVideoEventParams {
  final VideoEvent event;

  AddVideoEventParams({required this.event});
}

class GetVideoSessionsParams {
  final String videoId;
  final String userId;

  GetVideoSessionsParams({required this.videoId, required this.userId});
}
