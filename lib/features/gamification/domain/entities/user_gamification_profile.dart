import 'package:equatable/equatable.dart';

/// Perfil de gamificación del usuario
/// Diseñado con enfoque empático y offline-first
class UserGamificationProfile extends Equatable {
  final String userId;
  final int totalXP; // XP total acumulado
  final int currentLevel; // Nivel actual
  final int currentLevelXP; // XP en el nivel actual
  final int nextLevelXP; // XP necesario para siguiente nivel
  final int currentStreak; // Racha actual en días
  final DateTime? lastActivityDate; // Última fecha de actividad (CRÍTICO para offline)
  final DateTime? streakStartDate; // Fecha de inicio de racha
  final List<String> unlockedAchievements; // IDs de logros desbloqueados
  final String mascotState; // Estado actual del muñequito
  final int mascotLevel; // Nivel del muñequito (crece con el usuario)
  final Map<String, int> dailyXP; // XP ganado por día (últimos 30 días)

  // CAMPOS EMPÁTICOS - Protección contra ansiedad
  final int restDaysUsed; // Días de descanso usados esta semana
  final int restDaysAvailable; // Días de descanso disponibles (3 por semana)
  final bool isPauseModeActive; // Modo pausa activo (no cuenta racha)
  final DateTime? pauseModeStartDate; // Cuándo empezó el modo pausa
  final DateTime? lastRestDayUsed; // Última vez que usó un día de descanso

  // OFFLINE-FIRST
  final bool isSynced; // Si está sincronizado con Firestore
  final DateTime? lastSyncAt; // Última sincronización

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserGamificationProfile({
    required this.userId,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.currentLevelXP = 0,
    this.nextLevelXP = 100,
    this.currentStreak = 0,
    this.lastActivityDate,
    this.streakStartDate,
    this.unlockedAchievements = const [],
    this.mascotState = 'happy',
    this.mascotLevel = 1,
    this.dailyXP = const {},
    this.restDaysUsed = 0,
    this.restDaysAvailable = 3,
    this.isPauseModeActive = false,
    this.pauseModeStartDate,
    this.lastRestDayUsed,
    this.isSynced = false,
    this.lastSyncAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        totalXP,
        currentLevel,
        currentLevelXP,
        nextLevelXP,
        currentStreak,
        lastActivityDate,
        streakStartDate,
        unlockedAchievements,
        mascotState,
        mascotLevel,
        dailyXP,
        restDaysUsed,
        restDaysAvailable,
        isPauseModeActive,
        pauseModeStartDate,
        lastRestDayUsed,
        isSynced,
        lastSyncAt,
        createdAt,
        updatedAt,
      ];

  UserGamificationProfile copyWith({
    String? userId,
    int? totalXP,
    int? currentLevel,
    int? currentLevelXP,
    int? nextLevelXP,
    int? currentStreak,
    DateTime? lastActivityDate,
    DateTime? streakStartDate,
    List<String>? unlockedAchievements,
    String? mascotState,
    int? mascotLevel,
    Map<String, int>? dailyXP,
    int? restDaysUsed,
    int? restDaysAvailable,
    bool? isPauseModeActive,
    DateTime? pauseModeStartDate,
    DateTime? lastRestDayUsed,
    bool? isSynced,
    DateTime? lastSyncAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGamificationProfile(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelXP: currentLevelXP ?? this.currentLevelXP,
      nextLevelXP: nextLevelXP ?? this.nextLevelXP,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      mascotState: mascotState ?? this.mascotState,
      mascotLevel: mascotLevel ?? this.mascotLevel,
      dailyXP: dailyXP ?? this.dailyXP,
      restDaysUsed: restDaysUsed ?? this.restDaysUsed,
      restDaysAvailable: restDaysAvailable ?? this.restDaysAvailable,
      isPauseModeActive: isPauseModeActive ?? this.isPauseModeActive,
      pauseModeStartDate: pauseModeStartDate ?? this.pauseModeStartDate,
      lastRestDayUsed: lastRestDayUsed ?? this.lastRestDayUsed,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si puede usar un día de descanso
  bool get canUseRestDay {
    if (isPauseModeActive) return false;
    if (restDaysAvailable <= 0) return false;

    // Resetear días disponibles si pasó una semana desde el último uso
    if (lastRestDayUsed != null) {
      final daysSinceLastRest =
          DateTime.now().difference(lastRestDayUsed!).inDays;
      if (daysSinceLastRest >= 7) {
        return true; // Se resetean automáticamente
      }
    }

    return restDaysAvailable > 0;
  }

  /// Verifica si la racha está en riesgo (última actividad hace más de 24 horas)
  bool get isStreakAtRisk {
    if (isPauseModeActive) return false;
    if (lastActivityDate == null) return true;

    final hoursSinceLastActivity =
        DateTime.now().difference(lastActivityDate!).inHours;
    return hoursSinceLastActivity >= 24 && hoursSinceLastActivity < 48;
  }

  /// Verifica si la racha se perdió (última actividad hace más de 48 horas)
  bool get isStreakLost {
    if (isPauseModeActive) return false;
    if (lastActivityDate == null) return true;

    final hoursSinceLastActivity =
        DateTime.now().difference(lastActivityDate!).inHours;
    return hoursSinceLastActivity >= 48;
  }

  /// Porcentaje de progreso hacia el siguiente nivel
  double get levelProgress {
    if (nextLevelXP == 0) return 1.0;
    final progress = currentLevelXP / nextLevelXP;
    return progress.clamp(0.0, 1.0);
  }
}

