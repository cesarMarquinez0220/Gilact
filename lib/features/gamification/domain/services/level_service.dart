import '../entities/user_gamification_profile.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Servicio para calcular niveles basándose en XP
/// Fórmula: XP requerido para nivel N = 100 * N * (N + 1) / 2
class LevelService {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  final AppLogger _logger = getIt<AppLogger>();

  /// Calcula el XP total necesario para alcanzar un nivel específico
  /// Fórmula: 100 * N * (N + 1) / 2
  int getTotalXPForLevel(int level) {
    if (level <= 0) return 0;
    if (level == 1) return 100;
    return (100 * level * (level + 1)) ~/ 2;
  }

  /// Calcula el XP total necesario para alcanzar el siguiente nivel
  /// Retorna el XP total necesario, no el XP adicional
  int getXPForNextLevel(int currentLevel) {
    if (currentLevel <= 0) return 100;
    return getTotalXPForLevel(currentLevel + 1);
  }

  /// Calcula el nivel basándose en el XP total
  int calculateLevelFromTotalXP(int totalXP) {
    if (totalXP < 100) return 1;

    int level = 1;
    int requiredXP = getTotalXPForLevel(level);

    while (totalXP >= requiredXP) {
      level++;
      requiredXP = getTotalXPForLevel(level);
    }

    return level - 1; // Retornar el nivel anterior (el que ya alcanzó)
  }

  /// Calcula el XP en el nivel actual (XP total - XP necesario para alcanzar el nivel actual)
  /// Siempre retorna el XP desde el inicio del nivel actual
  /// Para nivel 1:
  ///   - Si totalXP < 100: retorna totalXP (aún no alcanzó los 100 XP del nivel 1)
  ///   - Si totalXP >= 100: retorna totalXP - 100 (XP desde que alcanzó nivel 1)
  /// Para niveles superiores: retorna totalXP - XP necesario para alcanzar el nivel actual
  int calculateCurrentLevelXP(int totalXP, int currentLevel) {
    if (currentLevel <= 1) {
      // Para nivel 1, si tiene menos de 100 XP, el XP en el nivel es el total
      // Si tiene 100 o más XP, el XP en el nivel es el total menos los 100 XP del nivel 1
      final level1XP = getTotalXPForLevel(1);
      if (totalXP < level1XP) {
        return totalXP; // Aún no alcanzó los 100 XP del nivel 1
      }
      return totalXP - level1XP; // Ya alcanzó nivel 1, calcular XP adicional
    }

    // Para niveles superiores: restar el XP necesario para alcanzar el nivel actual
    // No el nivel anterior, sino el nivel actual
    final currentLevelTotalXP = getTotalXPForLevel(currentLevel);
    return totalXP - currentLevelTotalXP;
  }

  /// Calcula el XP necesario para alcanzar el siguiente nivel
  /// Retorna el XP necesario desde el inicio del nivel actual hasta el siguiente
  /// Para nivel 1: retorna el XP necesario para llegar a nivel 2 (200)
  /// Para nivel 2: retorna el XP necesario para llegar a nivel 3 (300)
  int calculateNextLevelXP(int currentLevel, int totalXP) {
    final currentLevelTotalXP = getTotalXPForLevel(currentLevel);
    final nextLevelTotalXP = getTotalXPForLevel(currentLevel + 1);
    // XP necesario desde el inicio del nivel actual hasta el siguiente
    return nextLevelTotalXP - currentLevelTotalXP;
  }

