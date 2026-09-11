import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<Either<Failure, List<Lesson>>> getAllLessons();
  
  Future<Either<Failure, Lesson>> getLessonById(String id);
  
  Future<Either<Failure, List<Lesson>>> getLessonsByCategory(String category);
  
  Future<Either<Failure, List<Lesson>>> searchLessons(String query);
  
  Future<Either<Failure, void>> markLessonAsCompleted(String lessonId);
  
  Future<Either<Failure, double>> getLessonProgress(String lessonId);
  
  Future<Either<Failure, Map<String, double>>> getUserProgress();
  
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics();
}
