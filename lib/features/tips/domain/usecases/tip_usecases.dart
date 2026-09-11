import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/tip.dart';
import '../repositories/tip_repository.dart';

@injectable
class GetAllTipsUseCase implements UseCaseNoParams<List<Tip>> {
  final TipRepository repository;

  GetAllTipsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Tip>>> call() async {
    return await repository.getAllTips();
  }
}

@injectable
class GetTipByIdUseCase implements UseCase<Tip, GetTipByIdParams> {
  final TipRepository repository;

  GetTipByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Tip>> call(GetTipByIdParams params) async {
    return await repository.getTipById(params.id);
  }
}

@injectable
class GetTipsByCategoryUseCase implements UseCase<List<Tip>, GetTipsByCategoryParams> {
  final TipRepository repository;

  GetTipsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Tip>>> call(GetTipsByCategoryParams params) async {
    return await repository.getTipsByCategory(params.category);
  }
}

@injectable
class SearchTipsUseCase implements UseCase<List<Tip>, SearchTipsParams> {
  final TipRepository repository;

  SearchTipsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Tip>>> call(SearchTipsParams params) async {
    return await repository.searchTips(params.query);
  }
}

@injectable
class MarkTipAsFavoriteUseCase implements UseCase<void, MarkTipAsFavoriteParams> {
  final TipRepository repository;

  MarkTipAsFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkTipAsFavoriteParams params) async {
    return await repository.markTipAsFavorite(params.tipId);
  }
}

@injectable
class UnmarkTipAsFavoriteUseCase implements UseCase<void, UnmarkTipAsFavoriteParams> {
  final TipRepository repository;

  UnmarkTipAsFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UnmarkTipAsFavoriteParams params) async {
    return await repository.unmarkTipAsFavorite(params.tipId);
  }
}

@injectable
class GetFavoriteTipsUseCase implements UseCaseNoParams<List<Tip>> {
  final TipRepository repository;

  GetFavoriteTipsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Tip>>> call() async {
    return await repository.getFavoriteTips();
  }
}

// Parámetros para los casos de uso
class GetTipByIdParams {
  final String id;

  GetTipByIdParams({required this.id});
}

class GetTipsByCategoryParams {
  final String category;

  GetTipsByCategoryParams({required this.category});
}

class SearchTipsParams {
  final String query;

  SearchTipsParams({required this.query});
}

class MarkTipAsFavoriteParams {
  final String tipId;

  MarkTipAsFavoriteParams({required this.tipId});
}

class UnmarkTipAsFavoriteParams {
  final String tipId;

  UnmarkTipAsFavoriteParams({required this.tipId});
}
