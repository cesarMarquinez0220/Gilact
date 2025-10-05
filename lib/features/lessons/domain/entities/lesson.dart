import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final double progress;
  final List<String> videoIds;
  final Map<String, dynamic>? metadata;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    required this.progress,
    required this.videoIds,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        imageUrl,
        order,
        createdAt,
        updatedAt,
        isCompleted,
        progress,
        videoIds,
        metadata,
      ];

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    double? progress,
    List<String>? videoIds,
    Map<String, dynamic>? metadata,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      videoIds: videoIds ?? this.videoIds,
      metadata: metadata ?? this.metadata,
    );
  }
}
