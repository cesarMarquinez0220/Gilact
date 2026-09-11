import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? birthDate;
  final String? phone;
  final String? location;
  final int? age;
  final String? idNumber;
  final String? motherName;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isEmailVerified,
    super.additionalData,
    this.birthDate,
    this.phone,
    this.location,
    this.age,
    this.idNumber,
    this.motherName,
  });

  factory UserModel.fromFirebaseUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isEmailVerified,
    Map<String, dynamic>? additionalData,
    String? birthDate,
    String? phone,
    String? location,
    int? age,
    String? idNumber,
    String? motherName,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: isEmailVerified,
      additionalData: additionalData,
      birthDate: birthDate,
      phone: phone,
      location: location,
      age: age,
      idNumber: idNumber,
      motherName: motherName,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name:
          data['usuario'] ??
          data['name'] ??
          '', // Usar 'usuario' como nombre principal
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      additionalData: data['additionalData'],
      birthDate: data['fechaNacimiento'],
      phone: data['telefono'],
      location: data['ubicacion'],
      age: data['edad'],
      idNumber: data['cedula'],
      motherName: data['nombre madre'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      // Campos obligatorios
      'usuario': name,
      'email': email,
      'fechaNacimiento': birthDate ?? '',

      // Campos opcionales (siempre presentes)
      'telefono': phone ?? '',
      'ubicacion': location ?? '',
      'edad': age,
      'cedula': idNumber ?? '',
      'nombre madre': motherName ?? '',

      // Campos del sistema
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,

      // Campo adicional para compatibilidad
      'name': name,
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? additionalData,
    String? birthDate,
    String? phone,
    String? location,
    int? age,
    String? idNumber,
    String? motherName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      additionalData: additionalData ?? this.additionalData,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      age: age ?? this.age,
      idNumber: idNumber ?? this.idNumber,
      motherName: motherName ?? this.motherName,
    );
  }
}
