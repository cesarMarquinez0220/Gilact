import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/educational_content.dart';
import '../../domain/repositories/educational_content_repository.dart';
import '../datasources/educational_content_remote_data_source.dart';

@LazySingleton(as: EducationalContentRepository)
class EducationalContentRepositoryImpl implements EducationalContentRepository {
  final EducationalContentRemoteDataSource _remoteDataSource;

  EducationalContentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<EducationalContent>>> getAllContent() async {
    try {
      final contentModels = await _remoteDataSource.getAllContent();
      return Right(contentModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, EducationalContent>> getContentById(String id) async {
    try {
      final contentModel = await _remoteDataSource.getContentById(id);
      return Right(contentModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<EducationalContent>>> getContentByCategory(String category) async {
    try {
      final contentModels = await _remoteDataSource.getContentByCategory(category);
      return Right(contentModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<EducationalContent>>> searchContent(String query) async {
    try {
      final contentModels = await _remoteDataSource.searchContent(query);
      return Right(contentModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markContentAsCompleted(String contentId) async {
    try {
      await _remoteDataSource.markContentAsCompleted(contentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCompletedContentIds() async {
    try {
      final completedIds = await _remoteDataSource.getCompletedContentIds();
      return Right(completedIds);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getContentStatistics() async {
    try {
      final statistics = await _remoteDataSource.getContentStatistics();
      return Right(statistics);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
