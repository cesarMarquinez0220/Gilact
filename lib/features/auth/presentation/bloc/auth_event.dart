part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String birthDate;
  final String? phone;
  final String? location;
  final String? idNumber;
  final String? motherName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    this.phone,
    this.location,
    this.idNumber,
    this.motherName,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    name,
    birthDate,
    phone,
    location,
    idNumber,
    motherName,
  ];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class SendEmailVerificationRequested extends AuthEvent {
  const SendEmailVerificationRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? photoUrl;

  const UpdateProfileRequested({required this.name, this.photoUrl});

  @override
  List<Object?> get props => [name, photoUrl];
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class CheckOfflineSessionRequested extends AuthEvent {
  const CheckOfflineSessionRequested();
}

class SyncOfflineSessionRequested extends AuthEvent {
  const SyncOfflineSessionRequested();
}