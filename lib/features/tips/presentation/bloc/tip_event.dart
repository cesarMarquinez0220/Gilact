part of 'tip_bloc.dart';

abstract class TipEvent extends Equatable {
  const TipEvent();

  @override
  List<Object?> get props => [];
}

class GetAllTipsRequested extends TipEvent {
  const GetAllTipsRequested();
}

class GetTipByIdRequested extends TipEvent {
  final String id;

  const GetTipByIdRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class GetTipsByCategoryRequested extends TipEvent {
  final String category;

  const GetTipsByCategoryRequested({required this.category});

  @override
  List<Object> get props => [category];
}

class SearchTipsRequested extends TipEvent {
  final String query;

  const SearchTipsRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class MarkTipAsFavoriteRequested extends TipEvent {
  final String tipId;

  const MarkTipAsFavoriteRequested({required this.tipId});

  @override
  List<Object> get props => [tipId];
}

class UnmarkTipAsFavoriteRequested extends TipEvent {
  final String tipId;

  const UnmarkTipAsFavoriteRequested({required this.tipId});

  @override
  List<Object> get props => [tipId];
}

class GetFavoriteTipsRequested extends TipEvent {
  const GetFavoriteTipsRequested();
}
