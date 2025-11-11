import 'package:flutter/foundation.dart';
import '../entities/user_gamification_profile.dart';

/// Servicio para calcular niveles basándose en XP
/// Fórmula: XP requerido para nivel N = 100 * N * (N + 1) / 2
class LevelService {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  /// Calcula el XP total necesario para alcanzar un nivel específico
  /// Fórmula: 100 * N * (N + 1) / 2
  int getTotalXPForLevel(int level) {
    if (level <= 0) return 0;
    if (level == 1) return 100;
    return (100 * level * (level + 1)) ~/ 2;
  }

  /// Calcula el XP necesario para pasar del nivel actual al siguiente
  int getXPForNextLevel(int currentLevel) {
    if (currentLevel <= 0) return 100;
    return 100 * (currentLevel + 1);
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

  /// Calcula el XP en el nivel actual (XP total - XP del nivel anterior)
  int calculateCurrentLevelXP(int totalXP, int currentLevel) {
    if (currentLevel <= 1) return totalXP;

    final previousLevelXP = getTotalXPForLevel(currentLevel - 1);
    return totalXP - previousLevelXP;
  }

  /// Calcula el XP necesario para el siguiente nivel
  int calculateNextLevelXP(int currentLevel) {
    return getXPForNextLevel(currentLevel);
  }

  /// Actualiza el perfil con el nuevo nivel después de agregar XP
  UserGamificationProfile updateLevelAfterXP(
    UserGamificationProfile profile,
    int additionalXP,
  ) {
    final newTotalXP = profile.totalXP + additionalXP;
    final newLevel = calculateLevelFromTotalXP(newTotalXP);
    final newCurrentLevelXP = calculateCurrentLevelXP(newTotalXP, newLevel);
    final newNextLevelXP = calculateNextLevelXP(newLevel);

    // Verificar si subió de nivel
    final leveledUp = newLevel > profile.currentLevel;

    if (kDebugMode && leveledUp) {
      print(
        '🎉 Usuario ${profile.userId} subió de nivel ${profile.currentLevel} a $newLevel!',
      );
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
    if (level >= 1 && level <= 5) return 'Bronce';
    if (level >= 6 && level <= 10) return 'Plata';
    if (level >= 11 && level <= 20) return 'Oro';
    if (level >= 21) return 'Diamante';
    return 'Principiante';
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
  double calculateLevelProgress(UserGamificationProfile profile) {
    if (profile.nextLevelXP == 0) return 1.0;
    return (profile.currentLevelXP / profile.nextLevelXP).clamp(0.0, 1.0);
  }
}

