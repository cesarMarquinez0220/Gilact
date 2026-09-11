import 'package:equatable/equatable.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/entities/achievement.dart';

/// Estados del BLoC de gamificación
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GamificationInitial extends GamificationState {
  const GamificationInitial();
}

/// Cargando perfil
class GamificationLoading extends GamificationState {
  const GamificationLoading();
}

/// Perfil cargado exitosamente
class GamificationLoaded extends GamificationState {
  final UserGamificationProfile profile;
  final List<Achievement> unlockedAchievements;
  final bool leveledUp;
  final List<Achievement> newlyUnlockedAchievements;

  const GamificationLoaded({
    required this.profile,
    this.unlockedAchievements = const [],
    this.leveledUp = false,
    this.newlyUnlockedAchievements = const [],
  });

  @override
  List<Object?> get props => [
        profile,
        unlockedAchievements,
        leveledUp,
        newlyUnlockedAchievements,
      ];

  GamificationLoaded copyWith({
    UserGamificationProfile? profile,
    List<Achievement>? unlockedAchievements,
    bool? leveledUp,
    List<Achievement>? newlyUnlockedAchievements,
  }) {
    return GamificationLoaded(
      profile: profile ?? this.profile,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      leveledUp: leveledUp ?? this.leveledUp,
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
    );
  }
}

/// Error al cargar perfil
class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}

