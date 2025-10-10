import 'package:equatable/equatable.dart';

class PrepartumInfo extends Equatable {
  final String userId;
  final DateTime expectedBirthDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  const PrepartumInfo({
    required this.userId,
    required this.expectedBirthDate,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    userId,
    expectedBirthDate,
    createdAt,
    updatedAt,
    additionalData,
  ];

  PrepartumInfo copyWith({
    String? userId,
    DateTime? expectedBirthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return PrepartumInfo(
      userId: userId ?? this.userId,
      expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
