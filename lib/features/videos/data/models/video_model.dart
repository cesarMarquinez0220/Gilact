import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    super.titleEn,
    required super.videoUrl,
    required super.imageUrl,
    required super.imageName,
    required super.lessonId,
    required super.videoId,
    required super.description,
    required super.duration,
    required super.createdAt,
    required super.updatedAt,
    required super.isCompleted,
    required super.order,
  });

  factory VideoModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleEn: data['title_en'] ?? data['titleEn'] ?? '',
      videoUrl: data['url'] ?? '',
      imageUrl: data['imgVideos'] ?? '',
      imageName: data['imgVideos'] ?? '',
      lessonId: data['numero_leccion'] ?? 0,
      videoId: data['id'] ?? 0,
      description: data['description'] ?? '',
      duration: Duration(seconds: data['duration'] ?? 0),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  factory VideoModel.fromQueryDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleEn: data['title_en'] ?? data['titleEn'] ?? '',
      videoUrl: data['url'] ?? '',
      imageUrl: data['imgVideos'] ?? '',
      imageName: data['imgVideos'] ?? '',
      lessonId: data['numero_leccion'] ?? 0,
      videoId: data['id'] ?? 0,
      description: data['description'] ?? '',
      duration: Duration(seconds: data['duration'] ?? 0),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'url': videoUrl,
      'imgVideos': imageUrl,
      'numero_leccion': lessonId,
      'id': videoId,
      'description': description,
      'duration': duration.inSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  @override
  VideoModel copyWith({
    String? id,
    String? title,
    String? titleEn,
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
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
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
