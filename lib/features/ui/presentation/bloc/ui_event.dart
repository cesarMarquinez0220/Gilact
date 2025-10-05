part of 'ui_bloc.dart';

abstract class UIEvent extends Equatable {
  const UIEvent();

  @override
  List<Object?> get props => [];
}

class LoadSplashPages extends UIEvent {
  const LoadSplashPages();
}

class LoadLessonProgressState extends UIEvent {
  const LoadLessonProgressState();
}

class UpdateLessonProgress extends UIEvent {
  final int lessonId;
  final bool isCompleted;

  const UpdateLessonProgress({
    required this.lessonId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [lessonId, isCompleted];
}

class UpdateVideoProgress extends UIEvent {
  final int videoId;
  final double progress;

  const UpdateVideoProgress({required this.videoId, required this.progress});

  @override
  List<Object?> get props => [videoId, progress];
}

class MarkVideoAsWatched extends UIEvent {
  final int videoId;

  const MarkVideoAsWatched(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class UpdateCompletedVideosList extends UIEvent {
  final List<int> completedVideoIds;

  const UpdateCompletedVideosList(this.completedVideoIds);

  @override
  List<Object?> get props => [completedVideoIds];
}

class UpdateLastCompletedLesson extends UIEvent {
  final int lessonNumber;

  const UpdateLastCompletedLesson(this.lessonNumber);

  @override
  List<Object?> get props => [lessonNumber];
}
