import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isEmailVerified,
    super.additionalData,
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
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['usuario'] ?? data['name'] ?? '', // Usar 'usuario' como nombre principal
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      additionalData: {
        'cedula': data['cedula'],
        'edad': data['edad'],
        'fechaNacimiento': data['fechaNacimiento'],
        'nombre madre': data['nombre madre'],
        'telefono': data['telefono'],
        'ubicacion': data['ubicacion'],
        'usuario': data['usuario'],
        'uid': data['uid'],
        ...?data['additionalData'],
      },
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      'name': name,
      'usuario': name, // También guardar como 'usuario'
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'additionalData': additionalData,
      // Incluir campos adicionales si existen
      if (additionalData != null) ...additionalData!,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? additionalData,
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
    );
  }
}
