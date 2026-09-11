import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/usecases/lesson_usecases.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

@injectable
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetAllLessonsUseCase _getAllLessonsUseCase;
  final GetLessonByIdUseCase _getLessonByIdUseCase;
  final GetLessonsByCategoryUseCase _getLessonsByCategoryUseCase;
  final SearchLessonsUseCase _searchLessonsUseCase;
  final MarkLessonAsCompletedUseCase _markLessonAsCompletedUseCase;
  final GetLessonProgressUseCase _getLessonProgressUseCase;
  final GetUserProgressUseCase _getUserProgressUseCase;
  final GetUserStatisticsUseCase _getUserStatisticsUseCase;

  LessonBloc({
    required GetAllLessonsUseCase getAllLessonsUseCase,
    required GetLessonByIdUseCase getLessonByIdUseCase,
    required GetLessonsByCategoryUseCase getLessonsByCategoryUseCase,
    required SearchLessonsUseCase searchLessonsUseCase,
    required MarkLessonAsCompletedUseCase markLessonAsCompletedUseCase,
    required GetLessonProgressUseCase getLessonProgressUseCase,
    required GetUserProgressUseCase getUserProgressUseCase,
    required GetUserStatisticsUseCase getUserStatisticsUseCase,
  })  : _getAllLessonsUseCase = getAllLessonsUseCase,
        _getLessonByIdUseCase = getLessonByIdUseCase,
        _getLessonsByCategoryUseCase = getLessonsByCategoryUseCase,
        _searchLessonsUseCase = searchLessonsUseCase,
        _markLessonAsCompletedUseCase = markLessonAsCompletedUseCase,
        _getLessonProgressUseCase = getLessonProgressUseCase,
        _getUserProgressUseCase = getUserProgressUseCase,
        _getUserStatisticsUseCase = getUserStatisticsUseCase,
        super(const LessonInitial()) {
    on<GetAllLessonsRequested>(_onGetAllLessonsRequested);
    on<GetLessonByIdRequested>(_onGetLessonByIdRequested);
    on<GetLessonsByCategoryRequested>(_onGetLessonsByCategoryRequested);
    on<SearchLessonsRequested>(_onSearchLessonsRequested);
    on<MarkLessonAsCompletedRequested>(_onMarkLessonAsCompletedRequested);
    on<GetLessonProgressRequested>(_onGetLessonProgressRequested);
    on<GetUserProgressRequested>(_onGetUserProgressRequested);
    on<GetUserStatisticsRequested>(_onGetUserStatisticsRequested);
  }

  Future<void> _onGetAllLessonsRequested(
    GetAllLessonsRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());
    
    final result = await _getAllLessonsUseCase();

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (lessons) => emit(LessonsLoaded(lessons)),
    );
  }

  Future<void> _onGetLessonByIdRequested(
    GetLessonByIdRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());
    
    final result = await _getLessonByIdUseCase(GetLessonByIdParams(id: event.id));

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (lesson) => emit(LessonLoaded(lesson)),
    );
  }

  Future<void> _onGetLessonsByCategoryRequested(
    GetLessonsByCategoryRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());
    
    final result = await _getLessonsByCategoryUseCase(
      GetLessonsByCategoryParams(category: event.category),
    );

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (lessons) => emit(LessonsLoaded(lessons)),
    );
  }

  Future<void> _onSearchLessonsRequested(
    SearchLessonsRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());
    
    final result = await _searchLessonsUseCase(SearchLessonsParams(query: event.query));

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (lessons) => emit(LessonsLoaded(lessons)),
    );
  }

  Future<void> _onMarkLessonAsCompletedRequested(
    MarkLessonAsCompletedRequested event,
    Emitter<LessonState> emit,
  ) async {
    final result = await _markLessonAsCompletedUseCase(
      MarkLessonAsCompletedParams(lessonId: event.lessonId),
    );

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (_) => emit(LessonMarkedAsCompleted(event.lessonId)),
    );
  }

  Future<void> _onGetLessonProgressRequested(
    GetLessonProgressRequested event,
    Emitter<LessonState> emit,
  ) async {
    final result = await _getLessonProgressUseCase(
      GetLessonProgressParams(lessonId: event.lessonId),
    );

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (progress) => emit(LessonProgressLoaded(event.lessonId, progress)),
    );
  }

  Future<void> _onGetUserProgressRequested(
    GetUserProgressRequested event,
    Emitter<LessonState> emit,
  ) async {
    final result = await _getUserProgressUseCase();

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (progress) => emit(UserProgressLoaded(progress)),
    );
  }

  Future<void> _onGetUserStatisticsRequested(
    GetUserStatisticsRequested event,
    Emitter<LessonState> emit,
  ) async {
    final result = await _getUserStatisticsUseCase();

    result.fold(
      (failure) => emit(LessonFailure(failure.message)),
      (statistics) => emit(UserStatisticsLoaded(statistics)),
    );
  }
}
