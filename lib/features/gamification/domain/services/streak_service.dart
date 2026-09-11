import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../entities/daily_streak.dart';

/// Servicio para gestionar rachas diarias
/// Diseñado con enfoque empático y offline-first
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  /// Actualiza la racha cuando hay nueva actividad
  /// OFFLINE-FIRST: Usa timestamps precisos para sincronización
  DailyStreak updateStreakOnActivity(
    DailyStreak currentStreak,
    DateTime activityTimestamp,
  ) {
    // Si el modo pausa está activo, no actualizar la racha
    if (currentStreak.isPauseModeActive) {
      return currentStreak;
    }

    final activityDate = DateTime(
      activityTimestamp.year,
      activityTimestamp.month,
      activityTimestamp.day,
    );

    // Verificar si ya hay actividad en este día
    if (currentStreak.hasActivityOnDate(activityDate)) {
      // Ya hay actividad hoy, solo actualizar lastActivityDate
      return currentStreak.copyWith(
        lastActivityDate: activityTimestamp,
      );
    }

    // Nueva actividad en un nuevo día
    final newActivityDates = List<DateTime>.from(currentStreak.activityDates)
      ..add(activityTimestamp);

    // Verificar si continúa la racha o es un nuevo inicio
    int newStreak;
    DateTime? newStreakStartDate;

    if (currentStreak.lastActivityDate == null) {
      // Primera actividad
      newStreak = 1;
      newStreakStartDate = activityTimestamp;
    } else {
      final lastActivityDate = DateTime(
        currentStreak.lastActivityDate!.year,
        currentStreak.lastActivityDate!.month,
        currentStreak.lastActivityDate!.day,
      );

      final daysDifference = activityDate.difference(lastActivityDate).inDays;

      if (daysDifference == 1) {
        // Día consecutivo - continúa la racha
        newStreak = currentStreak.currentStreak + 1;
        newStreakStartDate = currentStreak.streakStartDate ?? activityTimestamp;
      } else if (daysDifference == 0) {
        // Mismo día - no cambia la racha
        newStreak = currentStreak.currentStreak;
        newStreakStartDate = currentStreak.streakStartDate;
      } else if (daysDifference <= 2) {
        // Dentro de 48 horas - recuperación automática (EMPÁTICO)
        newStreak = currentStreak.currentStreak + 1;
        newStreakStartDate = currentStreak.streakStartDate ?? activityTimestamp;
        if (kDebugMode) {
          print(
            '✅ Racha recuperada automáticamente (dentro de 48 horas)',
          );
        }
      } else {
        // Más de 48 horas - nueva racha (pero sin culpa)
        newStreak = 1;
        newStreakStartDate = activityTimestamp;
        if (kDebugMode) {
          print(
            '🔄 Nueva racha iniciada (sin culpa, solo nuevo comienzo)',
          );
        }
      }
    }

    // Resetear días de descanso si pasó una semana
    int newRestDaysUsed = currentStreak.restDaysUsedThisWeek;
    DateTime? newWeekStartDate = currentStreak.weekStartDate;

    if (newWeekStartDate == null) {
      newWeekStartDate = activityTimestamp;
    } else {
      final daysSinceWeekStart =
          activityDate.difference(newWeekStartDate).inDays;
      if (daysSinceWeekStart >= 7) {
        // Nueva semana - resetear días de descanso
        newRestDaysUsed = 0;
        newWeekStartDate = activityTimestamp;
      }
    }

    return currentStreak.copyWith(
      currentStreak: newStreak,
      streakStartDate: newStreakStartDate,
      lastActivityDate: activityTimestamp,
      activityDates: newActivityDates,
      restDaysUsedThisWeek: newRestDaysUsed,
      weekStartDate: newWeekStartDate,
    );
  }

  /// Usa un día de descanso (EMPÁTICO - no pierde la racha)
  DailyStreak useRestDay(
    DailyStreak currentStreak,
    DateTime restDayTimestamp,
  ) {
    if (!currentStreak.canUseRestDay) {
      if (kDebugMode) {
        print('⚠️ No se pueden usar más días de descanso esta semana');
      }
      return currentStreak;
    }

    // Agregar el día de descanso como actividad (pero no cuenta para racha)
    final newActivityDates = List<DateTime>.from(currentStreak.activityDates)
      ..add(restDayTimestamp);

    return currentStreak.copyWith(
      restDaysUsedThisWeek: currentStreak.restDaysUsedThisWeek + 1,
      lastActivityDate: restDayTimestamp,
      activityDates: newActivityDates,
    );
  }

  /// Activa el modo pausa (EMPÁTICO - la usuaria puede pausar la racha)
  DailyStreak activatePauseMode(
    DailyStreak currentStreak,
    DateTime pauseStartTimestamp,
  ) {
    return currentStreak.copyWith(
      isPauseModeActive: true,
      pauseModeStartDate: pauseStartTimestamp,
    );
  }

  /// Desactiva el modo pausa
  DailyStreak deactivatePauseMode(
    DailyStreak currentStreak,
    DateTime pauseEndTimestamp,
  ) {
    // Cuando se desactiva, la racha continúa desde donde estaba
    return currentStreak.copyWith(
      isPauseModeActive: false,
      pauseModeStartDate: null,
      lastActivityDate: pauseEndTimestamp, // Actualizar para que no se pierda
    );
  }

  /// Verifica el estado de la racha (para mostrar mensajes empáticos)
  StreakStatus checkStreakStatus(DailyStreak streak) {
    if (streak.isPauseModeActive) {
      return StreakStatus.paused;
    }

    if (streak.lastActivityDate == null) {
      return StreakStatus.noActivity;
    }

    final hoursSinceLastActivity =
        DateTime.now().difference(streak.lastActivityDate!).inHours;

    if (hoursSinceLastActivity < 24) {
      return StreakStatus.active;
    } else if (hoursSinceLastActivity >= 24 && hoursSinceLastActivity < 48) {
      return StreakStatus.atRisk;
    } else {
      return StreakStatus.lost;
    }
  }

  /// Obtiene mensaje empático según el estado de la racha
  String getEmpatheticMessage(StreakStatus status, int currentStreak) {
    // Importar easy_localization en el archivo que use este método
    switch (status) {
      case StreakStatus.active:
        return 'gamification.messages.streakMessages.active'.tr(namedArgs: {'days': currentStreak.toString()});
      case StreakStatus.atRisk:
        return 'gamification.messages.streakMessages.atRisk'.tr();
      case StreakStatus.lost:
        return 'gamification.messages.streakMessages.lost'.tr();
      case StreakStatus.paused:
        return 'gamification.messages.streakMessages.pauseActive'.tr();
      case StreakStatus.noActivity:
        return 'gamification.messages.streakMessages.noActivity'.tr();
    }
  }

  /// Reconstruye la racha desde transacciones de XP (para sincronización offline)
  /// CRÍTICO: Permite reconstruir la racha basándose en timestamps de XPTransaction
  DailyStreak rebuildStreakFromXPTransactions(
    DailyStreak currentStreak,
    List<DateTime> xpTransactionTimestamps,
  ) {
    if (xpTransactionTimestamps.isEmpty) {
      return currentStreak;
    }

    // Ordenar timestamps
    final sortedTimestamps = List<DateTime>.from(xpTransactionTimestamps)
      ..sort((a, b) => a.compareTo(b));

    // Reconstruir racha analizando días consecutivos
    int maxStreak = 0;
    int currentConsecutiveDays = 0;
    DateTime? lastDate;
    DateTime? streakStartDate;

    for (final timestamp in sortedTimestamps) {
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (lastDate == null) {
        // Primera fecha
        currentConsecutiveDays = 1;
        streakStartDate = date;
        maxStreak = 1;
      } else {
        final lastDateOnly = DateTime(
          lastDate.year,
          lastDate.month,
          lastDate.day,
        );
        final daysDifference = date.difference(lastDateOnly).inDays;

        if (daysDifference == 1) {
          // Día consecutivo
          currentConsecutiveDays++;
          if (currentConsecutiveDays > maxStreak) {
            maxStreak = currentConsecutiveDays;
          }
        } else if (daysDifference == 0) {
          // Mismo día - no cambia
          // No hacer nada
        } else {
          // Día no consecutivo - reiniciar
          currentConsecutiveDays = 1;
          streakStartDate = date;
        }
      }

      lastDate = date;
    }

    return currentStreak.copyWith(
      currentStreak: maxStreak,
      streakStartDate: streakStartDate,
      lastActivityDate: sortedTimestamps.last,
      activityDates: sortedTimestamps,
    );
  }
}

/// Estado de la racha (para mensajes empáticos)
enum StreakStatus {
  active, // Racha activa
  atRisk, // En riesgo (24-48 horas)
  lost, // Perdida (más de 48 horas)
  paused, // Modo pausa activo
  noActivity, // Sin actividad aún
}

