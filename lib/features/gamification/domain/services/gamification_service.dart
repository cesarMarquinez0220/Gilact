import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../repositories/gamification_repository.dart';
import '../entities/user_gamification_profile.dart';
import '../entities/xp_transaction.dart';
import '../entities/xp_transaction.dart' show XPSource;
import '../entities/daily_streak.dart';
import '../entities/achievement.dart';
import 'xp_calculation_service.dart';
import 'level_service.dart';
import 'streak_service.dart';
import 'achievement_service.dart';
import '../../../lessons/domain/repositories/lesson_repository.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../../core/di/injection.dart';

/// Servicio principal de gamificación
/// Facilita la integración con otras funcionalidades de la app
class GamificationService {
  final GamificationRepository _repository;
  final XPCalculationService _xpService = XPCalculationService();
  final LevelService _levelService = LevelService();
  final StreakService _streakService = StreakService();
  final AchievementService _achievementService = AchievementService();

  GamificationService({required GamificationRepository repository})
    : _repository = repository;

  /// Agrega XP por registro rápido de lactancia
  Future<Either<String, UserGamificationProfile>> addXPForQuickLactation({
    required String userId,
    required String recordId,
    required DateTime timestamp,
    bool isFirstOfDay = false,
  }) async {
    final transaction = _xpService.calculateXPForQuickLactation(
      userId: userId,
      recordId: recordId,
      timestamp: timestamp,
      isFirstOfDay: isFirstOfDay,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Agrega XP por registro completo de lactancia
  Future<Either<String, UserGamificationProfile>> addXPForCompleteLactation({
    required String userId,
    required String recordId,
    required DateTime timestamp,
    bool includesSleep = false,
    bool isFirstOfDay = false,
  }) async {
    final transaction = _xpService.calculateXPForCompleteLactation(
      userId: userId,
      recordId: recordId,
      timestamp: timestamp,
      includesSleep: includesSleep,
      isFirstOfDay: isFirstOfDay,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Agrega XP por lección completada
  Future<Either<String, UserGamificationProfile>> addXPForLessonCompleted({
    required String userId,
    required String lessonId,
    required DateTime timestamp,
    bool isFirstOfDay = false,
  }) async {
    final transaction = _xpService.calculateXPForLessonCompleted(
      userId: userId,
      lessonId: lessonId,
      timestamp: timestamp,
      isFirstOfDay: isFirstOfDay,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Agrega XP por registro de peso del bebé
  Future<Either<String, UserGamificationProfile>> addXPForBabyWeight({
    required String userId,
    required String recordId,
    required DateTime timestamp,
  }) async {
    final transaction = _xpService.calculateXPForBabyWeight(
      userId: userId,
      recordId: recordId,
      timestamp: timestamp,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Agrega XP por registro de sueño del bebé
  Future<Either<String, UserGamificationProfile>> addXPForBabySleep({
    required String userId,
    required String recordId,
    required DateTime timestamp,
  }) async {
    final transaction = _xpService.calculateXPForBabySleep(
      userId: userId,
      recordId: recordId,
      timestamp: timestamp,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Agrega XP por completar un desafío diario
  /// Verifica si ya se completó hoy para evitar recompensas duplicadas
  Future<Either<String, UserGamificationProfile>> addXPForDailyChallenge({
    required String userId,
    required String challengeId,
    required int xpReward,
    required DateTime timestamp,
  }) async {
    try {
      // Verificar si ya se completó este desafío hoy
      final profileResult = await _repository.getProfile(userId);
      return await profileResult.fold((error) => Left(error), (profile) async {
        if (profile == null) {
          return Left('Perfil no encontrado');
        }

        // Verificar si ya se completó hoy
        final today = DateTime(timestamp.year, timestamp.month, timestamp.day);
        final completedDate = profile.completedDailyChallenges[challengeId];

        if (completedDate != null) {
          final completedDay = DateTime(
            completedDate.year,
            completedDate.month,
            completedDate.day,
          );

          // Si ya se completó hoy, no otorgar XP de nuevo
          if (completedDay.year == today.year &&
              completedDay.month == today.month &&
              completedDay.day == today.day) {
            return Right(
              profile,
            ); // Ya completado hoy, retornar perfil sin cambios
          }
        }

        // Otorgar XP
        final transaction = _xpService.calculateXPForDailyChallenge(
          userId: userId,
          challengeId: challengeId,
          xpReward: xpReward,
          timestamp: timestamp,
        );

        // Actualizar perfil con el desafío completado
        final updatedCompletedChallenges = Map<String, DateTime>.from(
          profile.completedDailyChallenges,
        );
        updatedCompletedChallenges[challengeId] = timestamp;

        // Agregar XP y actualizar perfil
        final result = await _addXPAndUpdateProfile(userId, transaction);

        // Asegurar que el desafío completado se guarde
        return result.fold((error) => Left(error), (updatedProfile) async {
          final finalProfile = updatedProfile.copyWith(
            completedDailyChallenges: updatedCompletedChallenges,
          );
          await _repository.saveProfile(finalProfile);
          return Right(finalProfile);
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error agregando XP por desafío diario: $e');
      }
      return Left('Error agregando XP por desafío diario: $e');
    }
  }

  /// Agrega XP por completar trivia después de una lección
  Future<Either<String, UserGamificationProfile>> addXPForTriviaCompleted({
    required String userId,
    required String lessonId,
    required int correctAnswers,
    required int totalQuestions,
    required DateTime timestamp,
  }) async {
    final transaction = _xpService.calculateXPForTrivia(
      userId: userId,
      lessonId: lessonId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      timestamp: timestamp,
    );

    return await _addXPAndUpdateProfile(userId, transaction);
  }

  /// Verifica y otorga bonus por milestone de registros
  Future<Either<String, UserGamificationProfile?>>
  checkAndAwardRecordMilestone({
    required String userId,
    required int totalRecords,
    required DateTime timestamp,
  }) async {
    final milestoneBonus = _xpService.calculateRecordMilestoneBonus(
      userId: userId,
      totalRecords: totalRecords,
      timestamp: timestamp,
    );

    if (milestoneBonus == null) {
      return Right(null); // No hay milestone alcanzado
    }

    return await _addXPAndUpdateProfile(userId, milestoneBonus);
  }

  /// Verifica si la trivia de una lección está completada
  Future<bool> isTriviaCompleted(String userId, String lessonId) async {
    try {
      final transactionsResult = await _repository.getXPTransactions(userId);
      return transactionsResult.fold((error) => false, (transactions) {
        // Buscar si hay alguna transacción de trivia completada para esta lección
        return transactions.any(
          (transaction) =>
              transaction.source == XPSource.triviaCompleted &&
              transaction.sourceId == lessonId,
        );
      });
    } catch (e) {
      return false;
    }
  }

  /// Agrega XP y actualiza el perfil
  Future<Either<String, UserGamificationProfile>> _addXPAndUpdateProfile(
    String userId,
    XPTransaction transaction,
  ) async {
    try {
      // 1. Guardar transacción (offline-first)
      final saveResult = await _repository.saveXPTransaction(transaction);
      if (saveResult.isLeft()) {
        return Left(saveResult.fold((l) => l, (_) => ''));
      }

      // 2. Obtener perfil actual
      final profileResult = await _repository.getProfile(userId);
      return await profileResult.fold((error) => Left(error), (profile) async {
        if (profile == null) {
          // Crear perfil inicial
          final newProfile = UserGamificationProfile(
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _repository.saveProfile(newProfile);
          return Right(newProfile);
        }

        // 3. Actualizar perfil con nuevo XP
        final updatedProfile = _levelService.updateLevelAfterXP(
          profile,
          transaction.amount,
        );

        // 4. Actualizar racha
        final streakResult = await _repository.getStreak(userId);
        DailyStreak? updatedStreak;
        streakResult.fold((_) {}, (streak) {
          final currentStreak = streak ?? DailyStreak(userId: userId);
          updatedStreak = _streakService.updateStreakOnActivity(
            currentStreak,
            transaction.timestamp,
          );
        });

        if (updatedStreak != null) {
          final nonNullStreak = updatedStreak!;
          await _repository.saveStreak(nonNullStreak);

          // Actualizar perfil con racha
          final profileWithStreak = updatedProfile.copyWith(
            currentStreak: nonNullStreak.currentStreak,
            lastActivityDate: nonNullStreak.lastActivityDate,
            streakStartDate: nonNullStreak.streakStartDate,
            updatedAt: DateTime.now(),
          );

          // 5. Verificar bonus de racha
          final streakBonus = _xpService.calculateStreakBonus(
            userId: userId,
            streakDays: nonNullStreak.currentStreak,
            timestamp: DateTime.now(),
          );

          if (streakBonus != null) {
            await _repository.saveXPTransaction(streakBonus);
            final profileWithBonus = _levelService.updateLevelAfterXP(
              profileWithStreak,
              streakBonus.amount,
            );
            await _repository.saveProfile(profileWithBonus);
            return Right(profileWithBonus);
          }

          // 6. Determinar estado de mascota
          final mascotState = _determineMascotState(
            profileWithStreak,
            nonNullStreak,
          );
          final finalProfile = profileWithStreak.copyWith(
            mascotState: mascotState,
          );

          await _repository.saveProfile(finalProfile);
          return Right(finalProfile);
        }

        await _repository.saveProfile(updatedProfile);
        return Right(updatedProfile);
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error agregando XP: $e');
      }
      return Left('Error agregando XP: $e');
    }
  }

  /// Detecta y desbloquea logros nuevos (versión mejorada con estadísticas reales)
  Future<Either<String, List<Achievement>>> detectAndUnlockAchievements({
    required String userId,
    required int totalLactationRecords,
    required int completeLactationRecords,
    required int totalLessonsCompleted,
    required int babyWeightRecords,
    required bool hasNocturnalRecord,
    required int dailyRecordsToday,
    int babySleepRecords = 0,
    int perfectTrivias = 0,
    int nocturnalRecordsCount = 0,
    int daysUsingApp = 0,
  }) async {
    try {
      final profileResult = await _repository.getProfile(userId);
      return await profileResult.fold((error) => Left(error), (profile) async {
        if (profile == null) return Right([]);

        final newAchievements = _achievementService.detectNewAchievements(
          profile: profile,
          totalLactationRecords: totalLactationRecords,
          completeLactationRecords: completeLactationRecords,
          totalLessonsCompleted: totalLessonsCompleted,
          babyWeightRecords: babyWeightRecords,
          hasNocturnalRecord: hasNocturnalRecord,
          dailyRecordsToday: dailyRecordsToday,
          babySleepRecords: babySleepRecords,
          perfectTrivias: perfectTrivias,
          nocturnalRecordsCount: nocturnalRecordsCount,
          daysUsingApp: daysUsingApp,
        );

        if (newAchievements.isNotEmpty) {
          // Agregar XP por logros
          for (final achievement in newAchievements) {
            final xpTransaction = _xpService.calculateXPForAchievement(
              userId: userId,
              achievementId: achievement.id,
              xpReward: achievement.xpReward,
              timestamp: DateTime.now(),
            );
            await _repository.saveXPTransaction(xpTransaction);
          }

          // Actualizar perfil con logros desbloqueados
          final updatedAchievementIds = [
            ...profile.unlockedAchievements,
            ...newAchievements.map((a) => a.id),
          ];

          // Agregar logros nuevos a la lista de no vistos (para notificación roja)
          final newAchievementIds = newAchievements.map((a) => a.id).toList();
          final updatedNewAchievements = [
            ...profile.newAchievements,
            ...newAchievementIds,
          ];

          final updatedProfile = profile.copyWith(
            unlockedAchievements: updatedAchievementIds,
            newAchievements: updatedNewAchievements,
            mascotState: 'celebrating',
            updatedAt: DateTime.now(),
          );
          await _repository.saveProfile(updatedProfile);
        }

        return Right(newAchievements);
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error detectando logros: $e');
      }
      return Left('Error detectando logros: $e');
    }
  }

  /// Determina el estado de la mascota
  String _determineMascotState(
    UserGamificationProfile profile,
    DailyStreak streak,
  ) {
    if (profile.isPauseModeActive) return 'supporting';

    final streakStatus = _streakService.checkStreakStatus(streak);
    switch (streakStatus) {
      case StreakStatus.active:
        if (profile.levelProgress > 0.8) {
          return 'thinking';
        }
        return 'happy';
      case StreakStatus.atRisk:
        return 'worried';
      case StreakStatus.lost:
        return 'supporting';
      case StreakStatus.paused:
        return 'supporting';
      case StreakStatus.noActivity:
        return 'sleeping';
    }
  }

  /// Obtiene el conteo de registros de hoy
  Future<int> getTodayRecordsCount(String userId) async {
    try {
      final lactationService = getIt<LactationService>();
      final stats = await lactationService.getStats();
      return stats.feedsToday;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el conteo de registros completos de hoy
  Future<int> getTodayCompleteRecordsCount(String userId) async {
    try {
      final today = DateTime.now();
      final lactationService = getIt<LactationService>();
      final todayRecords = await lactationService.getRecordsForDate(today);
      return todayRecords.where((record) {
        return record.vecesPecho > 0 || record.vecesBiberon > 0;
      }).length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el conteo de trivias pendientes
  Future<int> getPendingTriviasCount(String userId) async {
    try {
      final lessonRepository = getIt<LessonRepository>();
      final lessonsResult = await lessonRepository.getAllLessons();
      int pendingCount = 0;

      lessonsResult.fold((failure) => null, (lessons) {
        // Contar lecciones que tienen trivias pendientes
        // Por ahora, asumimos que todas las lecciones tienen trivias pendientes si no hay transacción XP
        // TODO: Implementar verificación real de trivias completadas por lección
        pendingCount = lessons.length;
        return null;
      });

      return pendingCount;
    } catch (e) {
      return 0;
    }
  }

  /// Verifica si una lección tiene trivias completadas
  Future<bool> isLessonTriviaCompleted(String userId, String lessonId) async {
    try {
      final profileResult = await _repository.getProfile(userId);
      return profileResult.fold((error) => false, (profile) {
        if (profile == null) return false;
        // Verificar si hay trivias completadas para esta lección
        // Por ahora, asumimos que si no está en la lista de logros, no está completada
        return false; // TODO: Implementar lógica real
      });
    } catch (e) {
      return false;
    }
  }
}
