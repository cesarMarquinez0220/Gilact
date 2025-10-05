part of 'educational_content_bloc.dart';

abstract class EducationalContentState extends Equatable {
  const EducationalContentState();

  @override
  List<Object?> get props => [];
}

class EducationalContentInitial extends EducationalContentState {
  const EducationalContentInitial();
}

class EducationalContentLoading extends EducationalContentState {
  const EducationalContentLoading();
}

class EducationalContentLoaded extends EducationalContentState {
  final List<EducationalContent> content;

  const EducationalContentLoaded(this.content);

  @override
  List<Object> get props => [content];
}

class EducationalContentDetailLoaded extends EducationalContentState {
  final EducationalContent content;

  const EducationalContentDetailLoaded(this.content);

  @override
  List<Object> get props => [content];
}

class EducationalContentFailure extends EducationalContentState {
  final String message;

  const EducationalContentFailure(this.message);

  @override
  List<Object> get props => [message];
}

class EducationalContentMarkedAsCompleted extends EducationalContentState {
  final String contentId;

  const EducationalContentMarkedAsCompleted(this.contentId);

  @override
  List<Object> get props => [contentId];
}

class CompletedEducationalContentIdsLoaded extends EducationalContentState {
  final List<String> completedIds;

  const CompletedEducationalContentIdsLoaded(this.completedIds);

  @override
  List<Object> get props => [completedIds];
}

class EducationalContentStatisticsLoaded extends EducationalContentState {
  final Map<String, dynamic> statistics;

  const EducationalContentStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}
