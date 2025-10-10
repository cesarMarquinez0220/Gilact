import 'package:equatable/equatable.dart';

class PostpartumInfo extends Equatable {
  final String userId;
  final String babyName;
  final DateTime birthDate;
  final String birthPlace;
  final double birthWeight;
  final int gestationalAge;
  final DateTime lastMenstruation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  const PostpartumInfo({
    required this.userId,
    required this.babyName,
    required this.birthDate,
    required this.birthPlace,
    required this.birthWeight,
    required this.gestationalAge,
    required this.lastMenstruation,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    userId,
    babyName,
    birthDate,
    birthPlace,
    birthWeight,
    gestationalAge,
    lastMenstruation,
    createdAt,
    updatedAt,
    additionalData,
  ];

  PostpartumInfo copyWith({
    String? userId,
    String? babyName,
    DateTime? birthDate,
    String? birthPlace,
    double? birthWeight,
    int? gestationalAge,
    DateTime? lastMenstruation,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return PostpartumInfo(
      userId: userId ?? this.userId,
      babyName: babyName ?? this.babyName,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      birthWeight: birthWeight ?? this.birthWeight,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      lastMenstruation: lastMenstruation ?? this.lastMenstruation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
