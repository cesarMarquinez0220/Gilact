import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ui_entities.dart';

abstract class UIRepository {
  Future<Either<Failure, List<SplashPage>>> getSplashPages();
  Future<Either<Failure, LessonProgressState>> getLessonProgressState();
  Future<Either<Failure, LessonProgressState>> updateLessonProgress(
    int lessonId,
    bool isCompleted,
  );
  Future<Either<Failure, LessonProgressState>> updateVideoProgress(
    int videoId,
    double progress,
  );
  Future<Either<Failure, LessonProgressState>> markVideoAsWatched(int videoId);
  Future<Either<Failure, LessonProgressState>> updateCompletedVideosList(
    List<int> completedVideoIds,
  );
  Future<Either<Failure, LessonProgressState>> updateLastCompletedLesson(
    int lessonNumber,
  );
}
