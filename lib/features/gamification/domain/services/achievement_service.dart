import 'package:flutter/foundation.dart';
import '../entities/achievement.dart';
import '../entities/user_gamification_profile.dart';

/// Servicio para detectar y gestionar logros
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Obtiene el badge específico para un achievement según su ID
  /// Retorna el path del badge específico o un badge genérico si no existe
  String _getBadgeForAchievement(String achievementId) {
    final badgeMap = {
      // Logros de Registros Totales (Milestones)
      'milestone_10': 'assets/images/badges/badge_10.png',
      'milestone_25': 'assets/images/badges/badge_25.png',
      'milestone_50': 'assets/images/badges/badge_50.png',
      'milestone_100': 'assets/images/badges/badge_100.png',
      'milestone_250': 'assets/images/badges/badge_250.png',
      'milestone_500': 'assets/images/badges/badge_500.png',

      // Logros de Registros Completos
      'complete_25': 'assets/images/badges/badge_complete_25.png',
      'complete_50': 'assets/images/badges/badge_complete_50.png',
      'complete_100': 'assets/images/badges/badge_complete_100.png',

      // Logros de Lecciones
      'lessons_7': 'assets/images/badges/badge_lessons_7.png',
      'lessons_all': 'assets/images/badges/badge_lessons_all.png',

      // Logros de Racha
      'streak_7': 'assets/images/badges/badge_streak_7.png',
      'streak_30': 'assets/images/badges/badge_streak_30.png',
      'streak_90': 'assets/images/badges/badge_streak_90.png',
      'streak_180': 'assets/images/badges/badge_streak_180.png',

      // Logros de Niveles
      'level_1': 'assets/images/badges/badge_level_1.png',
      'level_3': 'assets/images/badges/badge_level_3.png',
      'level_5': 'assets/images/badges/badge_level_5.png',
      'level_10': 'assets/images/badges/badge_level_10.png',
      'level_15': 'assets/images/badges/badge_level_15.png',
      'level_20': 'assets/images/badges/badge_level_20.png',

      // Logros Especiales
      'nocturnal_10': 'assets/images/badges/badge_nocturnal_10.png',
      'weight_10': 'assets/images/badges/badge_weight_10.png',
      'sleep_20': 'assets/images/badges/badge_sleep_20.png',
      'trivia_perfect_5': 'assets/images/badges/badge_trivia_perfect_5.png',

      // Logros Diarios - Los 3 genéricos se usan UNA SOLA VEZ cada uno (según BADGES_NEEDED_LIST.md)
      'daily_3':
          'assets/images/badges/logro.png', // Día Activo - ÚNICO uso de logro.png
      'daily_5':
          'assets/images/badges/medalla.png', // Día Dedicado - ÚNICO uso de medalla.png
      'daily_10':
          'assets/images/badges/birrete.png', // Día Excepcional - ÚNICO uso de birrete.png
      // Logros de Tiempo
      'first_week': 'assets/images/badges/badge_first_week.png',
      'first_month': 'assets/images/badges/badge_first_month.png',
      'three_months': 'assets/images/badges/badge_three_months.png',
      'six_months': 'assets/images/badges/badge_six_months.png',
    };

    final specificBadge = badgeMap[achievementId];
    if (specificBadge != null) {
      return specificBadge;
    }

    // Si no hay badge específico, retornar badge genérico por defecto
    // (No debería pasar ya que todos los achievements tienen badges específicos)
    return 'assets/images/badges/logro.png';
  }

  /// Lista de todos los logros disponibles
  /// Solo incluye achievements que tienen badges específicos según BADGES_NEEDED_LIST.md
  List<Achievement> getAllAchievements() {
    return [
      // Logros Diarios (usando los 3 badges genéricos)
      Achievement(
        id: 'daily_3',
        title: 'gamification.achievementTitles.daily3',
        description: 'gamification.achievementDescriptions.daily3',
        icon: _getBadgeForAchievement('daily_3'), // logro.png
        type: AchievementType.lactation,
        requiredValue: 3,
        xpReward: 25,
      ),
      Achievement(
        id: 'daily_5',
        title: 'gamification.achievementTitles.daily5',
        description: 'gamification.achievementDescriptions.daily5',
        icon: _getBadgeForAchievement('daily_5'), // medalla.png
        type: AchievementType.lactation,
        requiredValue: 5,
        xpReward: 45,
      ),
      Achievement(
        id: 'daily_10',
        title: 'gamification.achievementTitles.daily10',
        description: 'gamification.achievementDescriptions.daily10',
        icon: _getBadgeForAchievement('daily_10'), // birrete.png
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 100,
      ),

      // Logros de Registros Totales (Milestones)
      Achievement(
        id: 'milestone_10',
        title: 'gamification.achievementTitles.milestone10',
        description: 'gamification.achievementDescriptions.milestone10',
        icon: _getBadgeForAchievement('milestone_10'),
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 50,
      ),
      Achievement(
        id: 'milestone_25',
        title: 'gamification.achievementTitles.milestone25',
        description: 'gamification.achievementDescriptions.milestone25',
        icon: _getBadgeForAchievement('milestone_25'),
        type: AchievementType.lactation,
        requiredValue: 25,
        xpReward: 100,
      ),
      Achievement(
        id: 'milestone_50',
        title: 'gamification.achievementTitles.milestone50',
        description: 'gamification.achievementDescriptions.milestone50',
        icon: _getBadgeForAchievement('milestone_50'),
        type: AchievementType.lactation,
        requiredValue: 50,
        xpReward: 200,
      ),
      Achievement(
        id: 'milestone_100',
        title: 'gamification.achievementTitles.milestone100',
        description: 'gamification.achievementDescriptions.milestone100',
        icon: _getBadgeForAchievement('milestone_100'),
        type: AchievementType.lactation,
        requiredValue: 100,
        xpReward: 400,
      ),
      Achievement(
        id: 'milestone_250',
        title: 'gamification.achievementTitles.milestone250',
        description: 'gamification.achievementDescriptions.milestone250',
        icon: _getBadgeForAchievement('milestone_250'),
        type: AchievementType.lactation,
        requiredValue: 250,
        xpReward: 800,
      ),
      Achievement(
        id: 'milestone_500',
        title: 'gamification.achievementTitles.milestone500',
        description: 'gamification.achievementDescriptions.milestone500',
        icon: _getBadgeForAchievement('milestone_500'),
        type: AchievementType.lactation,
        requiredValue: 500,
        xpReward: 1500,
      ),

      // Logros de Registros Completos
      Achievement(
        id: 'complete_25',
        title: 'gamification.achievementTitles.complete25',
        description: 'gamification.achievementDescriptions.complete25',
        icon: _getBadgeForAchievement('complete_25'),
        type: AchievementType.lactation,
        requiredValue: 25,
        xpReward: 150,
      ),
      Achievement(
        id: 'complete_50',
        title: 'gamification.achievementTitles.complete50',
        description: 'gamification.achievementDescriptions.complete50',
        icon: _getBadgeForAchievement('complete_50'),
        type: AchievementType.lactation,
        requiredValue: 50,
        xpReward: 300,
      ),
      Achievement(
        id: 'complete_100',
        title: 'gamification.achievementTitles.complete100',
        description: 'gamification.achievementDescriptions.complete100',
        icon: _getBadgeForAchievement('complete_100'),
        type: AchievementType.lactation,
        requiredValue: 100,
        xpReward: 600,
      ),

      // Logros de Lecciones
      Achievement(
        id: 'lessons_7',
        title: 'gamification.achievementTitles.lessons7',
        description: 'gamification.achievementDescriptions.lessons7',
        icon: _getBadgeForAchievement('lessons_7'),
        type: AchievementType.lesson,
        requiredValue: 7,
        xpReward: 200,
      ),
      Achievement(
        id: 'lessons_all',
        title: 'gamification.achievementTitles.lessonsAll',
        description: 'gamification.achievementDescriptions.lessonsAll',
        icon: _getBadgeForAchievement('lessons_all'),
        type: AchievementType.lesson,
        requiredValue: 14,
        xpReward: 1000,
      ),

      // Logros de Racha
      Achievement(
        id: 'streak_7',
        title: 'gamification.achievementTitles.streak7',
        description: 'gamification.achievementDescriptions.streak7',
        icon: _getBadgeForAchievement('streak_7'),
        type: AchievementType.streak,
        requiredValue: 7,
        xpReward: 100,
      ),
      Achievement(
        id: 'streak_30',
        title: 'gamification.achievementTitles.streak30',
        description: 'gamification.achievementDescriptions.streak30',
        icon: _getBadgeForAchievement('streak_30'),
        type: AchievementType.streak,
        requiredValue: 30,
        xpReward: 500,
      ),
      Achievement(
        id: 'streak_90',
        title: 'gamification.achievementTitles.streak90',
        description: 'gamification.achievementDescriptions.streak90',
        icon: _getBadgeForAchievement('streak_90'),
        type: AchievementType.streak,
        requiredValue: 90,
        xpReward: 1500,
      ),
      Achievement(
        id: 'streak_180',
        title: 'gamification.achievementTitles.streak180',
        description: 'gamification.achievementDescriptions.streak180',
        icon: _getBadgeForAchievement('streak_180'),
        type: AchievementType.streak,
        requiredValue: 180,
        xpReward: 3000,
      ),

      // Logros de Niveles
      Achievement(
        id: 'level_1',
        title: 'gamification.achievementTitles.level1',
        description: 'gamification.achievementDescriptions.level1',
        icon: _getBadgeForAchievement('level_1'),
        type: AchievementType.special,
        requiredValue: 1,
        xpReward: 50,
      ),
      Achievement(
        id: 'level_3',
        title: 'gamification.achievementTitles.level3',
        description: 'gamification.achievementDescriptions.level3',
        icon: _getBadgeForAchievement('level_3'),
        type: AchievementType.special,
        requiredValue: 3,
        xpReward: 100,
      ),
      Achievement(
        id: 'level_5',
        title: 'gamification.achievementTitles.level5',
        description: 'gamification.achievementDescriptions.level5',
        icon: _getBadgeForAchievement('level_5'),
        type: AchievementType.special,
        requiredValue: 5,
        xpReward: 200,
      ),
      Achievement(
        id: 'level_10',
        title: 'gamification.achievementTitles.level10',
        description: 'gamification.achievementDescriptions.level10',
        icon: _getBadgeForAchievement('level_10'),
        type: AchievementType.special,
        requiredValue: 10,
        xpReward: 500,
      ),
      Achievement(
        id: 'level_15',
        title: 'gamification.achievementTitles.level15',
        description: 'gamification.achievementDescriptions.level15',
        icon: _getBadgeForAchievement('level_15'),
        type: AchievementType.special,
        requiredValue: 15,
        xpReward: 1000,
      ),
      Achievement(
        id: 'level_20',
        title: 'gamification.achievementTitles.level20',
        description: 'gamification.achievementDescriptions.level20',
        icon: _getBadgeForAchievement('level_20'),
        type: AchievementType.special,
        requiredValue: 20,
        xpReward: 2000,
      ),

      // Logros Especiales
      Achievement(
        id: 'nocturnal_10',
        title: 'gamification.achievementTitles.nocturnal10',
        description: 'gamification.achievementDescriptions.nocturnal10',
        icon: _getBadgeForAchievement('nocturnal_10'),
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 200,
      ),
      Achievement(
        id: 'weight_10',
        title: 'gamification.achievementTitles.weight10',
        description: 'gamification.achievementDescriptions.weight10',
        icon: _getBadgeForAchievement('weight_10'),
        type: AchievementType.special,
        requiredValue: 10,
        xpReward: 150,
      ),
      Achievement(
        id: 'sleep_20',
        title: 'gamification.achievementTitles.sleep20',
        description: 'gamification.achievementDescriptions.sleep20',
        icon: _getBadgeForAchievement('sleep_20'),
        type: AchievementType.special,
        requiredValue: 20,
        xpReward: 150,
      ),
      Achievement(
        id: 'trivia_perfect_5',
        title: 'gamification.achievementTitles.triviaPerfect5',
        description: 'gamification.achievementDescriptions.triviaPerfect5',
        icon: _getBadgeForAchievement('trivia_perfect_5'),
        type: AchievementType.lesson,
        requiredValue: 5,
        xpReward: 300,
      ),

      // Logros de Tiempo (Días usando la app)
      Achievement(
        id: 'first_week',
        title: 'gamification.achievementTitles.firstWeek',
        description: 'gamification.achievementDescriptions.firstWeek',
        icon: _getBadgeForAchievement('first_week'),
        type: AchievementType.special,
        requiredValue: 7,
        xpReward: 100,
      ),
      Achievement(
        id: 'first_month',
        title: 'gamification.achievementTitles.firstMonth',
        description: 'gamification.achievementDescriptions.firstMonth',
        icon: _getBadgeForAchievement('first_month'),
        type: AchievementType.special,
        requiredValue: 30,
        xpReward: 300,
      ),
      Achievement(
        id: 'three_months',
        title: 'gamification.achievementTitles.threeMonths',
        description: 'gamification.achievementDescriptions.threeMonths',
        icon: _getBadgeForAchievement('three_months'),
        type: AchievementType.special,
        requiredValue: 90,
        xpReward: 800,
      ),
      Achievement(
        id: 'six_months',
        title: 'gamification.achievementTitles.sixMonths',
        description: 'gamification.achievementDescriptions.sixMonths',
        icon: _getBadgeForAchievement('six_months'),
        type: AchievementType.special,
        requiredValue: 180,
        xpReward: 2000,
      ),
    ];
  }

  /// Detecta logros nuevos basándose en estadísticas del usuario
  /// Retorna lista de logros recién desbloqueados
  List<Achievement> detectNewAchievements({
    required UserGamificationProfile profile,
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
  }) {
    final allAchievements = getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      // Si ya está desbloqueado, saltar
      if (unlockedIds.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.lactation:
          switch (achievement.id) {
            // Logros diarios
            case 'daily_3':
              shouldUnlock = dailyRecordsToday >= 3;
              break;
            case 'daily_5':
              shouldUnlock = dailyRecordsToday >= 5;
              break;
            case 'daily_10':
              shouldUnlock = dailyRecordsToday >= 10;
              break;
            // Milestones
            case 'milestone_10':
            case 'milestone_25':
            case 'milestone_50':
            case 'milestone_100':
            case 'milestone_250':
            case 'milestone_500':
              shouldUnlock = totalLactationRecords >= achievement.requiredValue;
              if (kDebugMode && achievement.id == 'milestone_10') {
                print(
                  '🔍 [AchievementService] Verificando milestone_10: totalLactationRecords=$totalLactationRecords, requiredValue=${achievement.requiredValue}, shouldUnlock=$shouldUnlock',
                );
              }
              break;
            // Registros completos
            case 'complete_25':
            case 'complete_50':
            case 'complete_100':
              shouldUnlock =
                  completeLactationRecords >= achievement.requiredValue;
              break;
            // Nocturnos
            case 'nocturnal_10':
              shouldUnlock = nocturnalRecordsCount >= 10;
              break;
          }
          break;

        case AchievementType.lesson:
          switch (achievement.id) {
            case 'lessons_7':
            case 'lessons_all':
              shouldUnlock = totalLessonsCompleted >= achievement.requiredValue;
              break;
            case 'trivia_perfect_5':
              shouldUnlock = perfectTrivias >= 5;
              break;
          }
          break;

        case AchievementType.streak:
          switch (achievement.id) {
            case 'streak_7':
            case 'streak_30':
            case 'streak_90':
            case 'streak_180':
              shouldUnlock = profile.currentStreak >= achievement.requiredValue;
              break;
          }
          break;

        case AchievementType.special:
          switch (achievement.id) {
            case 'level_1':
            case 'level_3':
            case 'level_5':
            case 'level_10':
            case 'level_15':
            case 'level_20':
              shouldUnlock = profile.currentLevel >= achievement.requiredValue;
              break;
            case 'weight_10':
              shouldUnlock = babyWeightRecords >= 10;
              break;
            case 'sleep_20':
              shouldUnlock = babySleepRecords >= 20;
              break;
            // Logros de tiempo (días usando la app)
            case 'first_week':
              shouldUnlock = daysUsingApp >= 7;
              break;
            case 'first_month':
              shouldUnlock = daysUsingApp >= 30;
              break;
            case 'three_months':
              shouldUnlock = daysUsingApp >= 90;
              break;
            case 'six_months':
              shouldUnlock = daysUsingApp >= 180;
              break;
          }
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(
          achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
        );
      }
    }

    return newlyUnlocked;
  }

  /// Obtiene logros disponibles para usuarios preparto
  /// Filtra logros relacionados con lactancia, peso y sueño
  List<Achievement> getAvailableAchievementsForPrepartum() {
    final allAchievements = getAllAchievements();
    
    // IDs de logros que NO están disponibles para preparto
    final prepartumExcludedIds = {
      // Logros diarios de lactancia
      'daily_3',
      'daily_5',
      'daily_10',
      // Milestones de lactancia
      'milestone_10',
      'milestone_25',
      'milestone_50',
      'milestone_100',
      'milestone_250',
      'milestone_500',
      // Registros completos
      'complete_25',
      'complete_50',
      'complete_100',
      // Nocturnos
      'nocturnal_10',
      // Peso y sueño
      'weight_10',
      'sleep_20',
    };
    
    return allAchievements
        .where((achievement) => !prepartumExcludedIds.contains(achievement.id))
        .toList();
  }

  /// Obtiene logros desbloqueados por el usuario
  List<Achievement> getUnlockedAchievements(UserGamificationProfile profile) {
    final allAchievements = getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();

    return allAchievements
        .where((achievement) => unlockedIds.contains(achievement.id))
        .map((achievement) => achievement.copyWith(isUnlocked: true))
        .toList();
  }

  /// Obtiene logros bloqueados (aún no desbloqueados)
  List<Achievement> getLockedAchievements(UserGamificationProfile profile) {
    final allAchievements = getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();

    return allAchievements
        .where((achievement) => !unlockedIds.contains(achievement.id))
        .toList();
  }
}
