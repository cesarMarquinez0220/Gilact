part of 'educational_content_bloc.dart';

abstract class EducationalContentEvent extends Equatable {
  const EducationalContentEvent();

  @override
  List<Object?> get props => [];
}

class GetAllEducationalContentRequested extends EducationalContentEvent {
  const GetAllEducationalContentRequested();
}

class GetEducationalContentByIdRequested extends EducationalContentEvent {
  final String id;

  const GetEducationalContentByIdRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class GetEducationalContentByCategoryRequested extends EducationalContentEvent {
  final String category;

  const GetEducationalContentByCategoryRequested({required this.category});

  @override
  List<Object> get props => [category];
}

class SearchEducationalContentRequested extends EducationalContentEvent {
  final String query;

  const SearchEducationalContentRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class MarkEducationalContentAsCompletedRequested extends EducationalContentEvent {
  final String contentId;

  const MarkEducationalContentAsCompletedRequested({required this.contentId});

  @override
  List<Object> get props => [contentId];
}

class GetCompletedEducationalContentIdsRequested extends EducationalContentEvent {
  const GetCompletedEducationalContentIdsRequested();
}

class GetEducationalContentStatisticsRequested extends EducationalContentEvent {
  const GetEducationalContentStatisticsRequested();
}
