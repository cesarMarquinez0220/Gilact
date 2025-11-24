import 'package:injectable/injectable.dart';
import '../entities/daily_challenge.dart';
import '../entities/user_gamification_profile.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../lessons/domain/repositories/lesson_repository.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';
import 'gamification_service.dart';

@lazySingleton
class DailyChallengeService {
  final LactationService _lactationService;
  final LessonRepository _lessonRepository;
  final BabyWeightOfflineLocalDataSource _weightDataSource;
  final SleepOfflineLocalDataSource _sleepDataSource;
  final GamificationService _gamificationService;

  DailyChallengeService(
    this._lactationService,
    this._lessonRepository,
    this._weightDataSource,
    this._sleepDataSource,
    this._gamificationService,
  );

  /// Obtiene el desafío del día adaptativo
  /// Optimizado para usar métodos específicos en lugar de getUserStatistics completo
  Future<DailyChallenge> getDailyChallenge(
    UserGamificationProfile profile,
    String userId,
  ) async {
    final List<DailyChallenge> availableChallenges = [];
    final now = DateTime.now();

    // OPTIMIZACIÓN: Obtener solo los datos necesarios en lugar de todas las estadísticas
    final todayRecords = await _lactationService.getRecordsForDate(now);
    final dailyRecordsToday = todayRecords.length;

    // Desafíos de Lactancia (siempre disponibles y repetibles)
    availableChallenges.add(
      DailyChallenge(
        id: 'lactation_3_records',
        title: 'Objetivo Diario: 3 Registros',
        description: 'Registra 3 tomas de lactancia hoy',
        type: DailyChallengeType.lactation,
        requiredValue: 3,
        xpReward: 30,
        progress: dailyRecordsToday,
        icon: '📝',
      ),
    );
    availableChallenges.add(
      DailyChallenge(
        id: 'lactation_5_records',
        title: 'Objetivo Diario: 5 Registros',
        description: 'Registra 5 tomas de lactancia hoy',
        type: DailyChallengeType.lactation,
        requiredValue: 5,
        xpReward: 50,
        progress: dailyRecordsToday,
        icon: '📝',
      ),
    );
    availableChallenges.add(
      DailyChallenge(
        id: 'lactation_8_records',
        title: 'Objetivo Diario: 8 Registros',
        description: 'Registra 8 tomas de lactancia hoy',
        type: DailyChallengeType.lactation,
        requiredValue: 8,
        xpReward: 75,
        progress: dailyRecordsToday,
        icon: '🎯',
      ),
    );

    // Desafíos de Registros Completos (siempre disponibles y repetibles)
    final todayCompleteRecords = await _getTodayCompleteRecordsCount(userId);
    availableChallenges.add(
      DailyChallenge(
        id: 'complete_2_records',
        title: 'Registros Detallados',
        description: 'Completa 2 registros de lactancia con todos los detalles',
        type: DailyChallengeType.completeLactation,
        requiredValue: 2,
        xpReward: 40,
        progress: todayCompleteRecords,
        icon: '📋',
      ),
    );

    // Desafíos de Lecciones (solo si hay lecciones pendientes)
    final lessonsResult = await _lessonRepository.getAllLessons();
    int totalLessons = 0;
    int completedLessons = 0;
    lessonsResult.fold((failure) => null, (lessons) {
      totalLessons = lessons.length;
      completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    });
    if (completedLessons < totalLessons) {
      availableChallenges.add(
        DailyChallenge(
          id: 'complete_1_lesson',
          title: 'Día de Aprendizaje',
          description: 'Completa una lección hoy',
          type: DailyChallengeType.lesson,
          requiredValue: 1,
          xpReward: 60,
          progress: 0, // Se actualiza al completar una lección
          icon: '📚',
        ),
      );
    }

    // Desafíos de Trivia (solo si hay trivias pendientes)
    final pendingTrivias = await _gamificationService.getPendingTriviasCount(
      userId,
    );
    if (pendingTrivias > 0) {
      availableChallenges.add(
        DailyChallenge(
          id: 'complete_1_trivia',
          title: 'Desafío de Conocimiento',
          description: 'Completa una trivia de lección hoy',
          type: DailyChallengeType.trivia,
          requiredValue: 1,
          xpReward: 50,
          progress: 0, // Se actualiza al completar una trivia
          icon: '🧠',
        ),
      );
    }

    // Desafíos de Peso (siempre disponibles y repetibles)
    final todayWeightRecords = await _getTodayWeightRecordsCount(userId);
    availableChallenges.add(
      DailyChallenge(
        id: 'record_baby_weight',
        title: 'Control de Crecimiento',
        description: 'Registra el peso de tu bebé hoy',
        type: DailyChallengeType.babyWeight,
        requiredValue: 1,
        xpReward: 25,
        progress: todayWeightRecords,
        icon: '⚖️',
      ),
    );

    // Desafíos de Sueño (siempre disponibles y repetibles)
    final todaySleepRecords = await _getTodaySleepRecordsCount(userId);
    availableChallenges.add(
      DailyChallenge(
        id: 'record_baby_sleep',
        title: 'Noches Tranquilas',
        description: 'Registra el sueño de tu bebé hoy',
        type: DailyChallengeType.babySleep,
        requiredValue: 1,
        xpReward: 20,
        progress: todaySleepRecords,
        icon: '😴',
      ),
    );

    // Desafíos de Racha (siempre disponibles)
    // Racha de Semana: 7 días
    final streakWeekProgress = profile.currentStreak >= 7
        ? 7
        : profile.currentStreak;
    availableChallenges.add(
      DailyChallenge(
        id: 'streak_week',
        title: 'Racha de Semana',
        description: 'Mantén una racha de 7 días consecutivos',
        type: DailyChallengeType.streak,
        requiredValue: 7,
        xpReward: 100,
        progress: streakWeekProgress,
        icon: '🔥',
      ),
    );

    // Racha de Mes: 30 días
    final streakMonthProgress = profile.currentStreak >= 30
        ? 30
        : profile.currentStreak;
    availableChallenges.add(
      DailyChallenge(
        id: 'streak_month',
        title: 'Racha de Mes',
        description: 'Mantén una racha de 30 días consecutivos',
        type: DailyChallengeType.streak,
        requiredValue: 30,
        xpReward: 500,
        progress: streakMonthProgress,
        icon: '🔥',
      ),
    );

    // Filtrar desafíos ya completados para hoy
    // Para desafíos de racha, mostrarlos siempre que:
    // 1. El progreso no haya alcanzado el objetivo, O
    // 2. Si alcanzó el objetivo pero aún no se ha reclamado el XP hoy
    final uncompletedChallenges = availableChallenges.where((c) {
      // Para desafíos de racha, verificar si ya fue completado hoy
      if (c.type == DailyChallengeType.streak) {
        final completedDate = profile.completedDailyChallenges[c.id];
        final isCompletedToday =
            completedDate != null &&
            completedDate.year == now.year &&
            completedDate.month == now.month &&
            completedDate.day == now.day;

        // Si ya fue completado y reclamado hoy, no mostrarlo
        if (isCompletedToday && c.progress >= c.requiredValue) {
          return false;
        }

        // Mostrar si aún no alcanza el objetivo o si alcanzó pero no reclamó XP hoy
        return true;
      }

      // Para otros desafíos, usar la lógica normal
      return c.progress < c.requiredValue;
    }).toList();

    if (uncompletedChallenges.isEmpty) {
      // Si todos los desafíos están completados, ofrecer un desafío de "mantenimiento"
      return DailyChallenge(
        id: 'maintain_streak',
        title: 'Mantén tu Racha',
        description: 'Realiza al menos 1 registro para mantener tu racha',
        type: DailyChallengeType.streak,
        requiredValue: 1,
        xpReward: 10,
        progress: profile.currentStreak > 0 ? 1 : 0,
        icon: '🔥',
      );
    }

    // Lógica de selección basada en el día de la semana y prioridad
    final dayOfWeek = now.weekday; // 1 = Lunes, 7 = Domingo

    // Prioridades por día (incluyendo desafíos de racha)
    List<DailyChallengeType> dailyPriorities = [];
    switch (dayOfWeek) {
      case DateTime.monday:
        dailyPriorities = [
          DailyChallengeType.streak,
          DailyChallengeType.lactation,
          DailyChallengeType.completeLactation,
        ];
        break;
      case DateTime.tuesday:
        dailyPriorities = [
          DailyChallengeType.completeLactation,
          DailyChallengeType.trivia,
          DailyChallengeType.streak,
        ];
        break;
      case DateTime.wednesday:
        dailyPriorities = [
          DailyChallengeType.trivia,
          DailyChallengeType.lesson,
          DailyChallengeType.streak,
        ];
        break;
      case DateTime.thursday:
        dailyPriorities = [
          DailyChallengeType.lesson,
          DailyChallengeType.babyWeight,
          DailyChallengeType.streak,
        ];
        break;
      case DateTime.friday:
        dailyPriorities = [
          DailyChallengeType.babyWeight,
          DailyChallengeType.babySleep,
          DailyChallengeType.streak,
        ];
        break;
      case DateTime.saturday:
        dailyPriorities = [
          DailyChallengeType.babySleep,
          DailyChallengeType.lactation,
          DailyChallengeType.streak,
        ];
        break;
      case DateTime.sunday:
        dailyPriorities = [
          DailyChallengeType.streak,
          DailyChallengeType.lactation,
          DailyChallengeType.lesson,
          DailyChallengeType.trivia,
        ];
        break;
    }

    // Seleccionar el desafío con mayor prioridad y XP
    DailyChallenge? selectedChallenge;
    int maxPriority = -1;
    int maxXP = -1;

    for (final challenge in uncompletedChallenges) {
      final priority = dailyPriorities.indexOf(challenge.type);
      if (priority > maxPriority) {
        selectedChallenge = challenge;
        maxPriority = priority;
        maxXP = challenge.xpReward;
      } else if (priority == maxPriority && challenge.xpReward > maxXP) {
        selectedChallenge = challenge;
        maxXP = challenge.xpReward;
      }
    }

    // Fallback si no se encontró un desafío con prioridad (debería ser raro con la lista actual)
    return selectedChallenge ?? uncompletedChallenges.first;
  }

  /// Obtiene el conteo de registros completos de hoy
  Future<int> _getTodayCompleteRecordsCount(String userId) async {
    try {
      final today = DateTime.now();
      final todayRecords = await _lactationService.getRecordsForDate(today);
      return todayRecords.where((record) {
        return record.vecesPecho > 0 || record.vecesBiberon > 0;
      }).length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el conteo de registros de peso de hoy
  Future<int> _getTodayWeightRecordsCount(String userId) async {
    try {
      final today = DateTime.now();
      final allWeights = await _weightDataSource.getAllRecords();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      return allWeights.where((weight) {
        final recordedAt = weight.recordedAt;
        return recordedAt.isAfter(todayStart) && recordedAt.isBefore(todayEnd);
      }).length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el conteo de registros de sueño de hoy
  Future<int> _getTodaySleepRecordsCount(String userId) async {
    try {
      final today = DateTime.now();
      final allSleepRecords = await _sleepDataSource.getAllRecords();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      return allSleepRecords.where((sleep) {
        final sleepStart = sleep.sleepStartTime;
        return sleepStart.isAfter(todayStart) && sleepStart.isBefore(todayEnd);
      }).length;
    } catch (e) {
      return 0;
    }
  }
}
