import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';

@LazySingleton(as: LessonRepository)
class LessonRepositoryImpl implements LessonRepository {
  @override
  Future<Either<Failure, List<Lesson>>> getAllLessons() async {
    try {
      // Datos mock para las lecciones
      final lessons = [
        Lesson(
          id: '1',
          title: 'Introducción a la Lactancia Materna',
          description: 'Aprende los conceptos básicos de la lactancia materna',
          category: 'Básico',
          imageUrl: 'mother.png',
          order: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          progress: 0.0,
          isCompleted: false,
          videoIds: ['1', '2'],
        ),
        Lesson(
          id: '2',
          title: 'Posiciones Correctas',
          description: 'Descubre las mejores posiciones para amamantar',
          category: 'Técnica',
          imageUrl: 'mother2.png',
          order: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          progress: 0.3,
          isCompleted: false,
          videoIds: ['3', '4'],
        ),
        Lesson(
          id: '3',
          title: 'Beneficios para el Bebé',
          description: 'Conoce todos los beneficios de la lactancia materna',
          category: 'Beneficios',
          imageUrl: 'bebe1.png',
          order: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          progress: 0.8,
          isCompleted: false,
          videoIds: ['5', '6'],
        ),
        Lesson(
          id: '4',
          title: 'Alimentación Complementaria',
          description: 'Cuándo y cómo introducir alimentos sólidos',
          category: 'Alimentación',
          imageUrl: 'food1.png',
          order: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
          progress: 1.0,
          isCompleted: true,
          videoIds: ['7', '8'],
        ),
      ];

      return Right(lessons);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al cargar lecciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Lesson>> getLessonById(String id) async {
    try {
      final result = await getAllLessons();
      return result.fold((failure) => Left(failure), (lessons) {
        final lesson = lessons.firstWhere((lesson) => lesson.id == id);
        return Right(lesson);
      });
    } catch (e) {
      return Left(NotFoundFailure(message: 'Lección no encontrada'));
    }
  }

  @override
  Future<Either<Failure, List<Lesson>>> getLessonsByCategory(
    String category,
  ) async {
    try {
      final result = await getAllLessons();
      return result.fold((failure) => Left(failure), (lessons) {
        final filteredLessons = lessons
            .where((lesson) => lesson.category == category)
            .toList();
        return Right(filteredLessons);
      });
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al filtrar lecciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Lesson>>> searchLessons(String query) async {
    try {
      final result = await getAllLessons();
      return result.fold((failure) => Left(failure), (lessons) {
        final filteredLessons = lessons
            .where(
              (lesson) =>
                  lesson.title.toLowerCase().contains(query.toLowerCase()) ||
                  lesson.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
        return Right(filteredLessons);
      });
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al buscar lecciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markLessonAsCompleted(String lessonId) async {
    try {
      // En una implementación real, esto guardaría en la base de datos
      // Por ahora solo simulamos el éxito
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al marcar lección como completada: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getLessonProgress(String lessonId) async {
    try {
      final result = await getLessonById(lessonId);
      return result.fold(
        (failure) => Left(failure),
        (lesson) => Right(lesson.progress),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al obtener progreso: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getUserProgress() async {
    try {
      final result = await getAllLessons();
      return result.fold((failure) => Left(failure), (lessons) {
        final progress = <String, double>{};
        for (final lesson in lessons) {
          progress[lesson.id] = lesson.progress;
        }
        return Right(progress);
      });
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener progreso del usuario: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics() async {
    try {
      final result = await getAllLessons();
      return result.fold((failure) => Left(failure), (lessons) {
        final completedLessons = lessons
            .where((lesson) => lesson.isCompleted)
            .length;
        final totalLessons = lessons.length;
        final totalVideos = lessons.fold(
          0,
          (sum, lesson) => sum + lesson.videoIds.length,
        );
        final overallProgress =
            lessons.fold(0.0, (sum, lesson) => sum + lesson.progress) /
            totalLessons;

        final statistics = {
          'completedLessons': completedLessons,
          'totalLessons': totalLessons,
          'completedVideos': (totalVideos * overallProgress).round(),
          'totalVideos': totalVideos,
          'totalTime': '${(totalVideos * 10).toString()} min', // Simulación
          'overallProgress': (overallProgress * 100).round(),
        };

        return Right(statistics);
      });
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener estadísticas: ${e.toString()}',
        ),
      );
    }
  }
}
