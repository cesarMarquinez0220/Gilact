import 'package:equatable/equatable.dart';

/// Tipo de logro
enum AchievementType {
  lactation, // Relacionado con registros de lactancia
  lesson, // Relacionado con lecciones
  streak, // Relacionado con rachas
  special, // Logros especiales (niveles, etc.)
}

/// Logro/Badge que el usuario puede desbloquear
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji o asset path
  final AchievementType type;
  final int requiredValue; // Valor requerido (ej: 7 días para racha de 7)
  final int xpReward; // XP que otorga al desbloquearse
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requiredValue,
    this.xpReward = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        type,
        requiredValue,
        xpReward,
        isUnlocked,
        unlockedAt,
      ];

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requiredValue,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requiredValue: requiredValue ?? this.requiredValue,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

