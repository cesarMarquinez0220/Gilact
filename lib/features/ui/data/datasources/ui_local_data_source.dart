import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/ui_entities.dart';

abstract class UILocalDataSource {
  Future<List<SplashPage>> getSplashPages();
  Future<LessonProgressState> getLessonProgressState();
  Future<LessonProgressState> updateLessonProgress(
    int lessonId,
    bool isCompleted,
  );
  Future<LessonProgressState> updateVideoProgress(int videoId, double progress);
  Future<LessonProgressState> markVideoAsWatched(int videoId);
  Future<LessonProgressState> updateCompletedVideosList(
    List<int> completedVideoIds,
  );
  Future<LessonProgressState> updateLastCompletedLesson(int lessonNumber);
}

class UILocalDataSourceImpl implements UILocalDataSource {
  final SharedPreferences sharedPreferences;

  UILocalDataSourceImpl({required this.sharedPreferences});

  static const String _lessonProgressKey = 'lesson_progress';
  static const String _videoProgressKey = 'video_progress';
  static const String _lastCompletedLessonKey = 'last_completed_lesson';

  @override
  Future<List<SplashPage>> getSplashPages() async {
    try {
      // Retornar páginas estáticas del splash screen
      return [
        const SplashPage(
          id: 1,
          title: 'Nada se compara con la',
          subtitle: 'Leche Materna!',
          description:
              'Es el mejor alimento para el lactante. \n Es un complejo fluido nutricional vivo que contiene anticuerpos, enzimas, ácidos grasos y hormonas.',
          imagePath: 'assets/images/mother.png',
          additionalText: '¡Amamanta con orgullo!',
        ),
        const SplashPage(
          id: 2,
          title: 'Beneficios para el bebé',
          subtitle: 'Protección contra \n enfermedades como:',
          description:
              'Diarrea \n Alergias \n Resfriados \n Infecciones del oído \n Síndrome de muerte en la cuna \n (muerte súbita)',
          imagePath: 'assets/images/mother2.png',
        ),
        const SplashPage(
          id: 3,
          title: 'Beneficios para el bebé',
          subtitle: 'Disminuye la posibilidad \n de enfermarse de:',
          description:
              'Diabetes\n Hipertensión arterial \n Obesidad \n Cáncer (leucemia, linfoma)',
          imagePath: 'assets/images/mother3.png',
          isLastPage: true,
          autoNavigateDelay: Duration(seconds: 2),
        ),
      ];
    } catch (e) {
      throw Exception('Error al obtener páginas del splash: $e');
    }
  }

