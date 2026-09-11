import 'package:equatable/equatable.dart';

class SplashPage extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final String? additionalText;
  final bool isLastPage;
  final Duration autoNavigateDelay;

  const SplashPage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    this.additionalText,
    this.isLastPage = false,
    this.autoNavigateDelay = const Duration(seconds: 2),
  });

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    description,
    imagePath,
    additionalText,
    isLastPage,
    autoNavigateDelay,
  ];

  SplashPage copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    String? imagePath,
    String? additionalText,
    bool? isLastPage,
    Duration? autoNavigateDelay,
  }) {
    return SplashPage(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      additionalText: additionalText ?? this.additionalText,
      isLastPage: isLastPage ?? this.isLastPage,
      autoNavigateDelay: autoNavigateDelay ?? this.autoNavigateDelay,
    );
  }
}

class LessonProgressState extends Equatable {
  final Map<int, bool> lessonsStatus;
  final int lastCompletedLesson;
  final Map<int, double> videoProgress;

  const LessonProgressState({
    required this.lessonsStatus,
    required this.lastCompletedLesson,
    required this.videoProgress,
  });

  @override
  List<Object?> get props => [
    lessonsStatus,
    lastCompletedLesson,
    videoProgress,
  ];

  LessonProgressState copyWith({
    Map<int, bool>? lessonsStatus,
    int? lastCompletedLesson,
    Map<int, double>? videoProgress,
  }) {
    return LessonProgressState(
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lastCompletedLesson: lastCompletedLesson ?? this.lastCompletedLesson,
      videoProgress: videoProgress ?? this.videoProgress,
    );
  }

  bool isLessonCompleted(int lessonId) {
    return lessonsStatus[lessonId] ?? false;
  }

  double getVideoProgress(int videoId) {
    return videoProgress[videoId] ?? 0.0;
  }

  bool isFirstVideoEnabled() {
    return lessonsStatus[1] ?? false;
  }

  int getLastCompletedLessonId() {
    int? lastId;
    lessonsStatus.forEach((id, status) {
      if (status) {
        lastId = id;
      }
    });
    return lastId ?? -1;
  }
}
