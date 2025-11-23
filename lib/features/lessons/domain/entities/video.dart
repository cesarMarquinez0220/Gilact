import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final int videoId;
  final int leccionId;
  final String videoURL;
  final String imageName; // Para miniaturas de video (imgVideos)
  final String pathImageName; // Para imágenes del camino de lecciones (imagen)
  final String title; // Título por defecto (español o fallback)
  final String? titleEn; // Título en inglés (opcional)
  final String description;
  final Duration duration;
  final bool isCompleted;
  final double progress;
  
  /// Obtiene el título localizado según el idioma proporcionado
  /// Si no se proporciona locale, devuelve el título por defecto
  String getLocalizedTitle([String? languageCode]) {
    if (languageCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    return title;
  }

  const Video({
    required this.videoId,
    required this.leccionId,
    required this.videoURL,
    required this.imageName,
    required this.pathImageName,
    required this.title,
    this.titleEn,
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
    titleEn,
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
    String? titleEn,
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
      titleEn: titleEn ?? this.titleEn,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}
