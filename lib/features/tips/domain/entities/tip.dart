import 'package:equatable/equatable.dart';

class Tip extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final Map<String, dynamic>? metadata;

  const Tip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        category,
        order,
        createdAt,
        updatedAt,
        isFavorite,
        metadata,
      ];

  Tip copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  }) {
    return Tip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      metadata: metadata ?? this.metadata,
    );
  }
}
