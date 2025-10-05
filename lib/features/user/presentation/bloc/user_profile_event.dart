part of 'user_profile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class CreateUserProfileRequested extends UserProfileEvent {
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

  const CreateUserProfileRequested({
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
  });

  @override
  List<Object?> get props => [
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
  ];
}

class GetUserProfileRequested extends UserProfileEvent {
  final String userId;

  const GetUserProfileRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateUserProfileRequested extends UserProfileEvent {
  final String userId;
  final String? name;
  final String? phone;
  final String? location;
  final DateTime? birthDate;
  final int? age;
  final String? idNumber;
  final String? photoUrl;
  final Map<String, dynamic>? additionalData;

  const UpdateUserProfileRequested({
    required this.userId,
    this.name,
    this.phone,
    this.location,
    this.birthDate,
    this.age,
    this.idNumber,
    this.photoUrl,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    phone,
    location,
    birthDate,
    age,
    idNumber,
    photoUrl,
    additionalData,
  ];
}

class DeleteUserProfileRequested extends UserProfileEvent {
  final String userId;

  const DeleteUserProfileRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class SignOutRequested extends UserProfileEvent {
  const SignOutRequested();

  @override
  List<Object> get props => [];
}
