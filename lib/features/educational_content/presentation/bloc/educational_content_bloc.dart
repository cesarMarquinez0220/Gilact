import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/educational_content.dart';
import '../../domain/usecases/educational_content_usecases.dart';


part 'educational_content_event.dart';
part 'educational_content_state.dart';

@injectable
class EducationalContentBloc extends Bloc<EducationalContentEvent, EducationalContentState> {
  final GetAllEducationalContentUseCase _getAllContentUseCase;
  final GetEducationalContentByIdUseCase _getContentByIdUseCase;
  final GetEducationalContentByCategoryUseCase _getContentByCategoryUseCase;
  final SearchEducationalContentUseCase _searchContentUseCase;
  final MarkEducationalContentAsCompletedUseCase _markContentAsCompletedUseCase;
  final GetCompletedEducationalContentIdsUseCase _getCompletedContentIdsUseCase;
  final GetEducationalContentStatisticsUseCase _getContentStatisticsUseCase;

  EducationalContentBloc({
    required GetAllEducationalContentUseCase getAllContentUseCase,
    required GetEducationalContentByIdUseCase getContentByIdUseCase,
    required GetEducationalContentByCategoryUseCase getContentByCategoryUseCase,
    required SearchEducationalContentUseCase searchContentUseCase,
    required MarkEducationalContentAsCompletedUseCase markContentAsCompletedUseCase,
    required GetCompletedEducationalContentIdsUseCase getCompletedContentIdsUseCase,
    required GetEducationalContentStatisticsUseCase getContentStatisticsUseCase,
  })  : _getAllContentUseCase = getAllContentUseCase,
        _getContentByIdUseCase = getContentByIdUseCase,
        _getContentByCategoryUseCase = getContentByCategoryUseCase,
        _searchContentUseCase = searchContentUseCase,
        _markContentAsCompletedUseCase = markContentAsCompletedUseCase,
        _getCompletedContentIdsUseCase = getCompletedContentIdsUseCase,
        _getContentStatisticsUseCase = getContentStatisticsUseCase,
        super(EducationalContentInitial()) {
    on<GetAllEducationalContentRequested>(_onGetAllContentRequested);
    on<GetEducationalContentByIdRequested>(_onGetContentByIdRequested);
    on<GetEducationalContentByCategoryRequested>(_onGetContentByCategoryRequested);
    on<SearchEducationalContentRequested>(_onSearchContentRequested);
    on<MarkEducationalContentAsCompletedRequested>(_onMarkContentAsCompletedRequested);
    on<GetCompletedEducationalContentIdsRequested>(_onGetCompletedContentIdsRequested);
    on<GetEducationalContentStatisticsRequested>(_onGetContentStatisticsRequested);
  }

  Future<void> _onGetAllContentRequested(
    GetAllEducationalContentRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    emit(EducationalContentLoading());
    
    final result = await _getAllContentUseCase();

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (content) => emit(EducationalContentLoaded(content)),
    );
  }

  Future<void> _onGetContentByIdRequested(
    GetEducationalContentByIdRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    emit(EducationalContentLoading());
    
    final result = await _getContentByIdUseCase(GetEducationalContentByIdParams(id: event.id));

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (content) => emit(EducationalContentDetailLoaded(content)),
    );
  }

  Future<void> _onGetContentByCategoryRequested(
    GetEducationalContentByCategoryRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    emit(EducationalContentLoading());
    
    final result = await _getContentByCategoryUseCase(
      GetEducationalContentByCategoryParams(category: event.category),
    );

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (content) => emit(EducationalContentLoaded(content)),
    );
  }

  Future<void> _onSearchContentRequested(
    SearchEducationalContentRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    emit(EducationalContentLoading());
    
    final result = await _searchContentUseCase(SearchEducationalContentParams(query: event.query));

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (content) => emit(EducationalContentLoaded(content)),
    );
  }

  Future<void> _onMarkContentAsCompletedRequested(
    MarkEducationalContentAsCompletedRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    final result = await _markContentAsCompletedUseCase(
      MarkEducationalContentAsCompletedParams(contentId: event.contentId),
    );

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (_) => emit(EducationalContentMarkedAsCompleted(event.contentId)),
    );
  }

  Future<void> _onGetCompletedContentIdsRequested(
    GetCompletedEducationalContentIdsRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    final result = await _getCompletedContentIdsUseCase();

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (completedIds) => emit(CompletedEducationalContentIdsLoaded(completedIds)),
    );
  }

  Future<void> _onGetContentStatisticsRequested(
    GetEducationalContentStatisticsRequested event,
    Emitter<EducationalContentState> emit,
  ) async {
    final result = await _getContentStatisticsUseCase();

    result.fold(
      (failure) => emit(EducationalContentFailure(failure.message)),
      (statistics) => emit(EducationalContentStatisticsLoaded(statistics)),
    );
  }
}
