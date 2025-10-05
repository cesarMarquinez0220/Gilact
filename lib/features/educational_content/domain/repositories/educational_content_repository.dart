import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/educational_content.dart';

abstract class EducationalContentRepository {
  Future<Either<Failure, List<EducationalContent>>> getAllContent();
  
  Future<Either<Failure, EducationalContent>> getContentById(String id);
  
  Future<Either<Failure, List<EducationalContent>>> getContentByCategory(String category);
  
  Future<Either<Failure, List<EducationalContent>>> searchContent(String query);
  
  Future<Either<Failure, void>> markContentAsCompleted(String contentId);
  
  Future<Either<Failure, List<String>>> getCompletedContentIds();
  
  Future<Either<Failure, Map<String, dynamic>>> getContentStatistics();
}
