import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/entities/daily_streak.dart';
import '../../domain/services/xp_calculation_service.dart';
import '../../domain/services/level_service.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/gamification_service.dart';
import '../../../../core/di/injection.dart';

/// BLoC para gestionar el estado de gamificación
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository;
  final XPCalculationService _xpService = XPCalculationService();
  final LevelService _levelService = LevelService();
  final StreakService _streakService = StreakService();
  final AchievementService _achievementService = AchievementService();

  GamificationBloc({required GamificationRepository repository})
    : _repository = repository,
      super(const GamificationInitial()) {
    on<LoadGamificationProfile>(_onLoadGamificationProfile);
    on<AddXP>(_onAddXP);
    on<UpdateStreak>(_onUpdateStreak);
    on<UseRestDay>(_onUseRestDay);
    on<ActivatePauseMode>(_onActivatePauseMode);
    on<DeactivatePauseMode>(_onDeactivatePauseMode);
    on<SyncWithFirestore>(_onSyncWithFirestore);
    on<DetectAchievements>(_onDetectAchievements);
    on<UpdateGamificationProfile>(_onUpdateGamificationProfile);
    on<ResetGamificationProfile>(_onResetGamificationProfile);
  }

  Future<void> _onLoadGamificationProfile(
    LoadGamificationProfile event,
    Emitter<GamificationState> emit,
  ) async {
    emit(const GamificationLoading());

    final result = await _repository.getProfile(event.userId);

    // Manejar Left y Right por separado para evitar problemas con async en fold
    if (result.isLeft()) {
      final error = result.fold((l) => l, (_) => '');
      emit(GamificationError(error));
      return;
    }

    // Manejar Right (perfil)
    final profile = result.fold((_) => null, (p) => p);
    if (profile == null) {
      // Crear perfil inicial
      final newProfile = UserGamificationProfile(
        userId: event.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveProfile(newProfile);
      emit(GamificationLoaded(profile: newProfile));
    } else {
      // Cargar logros desbloqueados
      final achievements = _achievementService.getUnlockedAchievements(profile);
      emit(
        GamificationLoaded(
          profile: profile,
          unlockedAchievements: achievements,
        ),
      );
    }
  }

  Future<void> _onAddXP(AddXP event, Emitter<GamificationState> emit) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    try {
      // ACTUALIZACIÓN OPTIMISTA: Actualizar UI inmediatamente
      // 1. Calcular nuevo XP y nivel sin esperar operaciones de BD
      final previousLevel = currentProfile.currentLevel;
      final updatedProfile = _levelService.updateLevelAfterXP(
        currentProfile,
        event.transaction.amount,
      );
      final leveledUp = updatedProfile.currentLevel > previousLevel;

      // 2. Actualizar racha optimistamente (usar racha actual del estado)
      final currentStreakDays = currentProfile.currentStreak;
      final lastActivityDate = currentProfile.lastActivityDate;
      final streakStartDate = currentProfile.streakStartDate;

      // Calcular nueva racha localmente
      DailyStreak updatedStreak;
      if (lastActivityDate != null && streakStartDate != null) {
        final existingStreak = DailyStreak(
          userId: currentProfile.userId,
          currentStreak: currentStreakDays,
          lastActivityDate: lastActivityDate,
          streakStartDate: streakStartDate,
        );
        updatedStreak = _streakService.updateStreakOnActivity(
          existingStreak,
          event.transaction.timestamp,
        );
      } else {
        final newStreak = DailyStreak(userId: currentProfile.userId);
        updatedStreak = _streakService.updateStreakOnActivity(
          newStreak,
          event.transaction.timestamp,
        );
      }

      // 3. Actualizar perfil con nueva racha (optimista)
      final profileWithStreak = updatedProfile.copyWith(
        currentStreak: updatedStreak.currentStreak,
        lastActivityDate: updatedStreak.lastActivityDate,
        streakStartDate: updatedStreak.streakStartDate,
        updatedAt: DateTime.now(),
      );

      // 4. EMITIR ESTADO INMEDIATAMENTE (actualización optimista)
      emit(
        currentState.copyWith(profile: profileWithStreak, leveledUp: leveledUp),
      );

      // OPERACIONES EN BACKGROUND (no bloquean la UI)
      // Guardar transacción y actualizar perfil en segundo plano
      // NO emitir aquí porque el handler ya terminó - solo guardar en BD
      unawaited(
        (() async {
          try {
            // 1. Guardar transacción de XP
            await _repository.saveXPTransaction(event.transaction);

            // 2. Guardar racha actualizada
            await _repository.saveStreak(updatedStreak);

            // 3. Verificar bonus de racha
            XPTransaction? streakBonus;
            if (updatedStreak.currentStreak == 3 ||
                updatedStreak.currentStreak == 7 ||
                updatedStreak.currentStreak == 30 ||
                updatedStreak.currentStreak == 60 ||
                updatedStreak.currentStreak == 100) {
              streakBonus = _xpService.calculateStreakBonus(
                userId: currentProfile.userId,
                streakDays: updatedStreak.currentStreak,
                timestamp: DateTime.now(),
              );

              if (streakBonus != null) {
                await _repository.saveXPTransaction(streakBonus);
                final profileWithBonus = _levelService.updateLevelAfterXP(
                  profileWithStreak,
                  streakBonus.amount,
                );
                await _repository.saveProfile(profileWithBonus);

                // Si hay bonus, recargar el perfil usando un nuevo evento
                // en lugar de emitir directamente
                add(LoadGamificationProfile(currentProfile.userId));
                return;
              }
            }

            // 4. Obtener conteo de registros de lactancia de hoy
            final gamificationService = getIt<GamificationService>();
            final todayRecordsCount = await gamificationService
                .getTodayCompleteRecordsCount(currentProfile.userId);

            // 5. Actualizar estado de mascota
            final mascotState = _determineMascotState(
              profileWithStreak,
              updatedStreak,
              lactationRecordsToday: todayRecordsCount,
            );
            final profileWithMascot = profileWithStreak.copyWith(
              mascotState: mascotState,
            );
            await _repository.saveProfile(profileWithMascot);

            // No emitir aquí - el estado ya fue actualizado optimistamente
            // Si necesitamos actualizar el estado de la mascota, podemos
            // recargar el perfil, pero solo si es necesario
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error en operaciones de background al agregar XP: $e');
            }
            // No emitir error aquí para no interrumpir la UI
            // La actualización optimista ya se mostró
          }
        })(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error agregando XP: $e');
      }
      emit(GamificationError('Error agregando XP: $e'));
    }
  }

  Future<void> _onUpdateStreak(
    UpdateStreak event,
    Emitter<GamificationState> emit,
  ) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    final streakResult = await _repository.getStreak(currentProfile.userId);
    streakResult.fold((error) => emit(GamificationError(error)), (
      streak,
    ) async {
      if (streak == null) {
        final newStreak = DailyStreak(userId: currentProfile.userId);
        final updatedStreak = _streakService.updateStreakOnActivity(
          newStreak,
          event.activityTimestamp,
        );
        await _repository.saveStreak(updatedStreak);
      } else {
        final updatedStreak = _streakService.updateStreakOnActivity(
          streak,
          event.activityTimestamp,
        );
        await _repository.saveStreak(updatedStreak);

        final updatedProfile = currentProfile.copyWith(
          currentStreak: updatedStreak.currentStreak,
          lastActivityDate: updatedStreak.lastActivityDate,
          streakStartDate: updatedStreak.streakStartDate,
          updatedAt: DateTime.now(),
        );
        await _repository.saveProfile(updatedProfile);

        emit(currentState.copyWith(profile: updatedProfile));
      }
    });
  }

  Future<void> _onUseRestDay(
    UseRestDay event,
    Emitter<GamificationState> emit,
  ) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    if (!currentProfile.canUseRestDay) {
      emit(
        const GamificationError(
          'No puedes usar más días de descanso esta semana',
        ),
      );
      return;
    }

    final streakResult = await _repository.getStreak(currentProfile.userId);
    streakResult.fold((error) => emit(GamificationError(error)), (
      streak,
    ) async {
      if (streak == null) return;

      final updatedStreak = _streakService.useRestDay(streak, DateTime.now());
      await _repository.saveStreak(updatedStreak);

      final updatedProfile = currentProfile.copyWith(
        restDaysUsed: updatedStreak.restDaysUsedThisWeek,
        restDaysAvailable: 3 - updatedStreak.restDaysUsedThisWeek,
        lastRestDayUsed: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveProfile(updatedProfile);

      emit(currentState.copyWith(profile: updatedProfile));
    });
  }

  Future<void> _onActivatePauseMode(
    ActivatePauseMode event,
    Emitter<GamificationState> emit,
  ) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    final streakResult = await _repository.getStreak(currentProfile.userId);
    streakResult.fold((error) => emit(GamificationError(error)), (
      streak,
    ) async {
      if (streak == null) return;

      final updatedStreak = _streakService.activatePauseMode(
        streak,
        DateTime.now(),
      );
      await _repository.saveStreak(updatedStreak);

      final updatedProfile = currentProfile.copyWith(
        isPauseModeActive: true,
        pauseModeStartDate: DateTime.now(),
        mascotState: 'supporting',
        updatedAt: DateTime.now(),
      );
      await _repository.saveProfile(updatedProfile);

      emit(currentState.copyWith(profile: updatedProfile));
    });
  }

  Future<void> _onDeactivatePauseMode(
    DeactivatePauseMode event,
    Emitter<GamificationState> emit,
  ) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    final streakResult = await _repository.getStreak(currentProfile.userId);
    streakResult.fold((error) => emit(GamificationError(error)), (
      streak,
    ) async {
      if (streak == null) return;

      final updatedStreak = _streakService.deactivatePauseMode(
        streak,
        DateTime.now(),
      );
      await _repository.saveStreak(updatedStreak);

      final updatedProfile = currentProfile.copyWith(
        isPauseModeActive: false,
        pauseModeStartDate: null,
        mascotState: 'happy',
        updatedAt: DateTime.now(),
      );
      await _repository.saveProfile(updatedProfile);

      emit(currentState.copyWith(profile: updatedProfile));
    });
  }

  Future<void> _onSyncWithFirestore(
    SyncWithFirestore event,
    Emitter<GamificationState> emit,
  ) async {
    final result = await _repository.syncWithFirestore(event.userId);
    result.fold(
      (error) {
        if (kDebugMode) {
          print('⚠️ Error sincronizando: $error');
        }
      },
      (_) {
        if (kDebugMode) {
          print('✅ Sincronización completada');
        }
        // Recargar perfil después de sincronizar
        add(LoadGamificationProfile(event.userId));
      },
    );
  }

  Future<void> _onDetectAchievements(
    DetectAchievements event,
    Emitter<GamificationState> emit,
  ) async {
    if (state is! GamificationLoaded) return;

    final currentState = state as GamificationLoaded;
    final currentProfile = currentState.profile;

    final newAchievements = _achievementService.detectNewAchievements(
      profile: currentProfile,
      totalLactationRecords: event.totalLactationRecords,
      completeLactationRecords: event.completeLactationRecords,
      totalLessonsCompleted: event.totalLessonsCompleted,
      babyWeightRecords: event.babyWeightRecords,
      hasNocturnalRecord: event.hasNocturnalRecord,
      dailyRecordsToday: event.dailyRecordsToday,
    );

    if (newAchievements.isNotEmpty) {
      // Agregar XP por logros desbloqueados
      for (final achievement in newAchievements) {
        final xpTransaction = _xpService.calculateXPForAchievement(
          userId: currentProfile.userId,
          achievementId: achievement.id,
          xpReward: achievement.xpReward,
          timestamp: DateTime.now(),
        );
        await _repository.saveXPTransaction(xpTransaction);

        // Actualizar perfil con nuevo XP
        final updatedProfile = _levelService.updateLevelAfterXP(
          currentProfile,
          achievement.xpReward,
        );
        await _repository.saveProfile(updatedProfile);
      }

      // Actualizar lista de logros desbloqueados
      final updatedUnlockedAchievements = [
        ...currentState.unlockedAchievements,
        ...newAchievements,
      ];
      final updatedAchievementIds = updatedUnlockedAchievements
          .map((a) => a.id)
          .toList();

      final updatedProfile = currentProfile.copyWith(
        unlockedAchievements: updatedAchievementIds,
        mascotState: 'celebrating',
        updatedAt: DateTime.now(),
      );
      await _repository.saveProfile(updatedProfile);

      emit(
        currentState.copyWith(
          profile: updatedProfile,
          unlockedAchievements: updatedUnlockedAchievements,
          newlyUnlockedAchievements: newAchievements,
        ),
      );
    }
  }

  /// Determina el estado de la mascota basándose en el perfil y la racha
  Future<void> _onUpdateGamificationProfile(
    UpdateGamificationProfile event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _repository.saveProfile(event.profile);

      if (state is GamificationLoaded) {
        final currentState = state as GamificationLoaded;
        final achievements = _achievementService.getUnlockedAchievements(
          event.profile,
        );
        emit(
          currentState.copyWith(
            profile: event.profile,
            unlockedAchievements: achievements,
          ),
        );
      } else {
        final achievements = _achievementService.getUnlockedAchievements(
          event.profile,
        );
        emit(
          GamificationLoaded(
            profile: event.profile,
            unlockedAchievements: achievements,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando perfil: $e');
      }
      emit(GamificationError('Error actualizando perfil: $e'));
    }
  }

  Future<void> _onResetGamificationProfile(
    ResetGamificationProfile event,
    Emitter<GamificationState> emit,
  ) async {
    // Resetear el estado a inicial
    emit(const GamificationInitial());
  }

  String _determineMascotState(
    UserGamificationProfile profile,
    DailyStreak streak, {
    int? lactationRecordsToday,
  }) {
    // Si no hay registros de lactancia hoy, el bebé está preocupado
    if (lactationRecordsToday != null && lactationRecordsToday == 0) {
      return 'worried';
    }

    if (profile.isPauseModeActive) return 'supporting';

    final streakStatus = _streakService.checkStreakStatus(streak);
    switch (streakStatus) {
      case StreakStatus.active:
        // Cerca de subir de nivel?
        if (profile.levelProgress > 0.8) {
          return 'thinking';
        }
        return 'happy';
      case StreakStatus.atRisk:
        return 'worried';
      case StreakStatus.lost:
        return 'supporting'; // Empático, no triste
      case StreakStatus.paused:
        return 'supporting';
      case StreakStatus.noActivity:
        return 'sleeping';
    }
  }
}
