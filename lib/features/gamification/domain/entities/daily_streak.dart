import 'package:equatable/equatable.dart';

/// Datos de racha diaria - Diseñado para sincronización offline inteligente
class DailyStreak extends Equatable {
  final String userId;
  final int currentStreak; // Racha actual en días
  final DateTime? streakStartDate; // Fecha de inicio de la racha actual
  final DateTime? lastActivityDate; // Última fecha con actividad (CRÍTICO para offline)
  final List<DateTime> activityDates; // Historial de fechas con actividad (últimos 30 días)
  final int restDaysUsedThisWeek; // Días de descanso usados esta semana
  final DateTime? weekStartDate; // Inicio de la semana actual (para resetear restDays)
  final bool isPauseModeActive; // Si el modo pausa está activo
  final DateTime? pauseModeStartDate; // Cuándo empezó el modo pausa

  const DailyStreak({
    required this.userId,
    this.currentStreak = 0,
    this.streakStartDate,
    this.lastActivityDate,
    this.activityDates = const [],
    this.restDaysUsedThisWeek = 0,
    this.weekStartDate,
    this.isPauseModeActive = false,
    this.pauseModeStartDate,
  });

  @override
  List<Object?> get props => [
        userId,
        currentStreak,
        streakStartDate,
        lastActivityDate,
        activityDates,
        restDaysUsedThisWeek,
        weekStartDate,
        isPauseModeActive,
        pauseModeStartDate,
      ];

  DailyStreak copyWith({
    String? userId,
    int? currentStreak,
    DateTime? streakStartDate,
    DateTime? lastActivityDate,
    List<DateTime>? activityDates,
    int? restDaysUsedThisWeek,
    DateTime? weekStartDate,
    bool? isPauseModeActive,
    DateTime? pauseModeStartDate,
  }) {
    return DailyStreak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      activityDates: activityDates ?? this.activityDates,
      restDaysUsedThisWeek: restDaysUsedThisWeek ?? this.restDaysUsedThisWeek,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      isPauseModeActive: isPauseModeActive ?? this.isPauseModeActive,
      pauseModeStartDate: pauseModeStartDate ?? this.pauseModeStartDate,
    );
  }

  /// Verifica si hay actividad en una fecha específica
  bool hasActivityOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return activityDates.any((activityDate) {
      final activityDateOnly =
          DateTime(activityDate.year, activityDate.month, activityDate.day);
      return activityDateOnly == dateOnly;
    });
  }

  /// Verifica si la racha está en riesgo (última actividad hace más de 24h pero menos de 48h)
  bool get isAtRisk {
    if (isPauseModeActive) return false;
    if (lastActivityDate == null) return true;

    final hoursSinceLastActivity =
        DateTime.now().difference(lastActivityDate!).inHours;
    return hoursSinceLastActivity >= 24 && hoursSinceLastActivity < 48;
  }

  /// Verifica si la racha se perdió (última actividad hace más de 48h)
  bool get isLost {
    if (isPauseModeActive) return false;
    if (lastActivityDate == null) return true;

    final hoursSinceLastActivity =
        DateTime.now().difference(lastActivityDate!).inHours;
    return hoursSinceLastActivity >= 48;
  }

  /// Verifica si puede usar un día de descanso
  bool get canUseRestDay {
    if (isPauseModeActive) return false;

    // Resetear si pasó una semana
    if (weekStartDate != null) {
      final daysSinceWeekStart =
          DateTime.now().difference(weekStartDate!).inDays;
      if (daysSinceWeekStart >= 7) {
        return true; // Se resetean automáticamente
      }
    }

    return restDaysUsedThisWeek < 3; // 3 días de descanso por semana
  }
}

