import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video.dart';
import '../entities/video_progress.dart';
import '../entities/video_session.dart';
import '../entities/video_statistics.dart';
import '../entities/video_event.dart';

abstract class VideoRepository {
  // Métodos básicos de videos
  Future<Either<Failure, List<Video>>> getAllVideos();

  Future<Either<Failure, Video>> getVideoById(String id);

  Future<Either<Failure, List<Video>>> getVideosByLessonId(String lessonId);

  Future<Either<Failure, List<Video>>> searchVideos(String query);

  // Métodos de progreso de videos
  Future<Either<Failure, VideoProgress>> getVideoProgress(
    String videoId,
    String userId,
  );

  Future<Either<Failure, void>> updateVideoProgress(VideoProgress progress);

  Future<Either<Failure, void>> markVideoAsCompleted(
    String videoId,
    String userId,
  );

  Future<Either<Failure, List<String>>> getCompletedVideoIds(String userId);

  Future<Either<Failure, VideoStatistics>> getVideoStatistics(
    String videoId,
    String userId,
  );

  // Métodos de sesiones de video
  Future<Either<Failure, VideoSession>> createVideoSession(
    VideoSession session,
  );

  Future<Either<Failure, void>> updateVideoSession(VideoSession session);

  Future<Either<Failure, void>> addVideoEvent(VideoEvent event);

  Future<Either<Failure, List<VideoSession>>> getVideoSessions(
    String videoId,
    String userId,
  );
}
