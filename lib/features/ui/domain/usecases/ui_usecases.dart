import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ui_entities.dart';
import '../repositories/ui_repository.dart';

class GetSplashPagesUseCase implements UseCase<List<SplashPage>, NoParams> {
  final UIRepository repository;

  GetSplashPagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SplashPage>>> call(NoParams params) async {
    return await repository.getSplashPages();
  }
}

class GetLessonProgressStateUseCase
    implements UseCase<LessonProgressState, NoParams> {
  final UIRepository repository;

  GetLessonProgressStateUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(NoParams params) async {
    return await repository.getLessonProgressState();
  }
}

class UpdateLessonProgressUseCase
    implements UseCase<LessonProgressState, Map<String, dynamic>> {
  final UIRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(
    Map<String, dynamic> params,
  ) async {
    final lessonId = params['lessonId'] as int;
    final isCompleted = params['isCompleted'] as bool;
    return await repository.updateLessonProgress(lessonId, isCompleted);
  }
}

class UpdateVideoProgressUseCase
    implements UseCase<LessonProgressState, Map<String, dynamic>> {
  final UIRepository repository;

  UpdateVideoProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(
    Map<String, dynamic> params,
  ) async {
    final videoId = params['videoId'] as int;
    final progress = params['progress'] as double;
    return await repository.updateVideoProgress(videoId, progress);
  }
}

class MarkVideoAsWatchedUseCase implements UseCase<LessonProgressState, int> {
  final UIRepository repository;

  MarkVideoAsWatchedUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(int videoId) async {
    return await repository.markVideoAsWatched(videoId);
  }
}

class UpdateCompletedVideosListUseCase
    implements UseCase<LessonProgressState, List<int>> {
  final UIRepository repository;

  UpdateCompletedVideosListUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(
    List<int> completedVideoIds,
  ) async {
    return await repository.updateCompletedVideosList(completedVideoIds);
  }
}

class UpdateLastCompletedLessonUseCase
    implements UseCase<LessonProgressState, int> {
  final UIRepository repository;

  UpdateLastCompletedLessonUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressState>> call(int lessonNumber) async {
    return await repository.updateLastCompletedLesson(lessonNumber);
  }
}
