import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entities.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.email,
    required super.motherName,
    required super.birthDate,
    required super.age,
    required super.cedula,
    required super.location,
    required super.phone,
    required super.registrationDate,
    super.isPrePartum = false,
    super.isPostPartum = false,
    super.babyInfo,
    super.situationData,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return UserProfileModel(
      id: id,
      username: json['usuario'] ?? '',
      email: json['email'] ?? '',
      motherName: json['nombre madre'] ?? '',
      birthDate: json['fechaNacimiento'] ?? '',
      age: json['edad'] ?? 0,
      cedula: json['cedula'] ?? '',
      location: json['ubicacion'] ?? '',
      phone: json['telefono'] ?? '',
      registrationDate:
          DateTime.tryParse(json['fechaRegistro'] ?? '') ?? DateTime.now(),
      isPrePartum: json['isPrePartum'] ?? false,
      isPostPartum: json['isPostPartum'] ?? false,
    );
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': username,
      'email': email,
      'nombre madre': motherName,
      'fechaNacimiento': birthDate,
      'edad': age,
      'cedula': cedula,
      'ubicacion': location,
      'telefono': phone,
      'fechaRegistro': registrationDate.toIso8601String(),
      'isPrePartum': isPrePartum,
      'isPostPartum': isPostPartum,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  @override
  UserProfileModel copyWith({
    String? id,
    String? username,
    String? email,
    String? motherName,
    String? birthDate,
    int? age,
    String? cedula,
    String? location,
    String? phone,
    DateTime? registrationDate,
    bool? isPrePartum,
    bool? isPostPartum,
    BabyInfo? babyInfo,
    Map<String, dynamic>? situationData,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      motherName: motherName ?? this.motherName,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      cedula: cedula ?? this.cedula,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      registrationDate: registrationDate ?? this.registrationDate,
      isPrePartum: isPrePartum ?? this.isPrePartum,
      isPostPartum: isPostPartum ?? this.isPostPartum,
      babyInfo: babyInfo ?? this.babyInfo,
      situationData: situationData ?? this.situationData,
    );
  }
}

class BabyInfoModel extends BabyInfo {
  const BabyInfoModel({
    required super.name,
    required super.gestationalAge,
    required super.birthDate,
    required super.lactationStartDate,
    required super.lactationTime,
    required super.birthTime,
    required super.birthPlace,
    required super.weight,
  });

  factory BabyInfoModel.fromJson(Map<String, dynamic> json) {
    return BabyInfoModel(
      name: json['nombre bebe'] ?? '',
      gestationalAge: json['edad gestacional'] ?? 0,
      birthDate: json['fecha nacimiento bebe'] ?? '',
      lactationStartDate: json['fecha lactancia'] ?? '',
      lactationTime: json['hora lactancia'] ?? '',
      birthTime: json['hora nacimiento'] ?? '',
      birthPlace: json['lugar nacimiento'] ?? '',
      weight: json['peso'] ?? '',
    );
  }

  factory BabyInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BabyInfoModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre bebe': name,
      'edad gestacional': gestationalAge,
      'fecha nacimiento bebe': birthDate,
      'fecha lactancia': lactationStartDate,
      'hora lactancia': lactationTime,
      'hora nacimiento': birthTime,
      'lugar nacimiento': birthPlace,
      'peso': weight,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  @override
  BabyInfoModel copyWith({
    String? name,
    int? gestationalAge,
    String? birthDate,
    String? lactationStartDate,
    String? lactationTime,
    String? birthTime,
    String? birthPlace,
    String? weight,
  }) {
    return BabyInfoModel(
      name: name ?? this.name,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      birthDate: birthDate ?? this.birthDate,
      lactationStartDate: lactationStartDate ?? this.lactationStartDate,
      lactationTime: lactationTime ?? this.lactationTime,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      weight: weight ?? this.weight,
    );
  }
}

class LessonProgressModel extends LessonProgress {
  const LessonProgressModel({
    required super.lessonId,
    required super.title,
    required super.subtitle,
    required super.imageName,
    required super.videoId,
    required super.durationId,
    super.isEnabled = false,
    super.isCompleted = false,
    super.progressPercentage = 0.0,
    super.progressColor = Colors.blue,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageName: json['imageName'] ?? '',
      videoId: json['videoId'] ?? 0,
      durationId: json['durationId'] ?? 0,
      isEnabled: json['isEnabled'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      progressColor: Color(json['progressColor'] ?? Colors.blue.toARGB32()),
    );
  }

  factory LessonProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonProgressModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'subtitle': subtitle,
      'imageName': imageName,
      'videoId': videoId,
      'durationId': durationId,
      'isEnabled': isEnabled,
      'isCompleted': isCompleted,
      'progressPercentage': progressPercentage,
      'progressColor': progressColor.toARGB32(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  @override
  LessonProgressModel copyWith({
    String? lessonId,
    String? title,
    String? subtitle,
    String? imageName,
    int? videoId,
    int? durationId,
    bool? isEnabled,
    bool? isCompleted,
    double? progressPercentage,
    Color? progressColor,
  }) {
    return LessonProgressModel(
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageName: imageName ?? this.imageName,
      videoId: videoId ?? this.videoId,
      durationId: durationId ?? this.durationId,
      isEnabled: isEnabled ?? this.isEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      progressColor: progressColor ?? this.progressColor,
    );
  }
}
