import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String email;
  final String motherName;
  final String birthDate;
  final int age;
  final String cedula;
  final String location;
  final String phone;
  final DateTime registrationDate;
  final bool isPrePartum;
  final bool isPostPartum;
  final BabyInfo? babyInfo;
  final Map<String, dynamic>? situationData;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.motherName,
    required this.birthDate,
    required this.age,
    required this.cedula,
    required this.location,
    required this.phone,
    required this.registrationDate,
    this.isPrePartum = false,
    this.isPostPartum = false,
    this.babyInfo,
    this.situationData,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    motherName,
    birthDate,
    age,
    cedula,
    location,
    phone,
    registrationDate,
    isPrePartum,
    isPostPartum,
    babyInfo,
    situationData,
  ];

  UserProfile copyWith({
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
    return UserProfile(
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

class BabyInfo extends Equatable {
  final String name;
  final int gestationalAge;
  final String birthDate;
  final String lactationStartDate;
  final String lactationTime;
  final String birthTime;
  final String birthPlace;
  final String weight;

  const BabyInfo({
    required this.name,
    required this.gestationalAge,
    required this.birthDate,
    required this.lactationStartDate,
    required this.lactationTime,
    required this.birthTime,
    required this.birthPlace,
    required this.weight,
  });

  @override
  List<Object?> get props => [
    name,
    gestationalAge,
    birthDate,
    lactationStartDate,
    lactationTime,
    birthTime,
    birthPlace,
    weight,
  ];

  BabyInfo copyWith({
    String? name,
    int? gestationalAge,
    String? birthDate,
    String? lactationStartDate,
    String? lactationTime,
    String? birthTime,
    String? birthPlace,
    String? weight,
  }) {
    return BabyInfo(
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

class LessonProgress extends Equatable {
  final String lessonId;
  final String title;
  final String subtitle;
  final String imageName;
  final int videoId;
  final int durationId;
  final bool isEnabled;
  final bool isCompleted;
  final double progressPercentage;
  final Color progressColor;

  const LessonProgress({
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.imageName,
    required this.videoId,
    required this.durationId,
    this.isEnabled = false,
    this.isCompleted = false,
    this.progressPercentage = 0.0,
    this.progressColor = Colors.blue,
  });

  @override
  List<Object?> get props => [
    lessonId,
    title,
    subtitle,
    imageName,
    videoId,
    durationId,
    isEnabled,
    isCompleted,
    progressPercentage,
    progressColor,
  ];

  LessonProgress copyWith({
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
    return LessonProgress(
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
