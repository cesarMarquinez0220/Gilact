import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tip.dart';

abstract class TipRepository {
  Future<Either<Failure, List<Tip>>> getAllTips();
  
  Future<Either<Failure, Tip>> getTipById(String id);
  
  Future<Either<Failure, List<Tip>>> getTipsByCategory(String category);
  
  Future<Either<Failure, List<Tip>>> searchTips(String query);
  
  Future<Either<Failure, void>> markTipAsFavorite(String tipId);
  
  Future<Either<Failure, void>> unmarkTipAsFavorite(String tipId);
  
  Future<Either<Failure, List<Tip>>> getFavoriteTips();
}
