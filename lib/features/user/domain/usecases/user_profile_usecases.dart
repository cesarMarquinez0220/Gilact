import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile_entities.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, String> {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(String username) async {
    return await repository.getUserProfile(username);
  }
}

class UpdateUserProfileUseCase implements UseCase<UserProfile, UserProfile> {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UserProfile userProfile) async {
    return await repository.updateUserProfile(userProfile);
  }
}

class GetBabyInfoUseCase implements UseCase<BabyInfo?, String> {
  final UserProfileRepository repository;

  GetBabyInfoUseCase(this.repository);

  @override
  Future<Either<Failure, BabyInfo?>> call(String username) async {
    return await repository.getBabyInfo(username);
  }
}

class UpdateBabyInfoUseCase implements UseCase<BabyInfo, Map<String, dynamic>> {
  final UserProfileRepository repository;

  UpdateBabyInfoUseCase(this.repository);

  @override
  Future<Either<Failure, BabyInfo>> call(Map<String, dynamic> params) async {
    final username = params['username'] as String;
    final babyInfo = params['babyInfo'] as BabyInfo;
    return await repository.updateBabyInfo(username, babyInfo);
  }
}

class GetLessonProgressUseCase
    implements UseCase<List<LessonProgress>, String> {
  final UserProfileRepository repository;

  GetLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, List<LessonProgress>>> call(String username) async {
    return await repository.getLessonProgress(username);
  }
}

class UpdateLessonProgressUseCase
    implements UseCase<LessonProgress, Map<String, dynamic>> {
  final UserProfileRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgress>> call(
    Map<String, dynamic> params,
  ) async {
    final username = params['username'] as String;
    final lessonId = params['lessonId'] as String;
    final progress = params['progress'] as double;
    return await repository.updateLessonProgress(username, lessonId, progress);
  }
}

class GetLastCompletedLessonUseCase implements UseCase<int, String> {
  final UserProfileRepository repository;

  GetLastCompletedLessonUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(String username) async {
    return await repository.getLastCompletedLesson(username);
  }
}

class CheckUserSituationUseCase implements UseCase<Map<String, bool>, String> {
  final UserProfileRepository repository;

  CheckUserSituationUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, bool>>> call(String username) async {
    return await repository.checkUserSituation(username);
  }
}

class SignOutUseCase implements UseCase<void, NoParams> {
  final UserProfileRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
