import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.location,
    super.birthDate,
    super.age,
    super.idNumber,
    super.photoUrl,
    super.additionalData,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfileModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      location: data['location'],
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      age: data['age'],
      idNumber: data['idNumber'],
      photoUrl: data['photoUrl'],
      additionalData: data['additionalData'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'age': age,
      'idNumber': idNumber,
      'photoUrl': photoUrl,
      'additionalData': additionalData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  UserProfileModel copyWith({
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
    return UserProfileModel(
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
