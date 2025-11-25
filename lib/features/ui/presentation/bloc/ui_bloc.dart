import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/ui_entities.dart';
import '../../domain/usecases/ui_usecases.dart';

part 'ui_event.dart';
part 'ui_state.dart';

class UIBloc extends Bloc<UIEvent, UIState> {
  final GetSplashPagesUseCase getSplashPagesUseCase;
  final GetLessonProgressStateUseCase getLessonProgressStateUseCase;
  final UpdateLessonProgressUseCase updateLessonProgressUseCase;
  final UpdateVideoProgressUseCase updateVideoProgressUseCase;
  final MarkVideoAsWatchedUseCase markVideoAsWatchedUseCase;
  final UpdateCompletedVideosListUseCase updateCompletedVideosListUseCase;
  final UpdateLastCompletedLessonUseCase updateLastCompletedLessonUseCase;

  UIBloc({
    required this.getSplashPagesUseCase,
    required this.getLessonProgressStateUseCase,
    required this.updateLessonProgressUseCase,
    required this.updateVideoProgressUseCase,
    required this.markVideoAsWatchedUseCase,
    required this.updateCompletedVideosListUseCase,
    required this.updateLastCompletedLessonUseCase,
  }) : super(UIInitial()) {
    on<LoadSplashPages>(_onLoadSplashPages);
    on<LoadLessonProgressState>(_onLoadLessonProgressState);
    on<UpdateLessonProgress>(_onUpdateLessonProgress);
    on<UpdateVideoProgress>(_onUpdateVideoProgress);
    on<MarkVideoAsWatched>(_onMarkVideoAsWatched);
    on<UpdateCompletedVideosList>(_onUpdateCompletedVideosList);
    on<UpdateLastCompletedLesson>(_onUpdateLastCompletedLesson);
  }

  Future<void> _onLoadSplashPages(
    LoadSplashPages event,
    Emitter<UIState> emit,
  ) async {
    emit(UILoading());

    final result = await getSplashPagesUseCase(const NoParams());

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (splashPages) => emit(SplashPagesLoaded(splashPages)),
    );
  }

  Future<void> _onLoadLessonProgressState(
    LoadLessonProgressState event,
    Emitter<UIState> emit,
  ) async {
    emit(UILoading());

    final result = await getLessonProgressStateUseCase(const NoParams());

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }

  Future<void> _onUpdateLessonProgress(
    UpdateLessonProgress event,
    Emitter<UIState> emit,
  ) async {
    final result = await updateLessonProgressUseCase({
      'lessonId': event.lessonId,
      'isCompleted': event.isCompleted,
    });

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }

  Future<void> _onUpdateVideoProgress(
    UpdateVideoProgress event,
    Emitter<UIState> emit,
  ) async {
    final result = await updateVideoProgressUseCase({
      'videoId': event.videoId,
      'progress': event.progress,
    });

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }

  Future<void> _onMarkVideoAsWatched(
    MarkVideoAsWatched event,
    Emitter<UIState> emit,
  ) async {
    final result = await markVideoAsWatchedUseCase(event.videoId);

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }

  Future<void> _onUpdateCompletedVideosList(
    UpdateCompletedVideosList event,
    Emitter<UIState> emit,
  ) async {
    final result = await updateCompletedVideosListUseCase(
      event.completedVideoIds,
    );

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }

  Future<void> _onUpdateLastCompletedLesson(
    UpdateLastCompletedLesson event,
    Emitter<UIState> emit,
  ) async {
    final result = await updateLastCompletedLessonUseCase(event.lessonNumber);

    result.fold(
      (failure) => emit(UIFailure(failure.message)),
      (progressState) => emit(LessonProgressStateLoaded(progressState)),
    );
  }
}
