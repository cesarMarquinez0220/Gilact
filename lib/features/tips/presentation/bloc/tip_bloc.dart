import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/tip.dart';
import '../../domain/usecases/tip_usecases.dart';

part 'tip_event.dart';
part 'tip_state.dart';

@injectable
class TipBloc extends Bloc<TipEvent, TipState> {
  final GetAllTipsUseCase _getAllTipsUseCase;
  final GetTipByIdUseCase _getTipByIdUseCase;
  final GetTipsByCategoryUseCase _getTipsByCategoryUseCase;
  final SearchTipsUseCase _searchTipsUseCase;
  final MarkTipAsFavoriteUseCase _markTipAsFavoriteUseCase;
  final UnmarkTipAsFavoriteUseCase _unmarkTipAsFavoriteUseCase;
  final GetFavoriteTipsUseCase _getFavoriteTipsUseCase;

  TipBloc({
    required GetAllTipsUseCase getAllTipsUseCase,
    required GetTipByIdUseCase getTipByIdUseCase,
    required GetTipsByCategoryUseCase getTipsByCategoryUseCase,
    required SearchTipsUseCase searchTipsUseCase,
    required MarkTipAsFavoriteUseCase markTipAsFavoriteUseCase,
    required UnmarkTipAsFavoriteUseCase unmarkTipAsFavoriteUseCase,
    required GetFavoriteTipsUseCase getFavoriteTipsUseCase,
  }) : _getAllTipsUseCase = getAllTipsUseCase,
       _getTipByIdUseCase = getTipByIdUseCase,
       _getTipsByCategoryUseCase = getTipsByCategoryUseCase,
       _searchTipsUseCase = searchTipsUseCase,
       _markTipAsFavoriteUseCase = markTipAsFavoriteUseCase,
       _unmarkTipAsFavoriteUseCase = unmarkTipAsFavoriteUseCase,
       _getFavoriteTipsUseCase = getFavoriteTipsUseCase,
       super(const TipInitial()) {
    on<GetAllTipsRequested>(_onGetAllTipsRequested);
    on<GetTipByIdRequested>(_onGetTipByIdRequested);
    on<GetTipsByCategoryRequested>(_onGetTipsByCategoryRequested);
    on<SearchTipsRequested>(_onSearchTipsRequested);
    on<MarkTipAsFavoriteRequested>(_onMarkTipAsFavoriteRequested);
    on<UnmarkTipAsFavoriteRequested>(_onUnmarkTipAsFavoriteRequested);
    on<GetFavoriteTipsRequested>(_onGetFavoriteTipsRequested);
  }

  Future<void> _onGetAllTipsRequested(
    GetAllTipsRequested event,
    Emitter<TipState> emit,
  ) async {
    emit(const TipLoading());

    final result = await _getAllTipsUseCase();

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (tips) => emit(TipsLoaded(tips)),
    );
  }

  Future<void> _onGetTipByIdRequested(
    GetTipByIdRequested event,
    Emitter<TipState> emit,
  ) async {
    emit(const TipLoading());

    final result = await _getTipByIdUseCase(GetTipByIdParams(id: event.id));

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (tip) => emit(TipLoaded(tip)),
    );
  }

  Future<void> _onGetTipsByCategoryRequested(
    GetTipsByCategoryRequested event,
    Emitter<TipState> emit,
  ) async {
    emit(const TipLoading());

    final result = await _getTipsByCategoryUseCase(
      GetTipsByCategoryParams(category: event.category),
    );

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (tips) => emit(TipsLoaded(tips)),
    );
  }

  Future<void> _onSearchTipsRequested(
    SearchTipsRequested event,
    Emitter<TipState> emit,
  ) async {
    emit(const TipLoading());

    final result = await _searchTipsUseCase(
      SearchTipsParams(query: event.query),
    );

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (tips) => emit(TipsLoaded(tips)),
    );
  }

  Future<void> _onMarkTipAsFavoriteRequested(
    MarkTipAsFavoriteRequested event,
    Emitter<TipState> emit,
  ) async {
    final result = await _markTipAsFavoriteUseCase(
      MarkTipAsFavoriteParams(tipId: event.tipId),
    );

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (_) => emit(TipMarkedAsFavorite(event.tipId)),
    );
  }

  Future<void> _onUnmarkTipAsFavoriteRequested(
    UnmarkTipAsFavoriteRequested event,
    Emitter<TipState> emit,
  ) async {
    final result = await _unmarkTipAsFavoriteUseCase(
      UnmarkTipAsFavoriteParams(tipId: event.tipId),
    );

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (_) => emit(TipUnmarkedAsFavorite(event.tipId)),
    );
  }

  Future<void> _onGetFavoriteTipsRequested(
    GetFavoriteTipsRequested event,
    Emitter<TipState> emit,
  ) async {
    final result = await _getFavoriteTipsUseCase();

    result.fold(
      (failure) => emit(TipFailure(failure.message)),
      (tips) => emit(FavoriteTipsLoaded(tips)),
    );
  }
}
