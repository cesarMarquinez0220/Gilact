import 'package:equatable/equatable.dart';

class EducationalContent extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String category;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final Map<String, dynamic>? metadata;

  const EducationalContent({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        imageUrl,
        category,
        order,
        createdAt,
        updatedAt,
        isCompleted,
        metadata,
      ];

  EducationalContent copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? category,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return EducationalContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }
}
