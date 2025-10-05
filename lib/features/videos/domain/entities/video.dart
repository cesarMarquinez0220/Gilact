import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String videoUrl;
  final String imageUrl;
  final String imageName;
  final int lessonId;
  final int videoId;
  final String description;
  final Duration duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final int order;

  const Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.imageUrl,
    required this.imageName,
    required this.lessonId,
    required this.videoId,
    required this.description,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    required this.order,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    videoUrl,
    imageUrl,
    imageName,
    lessonId,
    videoId,
    description,
    duration,
    createdAt,
    updatedAt,
    isCompleted,
    order,
  ];

  /// Getter para compatibilidad con código existente
  String get url => videoUrl;

  Video copyWith({
    String? id,
    String? title,
    String? videoUrl,
    String? imageUrl,
    String? imageName,
    int? lessonId,
    int? videoId,
    String? description,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    int? order,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      imageName: imageName ?? this.imageName,
      lessonId: lessonId ?? this.lessonId,
      videoId: videoId ?? this.videoId,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}
