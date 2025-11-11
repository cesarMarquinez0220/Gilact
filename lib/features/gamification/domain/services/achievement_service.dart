import 'package:flutter/foundation.dart';
import '../entities/achievement.dart';
import '../entities/user_gamification_profile.dart';

/// Servicio para detectar y gestionar logros
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Lista de todos los logros disponibles
  List<Achievement> getAllAchievements() {
    return [
      // Logros de Lactancia - PROGRESIVOS (para prueba)
      Achievement(
        id: 'lactation_1',
        title: 'Primer Registro',
        description: '¡Tu primer registro de lactancia!',
        icon: 'assets/images/badges/birrete.png',
        type: AchievementType.lactation,
        requiredValue: 1,
        xpReward: 20,
      ),
      Achievement(
        id: 'lactation_2',
        title: 'Segundo Registro',
        description: '¡Ya llevas 2 registros!',
        icon: 'assets/images/badges/logro.png',
        type: AchievementType.lactation,
        requiredValue: 2,
        xpReward: 30,
      ),
      Achievement(
        id: 'lactation_3',
        title: 'Tercer Registro',
        description: '¡3 registros completados!',
        icon: 'assets/images/badges/medalla.png',
        type: AchievementType.lactation,
        requiredValue: 3,
        xpReward: 40,
      ),
      Achievement(
        id: 'lactation_4',
        title: 'Cuarto Registro',
        description: '¡4 registros! Sigue así',
        icon: 'assets/images/badges/racha.png',
        type: AchievementType.lactation,
        requiredValue: 4,
        xpReward: 50,
      ),
      Achievement(
        id: 'lactation_5',
        title: 'Quinto Registro',
        description: '¡5 registros! Eres increíble',
        icon: 'assets/images/badges/birrete.png',
        type: AchievementType.lactation,
        requiredValue: 5,
        xpReward: 60,
      ),
      Achievement(
        id: 'complete_records_10',
        title: 'Registro Completo',
        description: 'Completa 10 registros completos',
        icon: '📝',
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 50,
      ),
      Achievement(
        id: 'consistent_7_days',
        title: 'Consistente',
        description: '7 registros en 7 días',
        icon: '📊',
        type: AchievementType.lactation,
        requiredValue: 7,
        xpReward: 100,
      ),
      Achievement(
        id: 'daily_goal_8',
        title: 'Objetivo Diario',
        description: '8+ registros en un día',
        icon: '🎯',
        type: AchievementType.lactation,
        requiredValue: 8,
        xpReward: 75,
      ),
      Achievement(
        id: 'nocturnal',
        title: 'Nocturna',
        description: 'Registra lactancia entre 12am-6am',
        icon: '🌙',
        type: AchievementType.lactation,
        requiredValue: 1,
        xpReward: 30,
      ),

      // Logros de Lecciones
      Achievement(
        id: 'first_lesson',
        title: 'Primera Lección',
        description: 'Completa tu primera lección',
        icon: '📚',
        type: AchievementType.lesson,
        requiredValue: 1,
        xpReward: 50,
      ),
      Achievement(
        id: 'student_5',
        title: 'Estudiante',
        description: 'Completa 5 lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 5,
        xpReward: 150,
      ),
      Achievement(
        id: 'learner_10',
        title: 'Aprendiz',
        description: 'Completa 10 lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 10,
        xpReward: 300,
      ),
      Achievement(
        id: 'master_all',
        title: 'Maestro',
        description: 'Completa todas las lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 100, // Ajustar según número real de lecciones
        xpReward: 1000,
      ),

      // Logros de Racha
      Achievement(
        id: 'streak_3',
        title: 'Iniciando',
        description: 'Racha de 3 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 3,
        xpReward: 50,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Comprometida',
        description: 'Racha de 7 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 7,
        xpReward: 100,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Dedicada',
        description: 'Racha de 30 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 30,
        xpReward: 500,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Legendaria',
        description: 'Racha de 100 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 100,
        xpReward: 2000,
      ),

      // Logros Especiales
      Achievement(
        id: 'level_5',
        title: 'Nivel 5',
        description: 'Alcanza nivel 5',
        icon: '⭐',
        type: AchievementType.special,
        requiredValue: 5,
        xpReward: 200,
      ),
      Achievement(
        id: 'level_10',
        title: 'Nivel 10',
        description: 'Alcanza nivel 10',
        icon: '⭐',
        type: AchievementType.special,
        requiredValue: 10,
        xpReward: 500,
      ),
      Achievement(
        id: 'perfect_week',
        title: 'Semana Perfecta',
        description: '7 días consecutivos con actividad',
        icon: '💪',
        type: AchievementType.special,
        requiredValue: 7,
        xpReward: 200,
      ),
      Achievement(
        id: 'growth_tracker',
        title: 'Crecimiento',
        description: 'Registra peso del bebé 5 veces',
        icon: '📈',
        type: AchievementType.special,
        requiredValue: 5,
        xpReward: 150,
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
            case 'lactation_1':
            case 'lactation_2':
            case 'lactation_3':
            case 'lactation_4':
            case 'lactation_5':
              // Badges progresivos: desbloquear si tiene el número exacto de registros
              shouldUnlock = totalLactationRecords >= achievement.requiredValue;
              break;
            case 'complete_records_10':
              shouldUnlock = completeLactationRecords >= 10;
              break;
            case 'consistent_7_days':
              shouldUnlock = profile.currentStreak >= 7;
              break;
            case 'daily_goal_8':
              shouldUnlock = dailyRecordsToday >= 8;
              break;
            case 'nocturnal':
              shouldUnlock = hasNocturnalRecord;
              break;
          }
          break;

        case AchievementType.lesson:
          shouldUnlock = totalLessonsCompleted >= achievement.requiredValue;
          break;

        case AchievementType.streak:
          shouldUnlock = profile.currentStreak >= achievement.requiredValue;
          break;

        case AchievementType.special:
          switch (achievement.id) {
            case 'level_5':
            case 'level_10':
              shouldUnlock = profile.currentLevel >= achievement.requiredValue;
              break;
            case 'perfect_week':
              shouldUnlock = profile.currentStreak >= 7;
              break;
            case 'growth_tracker':
              shouldUnlock = babyWeightRecords >= 5;
              break;
          }
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  /// Obtiene logros desbloqueados por el usuario
  List<Achievement> getUnlockedAchievements(
    UserGamificationProfile profile,
  ) {
    final allAchievements = getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();

    return allAchievements
        .where((achievement) => unlockedIds.contains(achievement.id))
        .map((achievement) => achievement.copyWith(
              isUnlocked: true,
            ))
        .toList();
  }

  /// Obtiene logros bloqueados (aún no desbloqueados)
  List<Achievement> getLockedAchievements(
    UserGamificationProfile profile,
  ) {
    final allAchievements = getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();

    return allAchievements
        .where((achievement) => !unlockedIds.contains(achievement.id))
        .toList();
  }
}

