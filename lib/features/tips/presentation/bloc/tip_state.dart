part of 'tip_bloc.dart';

abstract class TipState extends Equatable {
  const TipState();

  @override
  List<Object?> get props => [];
}

class TipInitial extends TipState {
  const TipInitial();
}

class TipLoading extends TipState {
  const TipLoading();
}

class TipsLoaded extends TipState {
  final List<Tip> tips;

  const TipsLoaded(this.tips);

  @override
  List<Object> get props => [tips];
}

class TipLoaded extends TipState {
  final Tip tip;

  const TipLoaded(this.tip);

  @override
  List<Object> get props => [tip];
}

class TipFailure extends TipState {
  final String message;

  const TipFailure(this.message);

  @override
  List<Object> get props => [message];
}

class TipMarkedAsFavorite extends TipState {
  final String tipId;

  const TipMarkedAsFavorite(this.tipId);

  @override
  List<Object> get props => [tipId];
}

class TipUnmarkedAsFavorite extends TipState {
  final String tipId;

  const TipUnmarkedAsFavorite(this.tipId);

  @override
  List<Object> get props => [tipId];
}

class FavoriteTipsLoaded extends TipState {
  final List<Tip> favoriteTips;

  const FavoriteTipsLoaded(this.favoriteTips);

  @override
  List<Object> get props => [favoriteTips];
}
