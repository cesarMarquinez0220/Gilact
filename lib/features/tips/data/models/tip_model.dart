import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tip.dart';

class TipModel extends Tip {
  const TipModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.order,
    required super.createdAt,
    required super.updatedAt,
    required super.isFavorite,
    super.metadata,
  });

  factory TipModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TipModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
      metadata: data['metadata'],
    );
  }

  factory TipModel.fromQueryDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TipModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFavorite': isFavorite,
      'metadata': metadata,
    };
  }

  @override
  TipModel copyWith({
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
    return TipModel(
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
