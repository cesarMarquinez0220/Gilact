part of 'lesson_bloc.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

class GetAllLessonsRequested extends LessonEvent {
  const GetAllLessonsRequested();
}

class GetLessonByIdRequested extends LessonEvent {
  final String id;

  const GetLessonByIdRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class GetLessonsByCategoryRequested extends LessonEvent {
  final String category;

  const GetLessonsByCategoryRequested({required this.category});

  @override
  List<Object> get props => [category];
}

class SearchLessonsRequested extends LessonEvent {
  final String query;

  const SearchLessonsRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class MarkLessonAsCompletedRequested extends LessonEvent {
  final String lessonId;

  const MarkLessonAsCompletedRequested({required this.lessonId});

  @override
  List<Object> get props => [lessonId];
}

class GetLessonProgressRequested extends LessonEvent {
  final String lessonId;

  const GetLessonProgressRequested({required this.lessonId});

  @override
  List<Object> get props => [lessonId];
}

class GetUserProgressRequested extends LessonEvent {
  const GetUserProgressRequested();
}

class GetUserStatisticsRequested extends LessonEvent {
  const GetUserStatisticsRequested();
}
