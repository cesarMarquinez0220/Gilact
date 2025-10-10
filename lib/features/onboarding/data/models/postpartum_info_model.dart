import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/postpartum_info.dart';

class PostpartumInfoModel extends PostpartumInfo {
  const PostpartumInfoModel({
    required super.userId,
    required super.babyName,
    required super.birthDate,
    required super.birthPlace,
    required super.birthWeight,
    required super.gestationalAge,
    required super.lastMenstruation,
    required super.createdAt,
    required super.updatedAt,
    super.additionalData,
  });

  factory PostpartumInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostpartumInfoModel(
      userId: doc.id,
      babyName: data['babyName'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      birthPlace: data['birthPlace'] ?? '',
      birthWeight: (data['birthWeight'] as num).toDouble(),
      gestationalAge: data['gestationalAge'] ?? 0,
      lastMenstruation: (data['lastMenstruation'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'babyName': babyName,
      'birthDate': Timestamp.fromDate(birthDate),
      'birthPlace': birthPlace,
      'birthWeight': birthWeight,
      'gestationalAge': gestationalAge,
      'lastMenstruation': Timestamp.fromDate(lastMenstruation),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  factory PostpartumInfoModel.fromEntity(PostpartumInfo entity) {
    return PostpartumInfoModel(
      userId: entity.userId,
      babyName: entity.babyName,
      birthDate: entity.birthDate,
      birthPlace: entity.birthPlace,
      birthWeight: entity.birthWeight,
      gestationalAge: entity.gestationalAge,
      lastMenstruation: entity.lastMenstruation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      additionalData: entity.additionalData,
    );
  }
}
