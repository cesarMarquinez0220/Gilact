import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
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
import '../widgets/companion_achievements_section.dart';
import '../widgets/companion_daily_challenge_section.dart';
import '../widgets/companion_stats_summary.dart';
import '../widgets/companion_mascot_wrapper.dart';
import '../widgets/companion_new_achievements_animation.dart';

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
            color: const Color(0xFF667eea).withOpacity(0.3),
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
                  'Tu Compañera',
                  style: GoogleFonts.quicksand(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isShortScreen ? 4 : 6),
                Text(
                  'Tu apoyo en este viaje',
                  style: GoogleFonts.quicksand(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isSmallScreen ? 56 : 64,
            height: isSmallScreen ? 56 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
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
            color: Colors.black.withOpacity(0.05),
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
            color: Colors.black.withOpacity(0.05),
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
            'Error cargando compañera',
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
}

/// Obtiene la racha del usuario desde el repositorio
Future<DailyStreak?> _getStreak(String userId) async {
  try {
    final repository = getIt<GamificationRepository>();
    final result = await repository.getStreak(userId);
    return result.fold((error) {
      print('❌ Error obteniendo racha: $error');
      return null;
    }, (streak) => streak);
  } catch (e) {
    print('❌ Excepción obteniendo racha: $e');
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
    return DailyChallenge(
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
