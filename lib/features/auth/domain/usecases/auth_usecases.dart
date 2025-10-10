import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

@injectable
class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      birthDate: params.birthDate,
      phone: params.phone,
      location: params.location,
      idNumber: params.idNumber,
      motherName: params.motherName,
    );
  }
}

@injectable
class SignOutUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}

@injectable
class GetCurrentUserUseCase implements UseCaseNoParams<User?> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}

@injectable
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(email: params.email);
  }
}

@injectable
class SendEmailVerificationUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}

@injectable
class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      photoUrl: params.photoUrl,
    );
  }
}

@injectable
class DeleteAccountUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.deleteAccount();
  }
}

// Parámetros para los casos de uso
class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final String birthDate;
  final String? phone;
  final String? location;
  final String? idNumber;
  final String? motherName;

  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    this.phone,
    this.location,
    this.idNumber,
    this.motherName,
  });
}

class ResetPasswordParams {
  final String email;

  ResetPasswordParams({required this.email});
}

class UpdateProfileParams {
  final String name;
  final String? photoUrl;

  UpdateProfileParams({required this.name, this.photoUrl});
}
