part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

// Eventos básicos de videos
class GetAllVideosRequested extends VideoEvent {
  const GetAllVideosRequested();
}

class GetVideoByIdRequested extends VideoEvent {
  final String id;

  const GetVideoByIdRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class GetVideosByLessonIdRequested extends VideoEvent {
  final String lessonId;

  const GetVideosByLessonIdRequested({required this.lessonId});

  @override
  List<Object> get props => [lessonId];
}

class SearchVideosRequested extends VideoEvent {
  final String query;

  const SearchVideosRequested({required this.query});

  @override
  List<Object> get props => [query];
}

// Eventos de progreso de videos
class GetVideoProgressRequested extends VideoEvent {
  final String videoId;
  final String userId;

  const GetVideoProgressRequested({
    required this.videoId,
    required this.userId,
  });

  @override
  List<Object> get props => [videoId, userId];
}

class UpdateVideoProgressRequested extends VideoEvent {
  final VideoProgress progress;

  const UpdateVideoProgressRequested({required this.progress});

  @override
  List<Object> get props => [progress];
}

class MarkVideoAsCompletedRequested extends VideoEvent {
  final String videoId;
  final String userId;

  const MarkVideoAsCompletedRequested({
    required this.videoId,
    required this.userId,
  });

  @override
  List<Object> get props => [videoId, userId];
}

class GetCompletedVideoIdsRequested extends VideoEvent {
  final String userId;

  const GetCompletedVideoIdsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetVideoStatisticsRequested extends VideoEvent {
  final String videoId;
  final String userId;

  const GetVideoStatisticsRequested({
    required this.videoId,
    required this.userId,
  });

  @override
  List<Object> get props => [videoId, userId];
}

// Eventos de sesiones de video
class CreateVideoSessionRequested extends VideoEvent {
  final VideoSession session;

  const CreateVideoSessionRequested({required this.session});

  @override
  List<Object> get props => [session];
}

class UpdateVideoSessionRequested extends VideoEvent {
  final VideoSession session;

  const UpdateVideoSessionRequested({required this.session});

  @override
  List<Object> get props => [session];
}

class AddVideoEventRequested extends VideoEvent {
  final VideoEvent event;

  const AddVideoEventRequested({required this.event});

  @override
  List<Object> get props => [event];
}

class GetVideoSessionsRequested extends VideoEvent {
  final String videoId;
  final String userId;

  const GetVideoSessionsRequested({
    required this.videoId,
    required this.userId,
  });

  @override
  List<Object> get props => [videoId, userId];
}
