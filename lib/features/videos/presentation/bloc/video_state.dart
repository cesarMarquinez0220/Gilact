part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

// Estados básicos
class VideoInitial extends VideoState {
  const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();
}

class VideosLoaded extends VideoState {
  final List<Video> videos;

  const VideosLoaded(this.videos);

  @override
  List<Object> get props => [videos];
}

class VideoLoaded extends VideoState {
  final Video video;

  const VideoLoaded(this.video);

  @override
  List<Object> get props => [video];
}

class VideoFailure extends VideoState {
  final String message;

  const VideoFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Estados de progreso
class VideoProgressLoaded extends VideoState {
  final VideoProgress progress;

  const VideoProgressLoaded(this.progress);

  @override
  List<Object> get props => [progress];
}

class VideoProgressUpdated extends VideoState {
  final VideoProgress progress;

  const VideoProgressUpdated(this.progress);

  @override
  List<Object> get props => [progress];
}

class VideoCompleted extends VideoState {
  final String videoId;

  const VideoCompleted(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class VideoMarkedAsCompleted extends VideoState {
  final String videoId;

  const VideoMarkedAsCompleted(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class CompletedVideoIdsLoaded extends VideoState {
  final List<String> completedIds;

  const CompletedVideoIdsLoaded(this.completedIds);

  @override
  List<Object> get props => [completedIds];
}

class VideoStatisticsLoaded extends VideoState {
  final VideoStatistics statistics;

  const VideoStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

// Estados de sesiones
class VideoSessionCreated extends VideoState {
  final VideoSession session;

  const VideoSessionCreated(this.session);

  @override
  List<Object> get props => [session];
}

class VideoSessionUpdated extends VideoState {
  final VideoSession session;

  const VideoSessionUpdated(this.session);

  @override
  List<Object> get props => [session];
}

class VideoEventAdded extends VideoState {
  final VideoEvent event;

  const VideoEventAdded(this.event);

  @override
  List<Object> get props => [event];
}

class VideoSessionsLoaded extends VideoState {
  final List<VideoSession> sessions;

  const VideoSessionsLoaded(this.sessions);

  @override
  List<Object> get props => [sessions];
}
