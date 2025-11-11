import 'package:flutter/foundation.dart';
import '../entities/xp_transaction.dart';

/// Servicio para calcular XP según diferentes acciones
/// Diseñado para ser ajustable basándose en análisis de datos
class XPCalculationService {
  static final XPCalculationService _instance = XPCalculationService._internal();
  factory XPCalculationService() => _instance;
  XPCalculationService._internal();

  // VALORES BASE DE XP (Ajustables en Beta basándose en datos)
  static const int _baseXPQuickLactation = 10;
  static const int _baseXPCompleteLactation = 20;
  static const int _baseXPLessonCompleted = 30;
  static const int _baseXPBabyWeight = 15;
  static const int _baseXPBabySleep = 10;

  // BONUSES
  static const int _bonusFirstOfDay = 5;
  static const int _bonusIncludesSleep = 10;
  static const int _bonusFirstLessonOfDay = 15;

  // BONUSES DE RACHA
  static const int _bonusStreak3Days = 50;
  static const int _bonusStreak7Days = 100;
  static const int _bonusStreak30Days = 500;
  static const int _bonusStreak60Days = 1000;
  static const int _bonusStreak100Days = 2000;

  /// Calcula XP para un registro rápido de lactancia
  XPTransaction calculateXPForQuickLactation({
    required String userId,
    required String recordId,
    required DateTime timestamp,
    bool isFirstOfDay = false,
  }) {
    int xp = _baseXPQuickLactation;
    String? bonusReason;

    if (isFirstOfDay) {
      xp += _bonusFirstOfDay;
      bonusReason = 'first_of_day';
    }

    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: xp,
      source: XPSource.lactationRecordQuick,
      sourceId: recordId,
      bonusReason: bonusReason,
      timestamp: timestamp,
    );
  }

  /// Calcula XP para un registro completo de lactancia
  XPTransaction calculateXPForCompleteLactation({
    required String userId,
    required String recordId,
    required DateTime timestamp,
    bool includesSleep = false,
    bool isFirstOfDay = false,
  }) {
    int xp = _baseXPCompleteLactation;
    String? bonusReason;

    if (isFirstOfDay) {
      xp += _bonusFirstOfDay;
      bonusReason = 'first_of_day';
    }

    if (includesSleep) {
      xp += _bonusIncludesSleep;
      bonusReason = bonusReason != null
          ? '$bonusReason + includes_sleep'
          : 'includes_sleep';
    }

    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: xp,
      source: XPSource.lactationRecordComplete,
      sourceId: recordId,
      bonusReason: bonusReason,
      timestamp: timestamp,
    );
  }

  /// Calcula XP para una lección completada
  XPTransaction calculateXPForLessonCompleted({
    required String userId,
    required String lessonId,
    required DateTime timestamp,
    bool isFirstOfDay = false,
  }) {
    int xp = _baseXPLessonCompleted;
    String? bonusReason;

    if (isFirstOfDay) {
      xp += _bonusFirstLessonOfDay;
      bonusReason = 'first_lesson_of_day';
    }

    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: xp,
      source: XPSource.lessonCompleted,
      sourceId: lessonId,
      bonusReason: bonusReason,
      timestamp: timestamp,
    );
  }

  /// Calcula XP para registro de peso del bebé
  XPTransaction calculateXPForBabyWeight({
    required String userId,
    required String recordId,
    required DateTime timestamp,
  }) {
    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: _baseXPBabyWeight,
      source: XPSource.babyWeightRecorded,
      sourceId: recordId,
      timestamp: timestamp,
    );
  }

  /// Calcula XP para registro de sueño del bebé
  XPTransaction calculateXPForBabySleep({
    required String userId,
    required String recordId,
    required DateTime timestamp,
  }) {
    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: _baseXPBabySleep,
      source: XPSource.babySleepRecorded,
      sourceId: recordId,
      timestamp: timestamp,
    );
  }

  /// Calcula bonus de XP por racha
  XPTransaction? calculateStreakBonus({
    required String userId,
    required int streakDays,
    required DateTime timestamp,
  }) {
    int? bonusXP;
    String? bonusReason;

    switch (streakDays) {
      case 3:
        bonusXP = _bonusStreak3Days;
        bonusReason = 'streak_3_days';
        break;
      case 7:
        bonusXP = _bonusStreak7Days;
        bonusReason = 'streak_7_days';
        break;
      case 30:
        bonusXP = _bonusStreak30Days;
        bonusReason = 'streak_30_days';
        break;
      case 60:
        bonusXP = _bonusStreak60Days;
        bonusReason = 'streak_60_days';
        break;
      case 100:
        bonusXP = _bonusStreak100Days;
        bonusReason = 'streak_100_days';
        break;
      default:
        return null; // No hay bonus para esta racha
    }

    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: bonusXP,
      source: XPSource.streakBonus,
      bonusReason: bonusReason,
      timestamp: timestamp,
    );
  }

  /// Calcula XP por logro desbloqueado
  XPTransaction calculateXPForAchievement({
    required String userId,
    required String achievementId,
    required int xpReward,
    required DateTime timestamp,
  }) {
    return XPTransaction(
      id: _generateTransactionId(),
      userId: userId,
      amount: xpReward,
      source: XPSource.achievementUnlocked,
      sourceId: achievementId,
      bonusReason: 'achievement_unlocked',
      timestamp: timestamp,
    );
  }

  /// Genera un ID único para la transacción
  String _generateTransactionId() {
    return 'xpt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Obtiene el valor base de XP para una fuente (útil para análisis)
  int getBaseXPForSource(XPSource source) {
    switch (source) {
      case XPSource.lactationRecordQuick:
        return _baseXPQuickLactation;
      case XPSource.lactationRecordComplete:
        return _baseXPCompleteLactation;
      case XPSource.lessonCompleted:
        return _baseXPLessonCompleted;
      case XPSource.babyWeightRecorded:
        return _baseXPBabyWeight;
      case XPSource.babySleepRecorded:
        return _baseXPBabySleep;
      default:
        return 0;
    }
  }
}

