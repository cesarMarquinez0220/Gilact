part of 'lesson_bloc.dart';

abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {
  const LessonInitial();
}

class LessonLoading extends LessonState {
  const LessonLoading();
}

class LessonsLoaded extends LessonState {
  final List<Lesson> lessons;

  const LessonsLoaded(this.lessons);

  @override
  List<Object> get props => [lessons];
}

class LessonLoaded extends LessonState {
  final Lesson lesson;

  const LessonLoaded(this.lesson);

  @override
  List<Object> get props => [lesson];
}

class LessonFailure extends LessonState {
  final String message;

  const LessonFailure(this.message);

  @override
  List<Object> get props => [message];
}

class LessonMarkedAsCompleted extends LessonState {
  final String lessonId;

  const LessonMarkedAsCompleted(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

class LessonProgressLoaded extends LessonState {
  final String lessonId;
  final double progress;

  const LessonProgressLoaded(this.lessonId, this.progress);

  @override
  List<Object> get props => [lessonId, progress];
}

class UserProgressLoaded extends LessonState {
  final Map<String, double> progress;

  const UserProgressLoaded(this.progress);

  @override
  List<Object> get props => [progress];
}

class UserStatisticsLoaded extends LessonState {
  final Map<String, dynamic> statistics;

  const UserStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}
