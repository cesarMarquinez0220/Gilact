import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/educational_content.dart';
import '../repositories/educational_content_repository.dart';

@injectable
class GetAllEducationalContentUseCase
    implements UseCaseNoParams<List<EducationalContent>> {
  final EducationalContentRepository repository;

  GetAllEducationalContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<EducationalContent>>> call() async {
    return await repository.getAllContent();
  }
}

@injectable
class GetEducationalContentByIdUseCase
    implements UseCase<EducationalContent, GetEducationalContentByIdParams> {
  final EducationalContentRepository repository;

  GetEducationalContentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, EducationalContent>> call(
    GetEducationalContentByIdParams params,
  ) async {
    return await repository.getContentById(params.id);
  }
}

@injectable
class GetEducationalContentByCategoryUseCase
    implements
        UseCase<
          List<EducationalContent>,
          GetEducationalContentByCategoryParams
        > {
  final EducationalContentRepository repository;

  GetEducationalContentByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<EducationalContent>>> call(
    GetEducationalContentByCategoryParams params,
  ) async {
    return await repository.getContentByCategory(params.category);
  }
}

@injectable
class SearchEducationalContentUseCase
    implements
        UseCase<List<EducationalContent>, SearchEducationalContentParams> {
  final EducationalContentRepository repository;

  SearchEducationalContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<EducationalContent>>> call(
    SearchEducationalContentParams params,
  ) async {
    return await repository.searchContent(params.query);
  }
}

@injectable
class MarkEducationalContentAsCompletedUseCase
    implements UseCase<void, MarkEducationalContentAsCompletedParams> {
  final EducationalContentRepository repository;

  MarkEducationalContentAsCompletedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    MarkEducationalContentAsCompletedParams params,
  ) async {
    return await repository.markContentAsCompleted(params.contentId);
  }
}

@injectable
class GetCompletedEducationalContentIdsUseCase
    implements UseCaseNoParams<List<String>> {
  final EducationalContentRepository repository;

  GetCompletedEducationalContentIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call() async {
    return await repository.getCompletedContentIds();
  }
}

@injectable
class GetEducationalContentStatisticsUseCase
    implements UseCaseNoParams<Map<String, dynamic>> {
  final EducationalContentRepository repository;

  GetEducationalContentStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getContentStatistics();
  }
}

// Parámetros para los casos de uso
class GetEducationalContentByIdParams {
  final String id;

  GetEducationalContentByIdParams({required this.id});
}

class GetEducationalContentByCategoryParams {
  final String category;

  GetEducationalContentByCategoryParams({required this.category});
}

class SearchEducationalContentParams {
  final String query;

  SearchEducationalContentParams({required this.query});
}

class MarkEducationalContentAsCompletedParams {
  final String contentId;

  MarkEducationalContentAsCompletedParams({required this.contentId});
}
