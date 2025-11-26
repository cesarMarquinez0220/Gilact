import '../entities/achievement.dart';
import '../entities/user_gamification_profile.dart';

/// Servicio para detectar y gestionar logros
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Lista de imágenes de badges disponibles (rotativas)
  static const List<String> _availableBadges = [
    'assets/images/badges/birrete.png',
    'assets/images/badges/logro.png',
    'assets/images/badges/medalla.png',
    'assets/images/badges/racha.png',
  ];

  /// Obtiene un badge de forma rotativa basado en un índice
  String _getRotatingBadge(int index) {
    return _availableBadges[index % _availableBadges.length];
  }

  /// Lista de todos los logros disponibles
  List<Achievement> getAllAchievements() {
    int badgeIndex = 0; // Índice para rotación de badges

    return [
      // Logros de Lactancia - PROGRESIVOS (para prueba)
      Achievement(
        id: 'lactation_1',
        title: 'Primer Registro',
        description: '¡Tu primer registro de lactancia!',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 1,
        xpReward: 20,
      ),
      Achievement(
        id: 'lactation_2',
        title: 'Segundo Registro',
        description: '¡Ya llevas 2 registros!',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 2,
        xpReward: 30,
      ),
      Achievement(
        id: 'lactation_3',
        title: 'Tercer Registro',
        description: '¡3 registros completados!',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 3,
        xpReward: 40,
      ),
      Achievement(
        id: 'lactation_4',
        title: 'Cuarto Registro',
        description: '¡4 registros! Sigue así',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 4,
        xpReward: 50,
      ),
      Achievement(
        id: 'lactation_5',
        title: 'Quinto Registro',
        description: '¡5 registros! Eres increíble',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 5,
        xpReward: 60,
      ),
      const Achievement(
        id: 'complete_records_10',
        title: 'Registro Completo',
        description: 'Completa 10 registros completos',
        icon: '📝',
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 50,
      ),
      const Achievement(
        id: 'consistent_7_days',
        title: 'Consistente',
        description: '7 registros en 7 días',
        icon: '📊',
        type: AchievementType.lactation,
        requiredValue: 7,
        xpReward: 100,
      ),
      // Badges de Registros Diarios (Incentivos)
      Achievement(
        id: 'daily_3',
        title: 'Día Activo',
        description: '3 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 3,
        xpReward: 25,
      ),
      Achievement(
        id: 'daily_4',
        title: 'Día Consistente',
        description: '4 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 4,
        xpReward: 35,
      ),
      Achievement(
        id: 'daily_5',
        title: 'Día Dedicado',
        description: '5 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 5,
        xpReward: 45,
      ),
      Achievement(
        id: 'daily_6',
        title: 'Día Intenso',
        description: '6 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 6,
        xpReward: 55,
      ),
      Achievement(
        id: 'daily_7',
        title: 'Día Completo',
        description: '7 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 7,
        xpReward: 65,
      ),
      Achievement(
        id: 'daily_8',
        title: 'Objetivo Diario',
        description: '8 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 8,
        xpReward: 75,
      ),
      Achievement(
        id: 'daily_10',
        title: 'Día Excepcional',
        description: '10 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 100,
      ),
      Achievement(
        id: 'daily_12',
        title: 'Día Extraordinario',
        description: '12 registros en un día',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 12,
        xpReward: 150,
      ),
      const Achievement(
        id: 'nocturnal',
        title: 'Nocturna',
        description: 'Registra lactancia entre 12am-6am',
        icon: '🌙',
        type: AchievementType.lactation,
        requiredValue: 1,
        xpReward: 30,
      ),

      // Logros de Lecciones
      const Achievement(
        id: 'first_lesson',
        title: 'Primera Lección',
        description: 'Completa tu primera lección',
        icon: '📚',
        type: AchievementType.lesson,
        requiredValue: 1,
        xpReward: 50,
      ),
      const Achievement(
        id: 'student_5',
        title: 'Estudiante',
        description: 'Completa 5 lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 5,
        xpReward: 150,
      ),
      const Achievement(
        id: 'learner_10',
        title: 'Aprendiz',
        description: 'Completa 10 lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 10,
        xpReward: 300,
      ),
      const Achievement(
        id: 'master_all',
        title: 'Maestro',
        description: 'Completa todas las lecciones',
        icon: '🎓',
        type: AchievementType.lesson,
        requiredValue: 100, // Ajustar según número real de lecciones
        xpReward: 1000,
      ),

      // Logros de Racha
      const Achievement(
        id: 'streak_3',
        title: 'Iniciando',
        description: 'Racha de 3 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 3,
        xpReward: 50,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Comprometida',
        description: 'Racha de 7 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 7,
        xpReward: 100,
      ),
      const Achievement(
        id: 'streak_30',
        title: 'Dedicada',
        description: 'Racha de 30 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 30,
        xpReward: 500,
      ),
      const Achievement(
        id: 'streak_100',
        title: 'Legendaria',
        description: 'Racha de 100 días',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 100,
        xpReward: 2000,
      ),

      // Logros Especiales
      const Achievement(
        id: 'level_5',
        title: 'Nivel 5',
        description: 'Alcanza nivel 5',
        icon: '⭐',
        type: AchievementType.special,
        requiredValue: 5,
        xpReward: 200,
      ),
      const Achievement(
        id: 'level_10',
        title: 'Nivel 10',
        description: 'Alcanza nivel 10',
        icon: '⭐',
        type: AchievementType.special,
        requiredValue: 10,
        xpReward: 500,
      ),
      const Achievement(
        id: 'perfect_week',
        title: 'Semana Perfecta',
        description: '7 días consecutivos con actividad',
        icon: '💪',
        type: AchievementType.special,
        requiredValue: 7,
        xpReward: 200,
      ),
      const Achievement(
        id: 'growth_tracker',
        title: 'Crecimiento',
        description: 'Registra peso del bebé 5 veces',
        icon: '📈',
        type: AchievementType.special,
        requiredValue: 5,
        xpReward: 150,
      ),

      // ========== LOGROS ADICIONALES PARA 6 MESES ==========

      // Logros de Registros Totales (Milestones)
      Achievement(
        id: 'milestone_10',
        title: 'Primeros Pasos',
        description: 'Completa 10 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 50,
      ),
      Achievement(
        id: 'milestone_25',
        title: 'Constante',
        description: 'Completa 25 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 25,
        xpReward: 100,
      ),
      Achievement(
        id: 'milestone_50',
        title: 'Dedicada',
        description: 'Completa 50 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 50,
        xpReward: 200,
      ),
      Achievement(
        id: 'milestone_100',
        title: 'Experta',
        description: 'Completa 100 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 100,
        xpReward: 400,
      ),
      Achievement(
        id: 'milestone_250',
        title: 'Maestra',
        description: 'Completa 250 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 250,
        xpReward: 800,
      ),
      Achievement(
        id: 'milestone_500',
        title: 'Leyenda',
        description: 'Completa 500 registros de lactancia',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 500,
        xpReward: 1500,
      ),

      // Logros de Registros Completos
      Achievement(
        id: 'complete_25',
        title: 'Detallista',
        description: 'Completa 25 registros completos',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 25,
        xpReward: 150,
      ),
      Achievement(
        id: 'complete_50',
        title: 'Completa',
        description: 'Completa 50 registros completos',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 50,
        xpReward: 300,
      ),
      Achievement(
        id: 'complete_100',
        title: 'Perfeccionista',
        description: 'Completa 100 registros completos',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 100,
        xpReward: 600,
      ),

      // Logros de Lecciones Adicionales
      Achievement(
        id: 'lessons_7',
        title: 'Estudiante Avanzada',
        description: 'Completa 7 lecciones',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lesson,
        requiredValue: 7,
        xpReward: 200,
      ),
      Achievement(
        id: 'lessons_all',
        title: 'Experta en Lactancia',
        description: 'Completa todas las lecciones (14)',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lesson,
        requiredValue: 14,
        xpReward: 1000,
      ),

      // Logros de Racha Adicionales
      Achievement(
        id: 'streak_90',
        title: 'Trimestre Constante',
        description: 'Racha de 90 días',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.streak,
        requiredValue: 90,
        xpReward: 1500,
      ),
      Achievement(
        id: 'streak_180',
        title: 'Semestre Legendario',
        description: 'Racha de 180 días (6 meses)',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.streak,
        requiredValue: 180,
        xpReward: 3000,
      ),

      // Logros de Niveles Adicionales
      Achievement(
        id: 'level_3',
        title: 'Nivel 3',
        description: 'Alcanza nivel 3',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 3,
        xpReward: 100,
      ),
      Achievement(
        id: 'level_15',
        title: 'Nivel 15',
        description: 'Alcanza nivel 15',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 15,
        xpReward: 1000,
      ),
      Achievement(
        id: 'level_20',
        title: 'Nivel 20',
        description: 'Alcanza nivel 20',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 20,
        xpReward: 2000,
      ),

      // Logros Especiales Adicionales
      Achievement(
        id: 'nocturnal_10',
        title: 'Madrugadora',
        description: '10 registros entre 12am-6am',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lactation,
        requiredValue: 10,
        xpReward: 200,
      ),
      Achievement(
        id: 'weight_10',
        title: 'Crecimiento',
        description: 'Registra peso del bebé 10 veces',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 10,
        xpReward: 150,
      ),
      Achievement(
        id: 'sleep_20',
        title: 'Sueño Dorado',
        description: 'Registra sueño del bebé 20 veces',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 20,
        xpReward: 150,
      ),
      Achievement(
        id: 'trivia_perfect_5',
        title: 'Trivia Perfecta',
        description: 'Completa 5 trivias con 100%',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.lesson,
        requiredValue: 5,
        xpReward: 300,
      ),
      Achievement(
        id: 'perfect_month',
        title: 'Mes Perfecto',
        description: '30 días consecutivos con actividad',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 30,
        xpReward: 1000,
      ),

      // Logros de Tiempo (Días usando la app)
      Achievement(
        id: 'first_week',
        title: 'Primera Semana',
        description: '7 días usando la app',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 7,
        xpReward: 100,
      ),
      Achievement(
        id: 'first_month',
        title: 'Primer Mes',
        description: '30 días usando la app',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 30,
        xpReward: 300,
      ),
      Achievement(
        id: 'three_months',
        title: 'Tres Meses',
        description: '90 días usando la app',
        icon: _getRotatingBadge(badgeIndex++),
        type: AchievementType.special,
        requiredValue: 90,
        xpReward: 800,
      ),
      Achievement(
        id: 'six_months',
        title: 'Seis Meses',
        description: '180 días usando la app',
        icon: _getRotatingBadge(badgeIndex++),
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
            // Badges de registros diarios (incentivos)
            case 'daily_3':
              shouldUnlock = dailyRecordsToday >= 3;
              break;
            case 'daily_4':
              shouldUnlock = dailyRecordsToday >= 4;
              break;
            case 'daily_5':
              shouldUnlock = dailyRecordsToday >= 5;
              break;
            case 'daily_6':
              shouldUnlock = dailyRecordsToday >= 6;
              break;
            case 'daily_7':
              shouldUnlock = dailyRecordsToday >= 7;
              break;
            case 'daily_8':
              shouldUnlock = dailyRecordsToday >= 8;
              break;
            case 'daily_10':
              shouldUnlock = dailyRecordsToday >= 10;
              break;
            case 'daily_12':
              shouldUnlock = dailyRecordsToday >= 12;
              break;
            case 'nocturnal':
              shouldUnlock = hasNocturnalRecord;
              break;
            // Milestones
            case 'milestone_10':
            case 'milestone_25':
            case 'milestone_50':
            case 'milestone_100':
            case 'milestone_250':
            case 'milestone_500':
              shouldUnlock = totalLactationRecords >= achievement.requiredValue;
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
            default:
              shouldUnlock = totalLessonsCompleted >= achievement.requiredValue;
              break;
          }
          break;

        case AchievementType.streak:
          switch (achievement.id) {
            case 'streak_90':
            case 'streak_180':
              shouldUnlock = profile.currentStreak >= achievement.requiredValue;
              break;
            default:
              shouldUnlock = profile.currentStreak >= achievement.requiredValue;
              break;
          }
          break;

        case AchievementType.special:
          switch (achievement.id) {
            case 'level_3':
            case 'level_5':
            case 'level_10':
            case 'level_15':
            case 'level_20':
              shouldUnlock = profile.currentLevel >= achievement.requiredValue;
              break;
            case 'perfect_week':
              shouldUnlock = profile.currentStreak >= 7;
              break;
            case 'perfect_month':
              shouldUnlock = profile.currentStreak >= 30;
              break;
            case 'growth_tracker':
              shouldUnlock = babyWeightRecords >= 5;
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
