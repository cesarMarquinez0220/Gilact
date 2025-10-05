import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ui_entities.dart';
import '../bloc/ui_bloc.dart';

class LessonProgressService extends ChangeNotifier {
  LessonProgressState _currentState = const LessonProgressState(
    lessonsStatus: {},
    lastCompletedLesson: 0,
    videoProgress: {},
  );

  LessonProgressState get currentState => _currentState;

  // Métodos para actualizar el estado
  void updateLessonProgress(int lessonId, bool isCompleted) {
    final updatedLessonsStatus = Map<int, bool>.from(
      _currentState.lessonsStatus,
    );
    updatedLessonsStatus[lessonId] = isCompleted;

    // Si se marca como completado, habilitar el siguiente video
    if (isCompleted) {
      int siguienteId = lessonId + 1;
      if (updatedLessonsStatus.containsKey(siguienteId)) {
        updatedLessonsStatus[siguienteId] = true;
      }
    }

    _currentState = _currentState.copyWith(lessonsStatus: updatedLessonsStatus);

    notifyListeners();
  }

  void updateVideoProgress(int videoId, double progress) {
    final updatedVideoProgress = Map<int, double>.from(
      _currentState.videoProgress,
    );
    updatedVideoProgress[videoId] = progress;

    _currentState = _currentState.copyWith(videoProgress: updatedVideoProgress);

    notifyListeners();
  }

  void markVideoAsWatched(int videoId) {
    final updatedLessonsStatus = Map<int, bool>.from(
      _currentState.lessonsStatus,
    );
    final updatedVideoProgress = Map<int, double>.from(
      _currentState.videoProgress,
    );

    updatedLessonsStatus[videoId] = true;
    updatedVideoProgress[videoId] = 1.0;

    // Habilitar el siguiente video
    int siguienteId = videoId + 1;
    if (updatedLessonsStatus.containsKey(siguienteId)) {
      updatedLessonsStatus[siguienteId] = true;
    }

    _currentState = _currentState.copyWith(
      lessonsStatus: updatedLessonsStatus,
      videoProgress: updatedVideoProgress,
    );

    notifyListeners();
  }

  void updateCompletedVideosList(List<int> completedVideoIds) {
    final updatedLessonsStatus = Map<int, bool>.from(
      _currentState.lessonsStatus,
    );
    final updatedVideoProgress = Map<int, double>.from(
      _currentState.videoProgress,
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

    _currentState = _currentState.copyWith(
      lessonsStatus: updatedLessonsStatus,
      videoProgress: updatedVideoProgress,
    );

    notifyListeners();
  }

  void updateLastCompletedLesson(int lessonNumber) {
    _currentState = _currentState.copyWith(lastCompletedLesson: lessonNumber);

    notifyListeners();
  }

  // Métodos de consulta
  bool isLessonCompleted(int lessonId) {
    return _currentState.isLessonCompleted(lessonId);
  }

  double getVideoProgress(int videoId) {
    return _currentState.getVideoProgress(videoId);
  }

  bool isFirstVideoEnabled() {
    return _currentState.isFirstVideoEnabled();
  }

  int getLastCompletedLessonId() {
    return _currentState.getLastCompletedLessonId();
  }

  // Método para sincronizar con BLoC
  void syncWithBloc(BuildContext context) {
    final uiBloc = context.read<UIBloc>();

    // Actualizar el estado en el BLoC
    uiBloc.add(
      UpdateCompletedVideosList(
        _currentState.lessonsStatus.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
      ),
    );
  }

  // Método para cargar estado desde BLoC
  void loadFromBloc(BuildContext context) {
    final uiBloc = context.read<UIBloc>();
    uiBloc.add(const LoadLessonProgressState());
  }
}

// Provider global para el servicio
class LessonProgressProvider extends InheritedNotifier<LessonProgressService> {
  const LessonProgressProvider({
    super.key,
    required LessonProgressService service,
    required super.child,
  }) : super(notifier: service);

  static LessonProgressService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LessonProgressProvider>()!
        .notifier!;
  }
}
