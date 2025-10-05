part of 'ui_bloc.dart';

abstract class UIState extends Equatable {
  const UIState();

  @override
  List<Object?> get props => [];
}

class UIInitial extends UIState {}

class UILoading extends UIState {}

class UIFailure extends UIState {
  final String message;

  const UIFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SplashPagesLoaded extends UIState {
  final List<SplashPage> splashPages;

  const SplashPagesLoaded(this.splashPages);

  @override
  List<Object?> get props => [splashPages];
}

class LessonProgressStateLoaded extends UIState {
  final LessonProgressState progressState;

  const LessonProgressStateLoaded(this.progressState);

  @override
  List<Object?> get props => [progressState];
}
