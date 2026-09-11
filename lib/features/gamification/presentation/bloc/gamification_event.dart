import 'package:equatable/equatable.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/entities/user_gamification_profile.dart';

/// Eventos del BLoC de gamificación
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

/// Carga el perfil de gamificación del usuario
class LoadGamificationProfile extends GamificationEvent {
  final String userId;

  const LoadGamificationProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Agrega XP al usuario
class AddXP extends GamificationEvent {
  final XPTransaction transaction;

  const AddXP(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Actualiza la racha del usuario
class UpdateStreak extends GamificationEvent {
  final DateTime activityTimestamp;

  const UpdateStreak(this.activityTimestamp);

  @override
  List<Object?> get props => [activityTimestamp];
}

/// Usa un día de descanso
class UseRestDay extends GamificationEvent {
  const UseRestDay();
}

/// Activa el modo pausa
class ActivatePauseMode extends GamificationEvent {
  const ActivatePauseMode();
}

/// Desactiva el modo pausa
class DeactivatePauseMode extends GamificationEvent {
  const DeactivatePauseMode();
}

/// Sincroniza datos con Firestore
class SyncWithFirestore extends GamificationEvent {
  final String userId;

  const SyncWithFirestore(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Detecta y desbloquea logros nuevos
class DetectAchievements extends GamificationEvent {
  final int totalLactationRecords;
  final int completeLactationRecords;
  final int totalLessonsCompleted;
  final int babyWeightRecords;
  final bool hasNocturnalRecord;
  final int dailyRecordsToday;

  const DetectAchievements({
    required this.totalLactationRecords,
    required this.completeLactationRecords,
    required this.totalLessonsCompleted,
    required this.babyWeightRecords,
    required this.hasNocturnalRecord,
    required this.dailyRecordsToday,
  });

  @override
  List<Object?> get props => [
        totalLactationRecords,
        completeLactationRecords,
        totalLessonsCompleted,
        babyWeightRecords,
        hasNocturnalRecord,
        dailyRecordsToday,
      ];
}

/// Actualiza el perfil de gamificación
class UpdateGamificationProfile extends GamificationEvent {
  final UserGamificationProfile profile;

  const UpdateGamificationProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Resetea el perfil de gamificación (útil al cerrar sesión)
class ResetGamificationProfile extends GamificationEvent {
  const ResetGamificationProfile();

  @override
  List<Object?> get props => [];
}

