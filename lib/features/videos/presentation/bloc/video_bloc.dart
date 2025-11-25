import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/video.dart';
import '../../domain/entities/video_progress.dart';
import '../../domain/entities/video_session.dart';
import '../../domain/entities/video_statistics.dart';
import '../../domain/usecases/video_usecases.dart';

part 'video_event.dart';
part 'video_state.dart';

@injectable
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetAllVideosUseCase _getAllVideosUseCase;
  final GetVideoByIdUseCase _getVideoByIdUseCase;
  final GetVideosByLessonIdUseCase _getVideosByLessonIdUseCase;
  final SearchVideosUseCase _searchVideosUseCase;
  final MarkVideoAsCompletedUseCase _markVideoAsCompletedUseCase;
  final GetCompletedVideoIdsUseCase _getCompletedVideoIdsUseCase;
  final UpdateVideoProgressUseCase _updateVideoProgressUseCase;

  VideoBloc({
    required GetAllVideosUseCase getAllVideosUseCase,
    required GetVideoByIdUseCase getVideoByIdUseCase,
    required GetVideosByLessonIdUseCase getVideosByLessonIdUseCase,
    required SearchVideosUseCase searchVideosUseCase,
    required MarkVideoAsCompletedUseCase markVideoAsCompletedUseCase,
    required GetCompletedVideoIdsUseCase getCompletedVideoIdsUseCase,
    required UpdateVideoProgressUseCase updateVideoProgressUseCase,
  }) : _getAllVideosUseCase = getAllVideosUseCase,
       _getVideoByIdUseCase = getVideoByIdUseCase,
       _getVideosByLessonIdUseCase = getVideosByLessonIdUseCase,
       _searchVideosUseCase = searchVideosUseCase,
       _markVideoAsCompletedUseCase = markVideoAsCompletedUseCase,
       _getCompletedVideoIdsUseCase = getCompletedVideoIdsUseCase,
       _updateVideoProgressUseCase = updateVideoProgressUseCase,
       super(const VideoInitial()) {
    on<GetAllVideosRequested>(_onGetAllVideosRequested);
    on<GetVideoByIdRequested>(_onGetVideoByIdRequested);
    on<GetVideosByLessonIdRequested>(_onGetVideosByLessonIdRequested);
    on<SearchVideosRequested>(_onSearchVideosRequested);
    on<MarkVideoAsCompletedRequested>(_onMarkVideoAsCompletedRequested);
    on<GetCompletedVideoIdsRequested>(_onGetCompletedVideoIdsRequested);
    on<UpdateVideoProgressRequested>(_onUpdateVideoProgressRequested);
  }

  Future<void> _onGetAllVideosRequested(
    GetAllVideosRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    final result = await _getAllVideosUseCase();

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (videos) => emit(VideosLoaded(videos)),
    );
  }

  Future<void> _onGetVideoByIdRequested(
    GetVideoByIdRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    final result = await _getVideoByIdUseCase(GetVideoByIdParams(id: event.id));

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (video) => emit(VideoLoaded(video)),
    );
  }

  Future<void> _onGetVideosByLessonIdRequested(
    GetVideosByLessonIdRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    final result = await _getVideosByLessonIdUseCase(
      GetVideosByLessonIdParams(lessonId: event.lessonId),
    );

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (videos) => emit(VideosLoaded(videos)),
    );
  }

  Future<void> _onSearchVideosRequested(
    SearchVideosRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    final result = await _searchVideosUseCase(
      SearchVideosParams(query: event.query),
    );

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (videos) => emit(VideosLoaded(videos)),
    );
  }

  Future<void> _onMarkVideoAsCompletedRequested(
    MarkVideoAsCompletedRequested event,
    Emitter<VideoState> emit,
  ) async {
    final result = await _markVideoAsCompletedUseCase(
      MarkVideoAsCompletedParams(videoId: event.videoId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (_) => emit(VideoMarkedAsCompleted(event.videoId)),
    );
  }

  Future<void> _onGetCompletedVideoIdsRequested(
    GetCompletedVideoIdsRequested event,
    Emitter<VideoState> emit,
  ) async {
    final result = await _getCompletedVideoIdsUseCase(
      GetCompletedVideoIdsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (completedIds) => emit(CompletedVideoIdsLoaded(completedIds)),
    );
  }

  Future<void> _onUpdateVideoProgressRequested(
    UpdateVideoProgressRequested event,
    Emitter<VideoState> emit,
  ) async {
    final result = await _updateVideoProgressUseCase(
      UpdateVideoProgressParams(progress: event.progress),
    );

    result.fold(
      (failure) => emit(VideoFailure(failure.message)),
      (_) => emit(VideoProgressUpdated(event.progress)),
    );
  }
}
