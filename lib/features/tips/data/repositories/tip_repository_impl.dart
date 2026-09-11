import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/tip.dart';
import '../../domain/repositories/tip_repository.dart';
import '../datasources/tip_remote_data_source.dart';

@LazySingleton(as: TipRepository)
class TipRepositoryImpl implements TipRepository {
  final TipRemoteDataSource _remoteDataSource;

  TipRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Tip>>> getAllTips() async {
    try {
      final tipModels = await _remoteDataSource.getAllTips();
      return Right(tipModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Tip>> getTipById(String id) async {
    try {
      final tipModel = await _remoteDataSource.getTipById(id);
      return Right(tipModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Tip>>> getTipsByCategory(String category) async {
    try {
      final tipModels = await _remoteDataSource.getTipsByCategory(category);
      return Right(tipModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Tip>>> searchTips(String query) async {
    try {
      final tipModels = await _remoteDataSource.searchTips(query);
      return Right(tipModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markTipAsFavorite(String tipId) async {
    try {
      await _remoteDataSource.markTipAsFavorite(tipId);
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
  Future<Either<Failure, void>> unmarkTipAsFavorite(String tipId) async {
    try {
      await _remoteDataSource.unmarkTipAsFavorite(tipId);
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
  Future<Either<Failure, List<Tip>>> getFavoriteTips() async {
    try {
      final tipModels = await _remoteDataSource.getFavoriteTips();
      return Right(tipModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
