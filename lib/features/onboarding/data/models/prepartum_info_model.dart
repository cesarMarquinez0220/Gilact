import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prepartum_info.dart';

class PrepartumInfoModel extends PrepartumInfo {
  const PrepartumInfoModel({
    required super.userId,
    required super.expectedBirthDate,
    required super.createdAt,
    required super.updatedAt,
    super.additionalData,
  });

  factory PrepartumInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PrepartumInfoModel(
      userId: doc.id,
      expectedBirthDate: (data['expectedBirthDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'expectedBirthDate': Timestamp.fromDate(expectedBirthDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  factory PrepartumInfoModel.fromEntity(PrepartumInfo entity) {
    return PrepartumInfoModel(
      userId: entity.userId,
      expectedBirthDate: entity.expectedBirthDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      additionalData: entity.additionalData,
    );
  }
}
