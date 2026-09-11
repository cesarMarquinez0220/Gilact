import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entities.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String username);
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile userProfile,
  );
  Future<Either<Failure, BabyInfo?>> getBabyInfo(String username);
  Future<Either<Failure, BabyInfo>> updateBabyInfo(
    String username,
    BabyInfo babyInfo,
  );
  Future<Either<Failure, List<LessonProgress>>> getLessonProgress(
    String username,
  );
  Future<Either<Failure, LessonProgress>> updateLessonProgress(
    String username,
    String lessonId,
    double progress,
  );
  Future<Either<Failure, int>> getLastCompletedLesson(String username);
  Future<Either<Failure, Map<String, bool>>> checkUserSituation(
    String username,
  );
  Future<Either<Failure, void>> signOut();

  // Métodos legacy para compatibilidad
  Future<Either<Failure, UserProfile>> createProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? location,
    DateTime? birthDate,
    int? age,
    String? idNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  });

  Future<Either<Failure, UserProfile>> getProfile(String userId);

  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? location,
    DateTime? birthDate,
    int? age,
    String? idNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  });

  Future<Either<Failure, void>> deleteProfile(String userId);

  Future<Either<Failure, bool>> profileExists(String userId);
}