  /// Actualiza el perfil con el nuevo nivel después de agregar XP
  UserGamificationProfile updateLevelAfterXP(
    UserGamificationProfile profile,
    int additionalXP,
  ) {
    final newTotalXP = profile.totalXP + additionalXP;
    final newLevel = calculateLevelFromTotalXP(newTotalXP);
    final newCurrentLevelXP = calculateCurrentLevelXP(newTotalXP, newLevel);
    // Calcular el XP adicional necesario para el siguiente nivel
    final newNextLevelXP = calculateNextLevelXP(newLevel, newTotalXP);

    // Verificar si subió de nivel
    final leveledUp = newLevel > profile.currentLevel;

    if (leveledUp) {
      _logger.d(
        'LevelService: Usuario ${profile.userId} subió de nivel ${profile.currentLevel} a $newLevel',
      );
      _logger.d('   └─ XP total: ${profile.totalXP} -> $newTotalXP');
      _logger.d(
        '   └─ XP en nuevo nivel: $newCurrentLevelXP / $newNextLevelXP',
      );
    }

    // Validar que los valores sean correctos
    // Si currentLevelXP es mayor que nextLevelXP, significa que el nivel debería ser mayor
    if (newCurrentLevelXP >= newNextLevelXP && newNextLevelXP > 0) {
      _logger.w(
        'LevelService: Advertencia - currentLevelXP ($newCurrentLevelXP) >= nextLevelXP ($newNextLevelXP) para nivel $newLevel',
      );
      // Recalcular el nivel para asegurar que sea correcto
      final correctedLevel = calculateLevelFromTotalXP(newTotalXP);
      if (correctedLevel != newLevel) {
        _logger.w(
          'LevelService: Corrigiendo nivel de $newLevel a $correctedLevel',
        );
        final correctedCurrentLevelXP = calculateCurrentLevelXP(
          newTotalXP,
          correctedLevel,
        );
        final correctedNextLevelXP = calculateNextLevelXP(
          correctedLevel,
          newTotalXP,
        );
        return profile.copyWith(
          totalXP: newTotalXP,
          currentLevel: correctedLevel,
          currentLevelXP: correctedCurrentLevelXP,
          nextLevelXP: correctedNextLevelXP,
          updatedAt: DateTime.now(),
        );
      }
    }

    return profile.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      currentLevelXP: newCurrentLevelXP,
      nextLevelXP: newNextLevelXP,
      updatedAt: DateTime.now(),
    );
  }

  /// Obtiene el rango del nivel (Bronce, Plata, Oro, Diamante)
  String getLevelTier(int level) {
    // Devolvemos la clave de traducción; la UI aplicará .tr()
    if (level >= 1 && level <= 5) return 'gamification.tiers.bronze';
    if (level >= 6 && level <= 10) return 'gamification.tiers.silver';
    if (level >= 11 && level <= 20) return 'gamification.tiers.gold';
    if (level >= 21) return 'gamification.tiers.diamond';
    return 'gamification.tiers.beginner';
  }

  /// Obtiene el emoji del rango
  String getLevelTierEmoji(int level) {
    if (level >= 1 && level <= 5) return '🥉';
    if (level >= 6 && level <= 10) return '🥈';
    if (level >= 11 && level <= 20) return '🥇';
    if (level >= 21) return '💎';
    return '⭐';
  }

  /// Calcula el porcentaje de progreso hacia el siguiente nivel
  /// nextLevelXP ahora representa el XP necesario desde el inicio del nivel actual
  double calculateLevelProgress(UserGamificationProfile profile) {
    if (profile.nextLevelXP == 0) return 1.0;

    // Validar que los valores sean válidos
    if (profile.currentLevelXP < 0 || profile.nextLevelXP <= 0) {
      return 0.0;
    }

    // Usar currentLevelXP y nextLevelXP directamente
    // currentLevelXP: XP en el nivel actual (desde el inicio del nivel)
    // nextLevelXP: XP necesario desde el inicio del nivel actual hasta el siguiente
    final progress = profile.currentLevelXP / profile.nextLevelXP;

    // Asegurar que el progreso esté entre 0 y 1
    // Si currentLevelXP es mayor que nextLevelXP, significa que ya alcanzó el siguiente nivel
    // pero el nivel no se actualizó correctamente, así que mostramos 100%
    if (progress > 1.0) {
      // Esto no debería pasar si el nivel está correcto, pero por seguridad retornamos 1.0
      return 1.0;
    }

    return progress.clamp(0.0, 1.0);
  }
}
