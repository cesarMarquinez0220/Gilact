import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/educational_content.dart';

class EducationalContentModel extends EducationalContent {
  const EducationalContentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.imageUrl,
    required super.category,
    required super.order,
    required super.createdAt,
    required super.updatedAt,
    required super.isCompleted,
    super.metadata,
  });

  factory EducationalContentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EducationalContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      metadata: data['metadata'],
    );
  }

  factory EducationalContentModel.fromQueryDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EducationalContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }

  EducationalContentModel copyWith({
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
    return EducationalContentModel(
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