  @override
  Future<LessonProgressState> getLessonProgressState() async {
    try {
      final lessonsJson = sharedPreferences.getString(_lessonProgressKey);
      final videoProgressJson = sharedPreferences.getString(_videoProgressKey);
      final lastCompletedLesson =
          sharedPreferences.getInt(_lastCompletedLessonKey) ?? 0;

      Map<int, bool> lessonsStatus = {};
      Map<int, double> videoProgress = {};

      if (lessonsJson != null) {
        final Map<String, dynamic> lessonsMap = json.decode(lessonsJson);
        lessonsStatus = lessonsMap.map(
          (key, value) => MapEntry(int.parse(key), value as bool),
        );
      } else {
        // Estado inicial
        lessonsStatus = {
          1: true, // video 1
          2: false, // video 2.1
          3: false, // video 2.2
          4: false, // video 3.1
          5: false, // video 3.2
          6: false, // video 3.3
          7: false, // video 3.4
          8: false, // video 4.1
          9: false, // video 4.2
          10: false, // video 5
          11: false, // video 6
          12: false, // video 7
          13: false, // video 8.1
          14: false, // video 8.2
          15: false, // video 9
          16: false, // video 10
          17: false, // video 11.1
          18: false, // video 11.2
          19: false, // video 11.3
          20: false, // video 11.4
          21: false, // video 11.5
          22: false, // video 12
          23: false, // video 13.1
          24: false, // video 13.2
          25: false, // video 13.3
          26: false, // video 14.1
          27: false, // video 14.2
          28: false, // video 15
          29: false, // video 16
        };
      }

      if (videoProgressJson != null) {
        final Map<String, dynamic> progressMap = json.decode(videoProgressJson);
        videoProgress = progressMap.map(
          (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
        );
      }

      return LessonProgressState(
        lessonsStatus: lessonsStatus,
        lastCompletedLesson: lastCompletedLesson,
        videoProgress: videoProgress,
      );
    } catch (e) {
      throw Exception('Error al obtener estado de progreso: $e');
    }
  }

  @override
  Future<LessonProgressState> updateLessonProgress(
    int lessonId,
    bool isCompleted,
  ) async {
    try {
      final currentState = await getLessonProgressState();
      final updatedLessonsStatus = Map<int, bool>.from(
        currentState.lessonsStatus,
      );

      updatedLessonsStatus[lessonId] = isCompleted;

      // Si se marca como completado, habilitar el siguiente video
      if (isCompleted) {
        int siguienteId = lessonId + 1;
        if (updatedLessonsStatus.containsKey(siguienteId)) {
          updatedLessonsStatus[siguienteId] = true;
        }
      }

      await sharedPreferences.setString(
        _lessonProgressKey,
        json.encode(
          updatedLessonsStatus.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      return LessonProgressState(
        lessonsStatus: updatedLessonsStatus,
        lastCompletedLesson: currentState.lastCompletedLesson,
        videoProgress: currentState.videoProgress,
      );
    } catch (e) {
      throw Exception('Error al actualizar progreso de lección: $e');
    }
  }

  @override
  Future<LessonProgressState> updateVideoProgress(
    int videoId,
    double progress,
  ) async {
    try {
      final currentState = await getLessonProgressState();
      final updatedVideoProgress = Map<int, double>.from(
        currentState.videoProgress,
      );

      updatedVideoProgress[videoId] = progress;

      await sharedPreferences.setString(
        _videoProgressKey,
        json.encode(
          updatedVideoProgress.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      return LessonProgressState(
        lessonsStatus: currentState.lessonsStatus,
        lastCompletedLesson: currentState.lastCompletedLesson,
        videoProgress: updatedVideoProgress,
      );
    } catch (e) {
      throw Exception('Error al actualizar progreso de video: $e');
    }
  }

  @override
  Future<LessonProgressState> markVideoAsWatched(int videoId) async {
    try {
      final currentState = await getLessonProgressState();
      final updatedLessonsStatus = Map<int, bool>.from(
        currentState.lessonsStatus,
      );
      final updatedVideoProgress = Map<int, double>.from(
        currentState.videoProgress,
      );

      updatedLessonsStatus[videoId] = true;
      updatedVideoProgress[videoId] = 1.0;

      // Habilitar el siguiente video
      int siguienteId = videoId + 1;
      if (updatedLessonsStatus.containsKey(siguienteId)) {
        updatedLessonsStatus[siguienteId] = true;
      }

      await sharedPreferences.setString(
        _lessonProgressKey,
        json.encode(
          updatedLessonsStatus.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      await sharedPreferences.setString(
        _videoProgressKey,
        json.encode(
          updatedVideoProgress.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      return LessonProgressState(
        lessonsStatus: updatedLessonsStatus,
        lastCompletedLesson: currentState.lastCompletedLesson,
        videoProgress: updatedVideoProgress,
      );
    } catch (e) {
      throw Exception('Error al marcar video como visto: $e');
    }
  }

  @override
  Future<LessonProgressState> updateCompletedVideosList(
    List<int> completedVideoIds,
  ) async {
    try {
      final currentState = await getLessonProgressState();
      final updatedLessonsStatus = Map<int, bool>.from(
        currentState.lessonsStatus,
      );
      final updatedVideoProgress = Map<int, double>.from(
        currentState.videoProgress,
      );

      for (var id in completedVideoIds) {
        updatedLessonsStatus[id] = true;
        updatedVideoProgress[id] = 1.0;

        // Habilitar el siguiente video
        int siguienteId = id + 1;
        if (updatedLessonsStatus.containsKey(siguienteId)) {
          updatedLessonsStatus[siguienteId] = true;
        }
      }

      await sharedPreferences.setString(
        _lessonProgressKey,
        json.encode(
          updatedLessonsStatus.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      await sharedPreferences.setString(
        _videoProgressKey,
        json.encode(
          updatedVideoProgress.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );

      return LessonProgressState(
        lessonsStatus: updatedLessonsStatus,
        lastCompletedLesson: currentState.lastCompletedLesson,
        videoProgress: updatedVideoProgress,
      );
    } catch (e) {
      throw Exception('Error al actualizar lista de videos completados: $e');
    }
  }

  @override
  Future<LessonProgressState> updateLastCompletedLesson(
    int lessonNumber,
  ) async {
    try {
      final currentState = await getLessonProgressState();

      await sharedPreferences.setInt(_lastCompletedLessonKey, lessonNumber);

      return LessonProgressState(
        lessonsStatus: currentState.lessonsStatus,
        lastCompletedLesson: lessonNumber,
        videoProgress: currentState.videoProgress,
      );
    } catch (e) {
      throw Exception('Error al actualizar última lección completada: $e');
    }
  }
}
