import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

@injectable
class GetAllLessonsUseCase implements UseCaseNoParams<List<Lesson>> {
  final LessonRepository repository;

  GetAllLessonsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Lesson>>> call() async {
    return await repository.getAllLessons();
  }
}

@injectable
class GetLessonByIdUseCase implements UseCase<Lesson, GetLessonByIdParams> {
  final LessonRepository repository;

  GetLessonByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Lesson>> call(GetLessonByIdParams params) async {
    return await repository.getLessonById(params.id);
  }
}

@injectable
class GetLessonsByCategoryUseCase implements UseCase<List<Lesson>, GetLessonsByCategoryParams> {
  final LessonRepository repository;

  GetLessonsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Lesson>>> call(GetLessonsByCategoryParams params) async {
    return await repository.getLessonsByCategory(params.category);
  }
}

@injectable
class SearchLessonsUseCase implements UseCase<List<Lesson>, SearchLessonsParams> {
  final LessonRepository repository;

  SearchLessonsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Lesson>>> call(SearchLessonsParams params) async {
    return await repository.searchLessons(params.query);
  }
}

@injectable
class MarkLessonAsCompletedUseCase implements UseCase<void, MarkLessonAsCompletedParams> {
  final LessonRepository repository;

  MarkLessonAsCompletedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkLessonAsCompletedParams params) async {
    return await repository.markLessonAsCompleted(params.lessonId);
  }
}

@injectable
class GetLessonProgressUseCase implements UseCase<double, GetLessonProgressParams> {
  final LessonRepository repository;

  GetLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(GetLessonProgressParams params) async {
    return await repository.getLessonProgress(params.lessonId);
  }
}

@injectable
class GetUserProgressUseCase implements UseCaseNoParams<Map<String, double>> {
  final LessonRepository repository;

  GetUserProgressUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, double>>> call() async {
    return await repository.getUserProgress();
  }
}

@injectable
class GetUserStatisticsUseCase implements UseCaseNoParams<Map<String, dynamic>> {
  final LessonRepository repository;

  GetUserStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getUserStatistics();
  }
}

// Parámetros para los casos de uso
class GetLessonByIdParams {
  final String id;

  GetLessonByIdParams({required this.id});
}

class GetLessonsByCategoryParams {
  final String category;

  GetLessonsByCategoryParams({required this.category});
}

class SearchLessonsParams {
  final String query;

  SearchLessonsParams({required this.query});
}

class MarkLessonAsCompletedParams {
  final String lessonId;

  MarkLessonAsCompletedParams({required this.lessonId});
}

class GetLessonProgressParams {
  final String lessonId;

  GetLessonProgressParams({required this.lessonId});
}
