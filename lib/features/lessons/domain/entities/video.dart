import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final int videoId;
  final int leccionId;
  final String videoURL;
  final String imageName; // Para miniaturas de video (imgVideos)
  final String pathImageName; // Para imágenes del camino de lecciones (imagen)
  final String title;
  final String description;
  final Duration duration;
  final bool isCompleted;
  final double progress;

  const Video({
    required this.videoId,
    required this.leccionId,
    required this.videoURL,
    required this.imageName,
    required this.pathImageName,
    required this.title,
    required this.description,
    required this.duration,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [
    videoId,
    leccionId,
    videoURL,
    imageName,
    pathImageName,
    title,
    description,
    duration,
    isCompleted,
    progress,
  ];

  Video copyWith({
    int? videoId,
    int? leccionId,
    String? videoURL,
    String? imageName,
    String? pathImageName,
    String? title,
    String? description,
    Duration? duration,
    bool? isCompleted,
    double? progress,
  }) {
    return Video(
      videoId: videoId ?? this.videoId,
      leccionId: leccionId ?? this.leccionId,
      videoURL: videoURL ?? this.videoURL,
      imageName: imageName ?? this.imageName,
      pathImageName: pathImageName ?? this.pathImageName,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}
