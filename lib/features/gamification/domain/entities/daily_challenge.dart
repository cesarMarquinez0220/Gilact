import 'package:equatable/equatable.dart';

/// Tipo de desafío diario
enum DailyChallengeType {
  lactation, // Desafíos de registros de lactancia
  completeLactation, // Desafíos de registros completos
  trivia, // Desafíos de trivias
  lesson, // Desafíos de lecciones
  streak, // Desafíos de racha
  babyWeight, // Desafíos de peso del bebé
  babySleep, // Desafíos de sueño del bebé
}

/// Desafío diario adaptativo
class DailyChallenge extends Equatable {
  final String id;
  final DailyChallengeType type;
  final String title;
  final String description;
  final int requiredValue; // Valor requerido para completar
  final int xpReward; // XP que se otorga al completar
  final int progress; // Progreso actual (0 a requiredValue)
  final bool isCompleted; // Si ya fue completado hoy
  final String icon; // Emoji o asset path

  const DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.requiredValue,
    required this.xpReward,
    this.progress = 0,
    this.isCompleted = false,
    this.icon = '🎯',
  });

  /// Porcentaje de progreso (0.0 a 1.0)
  double get progressPercentage {
    if (requiredValue == 0) return 0.0;
    return (progress / requiredValue).clamp(0.0, 1.0);
  }

  /// Si el desafío está completado
  bool get isDone => progress >= requiredValue || isCompleted;

  DailyChallenge copyWith({
    String? id,
    DailyChallengeType? type,
    String? title,
    String? description,
    int? requiredValue,
    int? xpReward,
    int? progress,
    bool? isCompleted,
    String? icon,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredValue: requiredValue ?? this.requiredValue,
      xpReward: xpReward ?? this.xpReward,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        requiredValue,
        xpReward,
        progress,
        isCompleted,
        icon,
      ];
}

