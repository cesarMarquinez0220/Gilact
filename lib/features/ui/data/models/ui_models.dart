import '../../domain/entities/ui_entities.dart';

class SplashPageModel extends SplashPage {
  const SplashPageModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.imagePath,
    super.additionalText,
    super.isLastPage = false,
    super.autoNavigateDelay = const Duration(seconds: 2),
  });

  factory SplashPageModel.fromJson(Map<String, dynamic> json) {
    return SplashPageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      additionalText: json['additionalText'],
      isLastPage: json['isLastPage'] ?? false,
      autoNavigateDelay: Duration(seconds: json['autoNavigateDelay'] ?? 2),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imagePath': imagePath,
      'additionalText': additionalText,
      'isLastPage': isLastPage,
      'autoNavigateDelay': autoNavigateDelay.inSeconds,
    };
  }

  SplashPageModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    String? imagePath,
    String? additionalText,
    bool? isLastPage,
    Duration? autoNavigateDelay,
  }) {
    return SplashPageModel(
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

class LessonProgressStateModel extends LessonProgressState {
  const LessonProgressStateModel({
    required super.lessonsStatus,
    required super.lastCompletedLesson,
    required super.videoProgress,
  });

  factory LessonProgressStateModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressStateModel(
      lessonsStatus: Map<int, bool>.from(json['lessonsStatus'] ?? {}),
      lastCompletedLesson: json['lastCompletedLesson'] ?? 0,
      videoProgress: Map<int, double>.from(json['videoProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonsStatus': lessonsStatus,
      'lastCompletedLesson': lastCompletedLesson,
      'videoProgress': videoProgress,
    };
  }

  LessonProgressStateModel copyWith({
    Map<int, bool>? lessonsStatus,
    int? lastCompletedLesson,
    Map<int, double>? videoProgress,
  }) {
    return LessonProgressStateModel(
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      lastCompletedLesson: lastCompletedLesson ?? this.lastCompletedLesson,
      videoProgress: videoProgress ?? this.videoProgress,
    );
  }

  static LessonProgressStateModel getInitialState() {
    return LessonProgressStateModel(
      lessonsStatus: {
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
      },
      lastCompletedLesson: 0,
      videoProgress: {},
    );
  }
}
