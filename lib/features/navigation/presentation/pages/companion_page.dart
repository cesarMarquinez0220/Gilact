import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/presentation/widgets/xp_bar_widget.dart';
import '../../../gamification/presentation/widgets/streak_widget.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../../gamification/domain/entities/daily_streak.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/daily_challenge_service.dart';
import '../../../gamification/domain/entities/daily_challenge.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/services/app_logger.dart';
import '../widgets/companion_achievements_section.dart';
import '../widgets/companion_daily_challenge_section.dart';
import '../widgets/companion_stats_summary.dart';
import '../widgets/companion_mascot_wrapper.dart';
import '../widgets/companion_new_achievements_animation.dart';
import '../../../gamification/presentation/widgets/achievement_unlocked_dialog.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import '../../../gamification/domain/services/gamification_service.dart';
import '../../../gamification/domain/services/user_statistics_service.dart';

/// Página dedicada a la compañera de gamificación
class CompanionPage extends StatelessWidget {
  const CompanionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, userState) {
          // Obtener userId del estado
          String? userId;
          if (userState is UserProfileLoaded) {
            userId = userState.profile.id;
          } else if (userState is UserProfileUpdated) {
            userId = userState.profile.id;
          }

          if (userId == null || userId.isEmpty) {
            return _buildLoadingState();
          }

          // userId ya está verificado como no-null arriba
          final validUserId = userId;

          // Cargar perfil de gamificación si no está cargado
          final gamificationBloc = context.read<GamificationBloc>();
          final currentGamificationState = gamificationBloc.state;

          if (currentGamificationState is! GamificationLoaded &&
              currentGamificationState is! GamificationLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              gamificationBloc.add(LoadGamificationProfile(validUserId));
            });
          } else if (currentGamificationState is GamificationLoaded) {
            // Detectar logros cuando se carga la página (para logros de tiempo como "Primera Semana")
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final gamificationRepository = getIt<GamificationRepository>();
                final gamificationService = GamificationService(
                  repository: gamificationRepository,
                );
                final userStatisticsService = getIt<UserStatisticsService>();
                final userStats = await userStatisticsService.getUserStatistics(
                  validUserId,
                );

                final achievements = await gamificationService
                    .detectAndUnlockAchievements(
                  userId: validUserId,
                  totalLactationRecords: userStats.totalLactationRecords,
                  completeLactationRecords: userStats.completeLactationRecords,
                  totalLessonsCompleted: userStats.totalLessonsCompleted,
                  babyWeightRecords: userStats.babyWeightRecords,
                  hasNocturnalRecord: userStats.hasNocturnalRecord,
                  dailyRecordsToday: userStats.dailyRecordsToday,
                  babySleepRecords: userStats.babySleepRecords,
                  perfectTrivias: userStats.perfectTrivias,
                  nocturnalRecordsCount: userStats.nocturnalRecordsCount,
                  daysUsingApp: userStats.daysUsingApp,
                );

                // Mostrar diálogo si hay logros nuevos
                if (achievements.isRight()) {
                  final newAchievements = achievements.getOrElse(() => []);
                  if (newAchievements.isNotEmpty && context.mounted) {
                    AchievementUnlockedDialog.show(
                      context,
                      newAchievements.first,
                      newAchievements.first.xpReward,
                    );
                  }
                }
              } catch (e) {
                // Ignorar errores en la detección de logros
                if (kDebugMode) {
                  print('Error detectando logros en companion page: $e');
                }
              }
            });
          }

          // Calcular padding bottom responsive
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 360;
          final isShortScreen = screenHeight < 700;

          // Altura de la barra de navegación
          final barHeight = isSmallScreen
              ? 80.0
              : (isShortScreen ? 84.0 : 88.0);

          // Margen inferior de la barra de navegación
          final barBottomMargin = bottomPadding > 0
              ? bottomPadding + (isSmallScreen ? 12.0 : 16.0)
              : (isSmallScreen ? 24.0 : 32.0);

          // Padding bottom total = altura barra + margen + espacio extra
          final totalBottomPadding = barHeight + barBottomMargin + 20;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: totalBottomPadding,
            ),
            child: Column(
              children: [
                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 20),
                // Mascota principal
                BlocBuilder<GamificationBloc, GamificationState>(
                  builder: (context, gamificationState) {
                    if (gamificationState is GamificationLoaded) {
                      // Tamaño responsive de la mascota
                      final mascotSize = isShortScreen ? 150.0 : 180.0;
                      return FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: CompanionMascotWrapper(
                          profile: gamificationState.profile,
                          size: mascotSize,
                        ),
                      );
                    } else if (gamificationState is GamificationLoading) {
                      return _buildLoadingMascot();
                    } else if (gamificationState is GamificationError) {
                      return _buildErrorState(gamificationState.message);
                    }
                    return _buildLoadingMascot();
                  },
                ),
                const SizedBox(height: 20),
                // Información de gamificación
                BlocBuilder<GamificationBloc, GamificationState>(
                  builder: (context, gamificationState) {
                    if (gamificationState is GamificationLoaded) {
                      // Mostrar animación de logros nuevos si hay
                      final newAchievements =
                          gamificationState.profile.newAchievements;
                      if (newAchievements.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          CompanionNewAchievementsAnimation.show(
                            context,
                            gamificationState.profile,
                            validUserId,
                          );
                        });
                      }

                      // Manejar level up con vibración y sonido mejorados
                      if (gamificationState.leveledUp) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final VibrationService vibrationService =
                              getIt<VibrationService>();
                          final SoundService soundService =
                              getIt<SoundService>();
                          vibrationService.vibrateOnLevelUp();
                          soundService
                              .playLevelUpSound(); // Usar sonido específico de level up
                        });
                      }

                      return Column(
                        children: [
                          // Barra de XP
                          FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: XPBarWidget(
                              profile: gamificationState.profile,
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 12 : 15),
                          // Widget de racha
                          FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: FutureBuilder<DailyStreak?>(
                              future: _getStreak(validUserId),
                              builder: (context, snapshot) {
                                return StreakWidget(
                                  profile: gamificationState.profile,
                                  streak: snapshot.data,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 16 : 20),
                          // Sección de Incentivos (Desafío del Día)
                          FadeInUp(
                            duration: const Duration(milliseconds: 1300),
                            child: FutureBuilder<DailyChallenge>(
                              future: _getDailyChallenge(
                                gamificationState.profile,
                                validUserId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final challenge = snapshot.data;
                                if (challenge == null) {
                                  return const SizedBox.shrink();
                                }
                                return CompanionDailyChallengeSection(
                                  profile: gamificationState.profile,
                                  challenge: challenge,
                                  userId: validUserId,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 16 : 20),
                          // Sección de Logros/Badges
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: CompanionAchievementsSection(
                              profile: gamificationState.profile,
                              unlockedAchievements:
                                  gamificationState.unlockedAchievements,
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 16 : 20),
                          // Estadísticas resumidas (más arriba ahora)
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: CompanionStatsSummary(
                              profile: gamificationState.profile,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye el header de la página
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isShortScreen = screenHeight < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 24,
        vertical: isShortScreen ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea), // Azul púrpura
            Color(0xFF764ba2), // Púrpura
            Color(0xFFf093fb), // Rosa claro
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'companion.headerTitle'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isShortScreen ? 4 : 6),
                Text(
                  'companion.headerSubtitle'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          // Botones de prueba para ver el diálogo de logro (MÁS VISIBLES)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón 1: Solo mostrar diálogo
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _testAchievementDialog(context),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber[700],
                        size: isSmallScreen ? 22 : 24,
                      ),
                    ),
                  ),
                ),
              ),
              // Botón 2: Simular desbloqueo real
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _testRealAchievementUnlock(context),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.orange[700],
                      size: isSmallScreen ? 22 : 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: isSmallScreen ? 56 : 64,
            height: isSmallScreen ? 56 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: isSmallScreen ? 28 : 32,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de carga de la mascota
  Widget _buildLoadingMascot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Construye el estado de carga inicial
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Construye el estado de error
  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'companion.errorLoadingCompanion'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Método de prueba para mostrar el diálogo de logro desbloqueado
  void _testAchievementDialog(BuildContext context) {
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    
    if (allAchievements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay logros disponibles')),
      );
      return;
    }
    
    // Buscar un logro con badge específico para la prueba
    // Intentar encontrar uno de los milestones, niveles, o daily_3 (Día Activo)
    final testAchievement = allAchievements.firstWhere(
      (a) => a.id == 'daily_3' ||  // Día Activo
             a.id == 'milestone_10' || 
             a.id == 'level_3' || 
             a.id == 'streak_7' ||
             a.id == 'complete_25',
      orElse: () => allAchievements.first,
    );
    
    AchievementUnlockedDialog.show(
      context,
      testAchievement,
      testAchievement.xpReward,
    );
  }

  /// Método de prueba para simular desbloqueo real de un logro
  /// Esto agregará el logro al perfil y mostrará la animación automáticamente
  void _testRealAchievementUnlock(BuildContext context) {
    final gamificationBloc = context.read<GamificationBloc>();
    final currentState = gamificationBloc.state;
    
    if (currentState is! GamificationLoaded) return;
    
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    
    // Buscar un logro que no esté desbloqueado
    final unlockedIds = currentState.profile.unlockedAchievements.toSet();
    final testAchievement = allAchievements.firstWhere(
      (a) => !unlockedIds.contains(a.id) && 
             (a.id == 'daily_3' ||  // Día Activo
              a.id == 'milestone_10' || 
              a.id == 'level_3' || 
              a.id == 'streak_7' ||
              a.id == 'complete_25'),
      orElse: () => allAchievements.firstWhere(
        (a) => !unlockedIds.contains(a.id),
        orElse: () => allAchievements.first,
      ),
    );
    
    // Agregar el logro al perfil
    final updatedUnlockedAchievements = [
      ...currentState.profile.unlockedAchievements,
      testAchievement.id,
    ];
    final updatedNewAchievements = [
      ...currentState.profile.newAchievements,
      testAchievement.id,
    ];
    
    final updatedProfile = currentState.profile.copyWith(
      unlockedAchievements: updatedUnlockedAchievements,
      newAchievements: updatedNewAchievements,
      updatedAt: DateTime.now(),
    );
    
    // Actualizar el perfil
    gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
    
    // Mostrar el diálogo de logro desbloqueado
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        AchievementUnlockedDialog.show(
          context,
          testAchievement,
          testAchievement.xpReward,
        );
      }
    });
  }
}

/// Obtiene la racha del usuario desde el repositorio
Future<DailyStreak?> _getStreak(String userId) async {
  try {
    final repository = getIt<GamificationRepository>();
    final logger = getIt<AppLogger>();
    final result = await repository.getStreak(userId);
    return result.fold((error) {
      logger.e('Error obteniendo racha: $error');
      return null;
    }, (streak) => streak);
  } catch (e, stackTrace) {
    final logger = getIt<AppLogger>();
    logger.e('Excepción obteniendo racha', e, stackTrace);
    return null;
  }
}

/// Obtiene el desafío del día
Future<DailyChallenge> _getDailyChallenge(
  UserGamificationProfile profile,
  String userId,
) async {
  try {
    final dailyChallengeService = getIt<DailyChallengeService>();
    return await dailyChallengeService.getDailyChallenge(profile, userId);
  } catch (e) {
    // Fallback: desafío por defecto
    return const DailyChallenge(
      id: 'default',
      title: 'Objetivo Diario',
      description: 'Completa 3 registros de lactancia hoy',
      type: DailyChallengeType.lactation,
      requiredValue: 3,
      xpReward: 30,
      progress: 0,
      icon: '📝',
    );
  }
}
