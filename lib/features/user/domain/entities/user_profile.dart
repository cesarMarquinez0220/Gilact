import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final DateTime? birthDate;
  final int? age;
  final String? idNumber;
  final String? photoUrl;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.birthDate,
    this.age,
    this.idNumber,
    this.photoUrl,
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    phone,
    location,
    birthDate,
    age,
    idNumber,
    photoUrl,
    additionalData,
    createdAt,
    updatedAt,
  ];

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? location,
    DateTime? birthDate,
    int? age,
    String? idNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      idNumber: idNumber ?? this.idNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
