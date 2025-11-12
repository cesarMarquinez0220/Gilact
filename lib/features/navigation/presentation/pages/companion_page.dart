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
import '../../../gamification/domain/entities/achievement.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import '../../../../core/di/injection.dart';
import 'package:flutter/services.dart';
import '../../../lactation/data/services/lactation_service.dart';
import 'package:lottie/lottie.dart';

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
                        child: _InteractiveMascotWrapper(
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
                          // Sección de Incentivos (Badges próximos a desbloquear)
                          FadeInUp(
                            duration: const Duration(milliseconds: 1300),
                            child: FutureBuilder<int>(
                              future: _getTodayRecordsCount(),
                              builder: (context, snapshot) {
                                final todayCount = snapshot.data ?? 0;
                                return _buildDailyIncentivesSection(
                                  context,
                                  gamificationState.profile,
                                  todayCount,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 16 : 20),
                          // Sección de Logros/Badges
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: _buildAchievementsSection(
                              context,
                              gamificationState.profile,
                              gamificationState.unlockedAchievements,
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 16 : 20),
                          // Estadísticas resumidas (más arriba ahora)
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: _buildStatsSummary(
                              context,
                              gamificationState.profile,
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

  /// Construye la sección de logros/badges
  Widget _buildAchievementsSection(
    BuildContext context,
    UserGamificationProfile profile,
    List<Achievement> unlockedAchievements,
  ) {
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    final totalAchievements = allAchievements.length;
    final unlockedCount = unlockedAchievements.length;
    final progress = totalAchievements > 0
        ? unlockedCount / totalAchievements
        : 0.0;

    // Si no hay logros desbloqueados, mostrar mensaje motivacional
    if (unlockedAchievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logros',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Comienza a desbloquear logros',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '¡Comienza tu viaje! Cada acción te acerca a nuevos logros 🎯',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de logros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logros Desbloqueados',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        '$unlockedCount de $totalAchievements',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
            ),
          ),
          const SizedBox(height: 20),
          // Grid de badges
          _buildAchievementsGrid(context, unlockedAchievements),
        ],
      ),
    );
  }

  /// Construye el grid de badges/logros
  Widget _buildAchievementsGrid(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    // Ordenar por tipo y luego por requiredValue
    final sortedAchievements = List<Achievement>.from(achievements)
      ..sort((a, b) {
        if (a.type != b.type) {
          return a.type.index.compareTo(b.type.index);
        }
        return a.requiredValue.compareTo(b.requiredValue);
      });

    // Calcular columnas responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 3 : 4;
    final spacing = screenWidth < 360 ? 8.0 : 12.0;
    final aspectRatio = screenWidth < 360 ? 0.9 : 0.85;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = sortedAchievements[index];
        return _buildAchievementBadge(context, achievement);
      },
    );
  }

  /// Construye un badge individual (interactivo)
  Widget _buildAchievementBadge(BuildContext context, Achievement achievement) {
    final isAssetPath = achievement.icon.startsWith('assets/');

    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono/Badge
                  if (isAssetPath)
                    Image.asset(
                      achievement.icon,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: Colors.amber[700],
                        );
                      },
                    )
                  else
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  const SizedBox(height: 6),
                  // Título (truncado)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Muestra el diálogo con detalles del logro
  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    final isAssetPath = achievement.icon.startsWith('assets/');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono del logro
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber[300]!, width: 3),
                ),
                child: isAssetPath
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          achievement.icon,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: Colors.amber[700],
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              // Recompensa XP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber[800], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Botón cerrar
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: Colors.amber[700],
                ),
                child: Text(
                  '¡Genial!',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el resumen de estadísticas
  Widget _buildStatsSummary(
    BuildContext context,
    UserGamificationProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  label: 'Nivel',
                  value: '${profile.currentLevel}',
                  color: const Color(0xFF3498DB),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '${profile.currentStreak}',
                  color: const Color(0xFFE74C3C),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'Logros',
                  value: '${profile.unlockedAchievements.length}',
                  color: Colors.amber[700]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un item de estadística (interactivo)
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Vibración suave al tocar
        HapticFeedback.selectionClick();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  /// Obtiene el conteo de registros de hoy
  Future<int> _getTodayRecordsCount() async {
    try {
      final lactationService = getIt<LactationService>();
      final stats = await lactationService.getStats();
      return stats.feedsToday;
    } catch (e) {
      print('❌ Error obteniendo registros de hoy: $e');
      return 0;
    }
  }

  /// Construye la sección de incentivos diarios (badges próximos a desbloquear)
  Widget _buildDailyIncentivesSection(
    BuildContext context,
    UserGamificationProfile profile,
    int todayRecordsCount,
  ) {
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    final unlockedIds = profile.unlockedAchievements.toSet();

    // Obtener badges diarios no desbloqueados
    final dailyAchievements =
        allAchievements
            .where(
              (a) => a.id.startsWith('daily_') && !unlockedIds.contains(a.id),
            )
            .toList()
          ..sort((a, b) => a.requiredValue.compareTo(b.requiredValue));

    // Obtener los próximos 2-3 badges a desbloquear
    final nextAchievements = dailyAchievements.take(3).toList();

    if (nextAchievements.isEmpty) {
      // Si ya desbloqueó todos, mostrar mensaje de celebración
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green[700], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Increíble!',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    'Ya desbloqueaste todos los badges diarios 🎉',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incentivos de Hoy',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'Registros de hoy: $todayRecordsCount',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de próximos badges
          ...nextAchievements.map((achievement) {
            final progress = todayRecordsCount >= achievement.requiredValue
                ? 1.0
                : (todayRecordsCount / achievement.requiredValue).clamp(
                    0.0,
                    1.0,
                  );
            final isUnlocked = progress >= 1.0;
            final remaining = (achievement.requiredValue - todayRecordsCount)
                .clamp(0, achievement.requiredValue);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.green[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.green[300]!
                        : Colors.amber.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Icono del badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.green[100]
                            : Colors.amber[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: achievement.icon.startsWith('assets/')
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                achievement.icon,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.emoji_events,
                                    color: isUnlocked
                                        ? Colors.green[700]
                                        : Colors.amber[700],
                                    size: 24,
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Información del badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  achievement.title,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '¡Desbloqueado!',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement.description,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Barra de progreso
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUnlocked
                                    ? Colors.green[400]!
                                    : Colors.amber[600]!,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUnlocked
                                ? '¡Completado! +${achievement.xpReward} XP'
                                : 'Faltan $remaining registros (+${achievement.xpReward} XP)',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isUnlocked
                                  ? Colors.green[700]
                                  : Colors.amber[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// Widget wrapper que agrega interactividad a la mascota (Versión Simplificada)
class _InteractiveMascotWrapper extends StatefulWidget {
  final UserGamificationProfile profile;
  final double size;

  const _InteractiveMascotWrapper({required this.profile, required this.size});

  @override
  State<_InteractiveMascotWrapper> createState() =>
      _InteractiveMascotWrapperState();
}

class _InteractiveMascotWrapperState extends State<_InteractiveMascotWrapper>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  String? _currentMessage;

  // Mensajes rotativos para la mascota
  final List<String> _messages = [
    '¡Hola! ¿Cómo estás hoy? 💙',
    '¡Sigue así, lo estás haciendo genial! 🌟',
    'Cada registro cuenta, estás haciendo un gran trabajo 👏',
    'Recuerda: tu bienestar es lo más importante 💕',
    '¡Estás avanzando increíblemente! 🎉',
    'Tómate tu tiempo, no hay prisa ⏰',
    'Eres una super mamá, sigue así! 💪',
  ];

  @override
  void initState() {
    super.initState();
    // Controlador para animación de escala de la mascota
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Vibración suave
    HapticFeedback.lightImpact();

    // Animación de escala de la mascota
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Mostrar mensaje rotativo
    setState(() {
      _tapCount = (_tapCount + 1) % _messages.length;
      _currentMessage = _messages[_tapCount];
    });

    // Ocultar el mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener mensaje por defecto según el estado
    String defaultMessage;
    switch (widget.profile.mascotState) {
      case 'celebrating':
        defaultMessage = '¡Excelente trabajo! 🎉';
        break;
      case 'thinking':
        defaultMessage = 'Estás muy cerca de subir de nivel';
        break;
      case 'worried':
        defaultMessage = 'Tu racha está en riesgo...';
        break;
      case 'supporting':
        defaultMessage = 'Tómate el tiempo que necesites, estaremos aquí 💙';
        break;
      case 'sleeping':
        defaultMessage = 'Descansa bien, te esperamos mañana';
        break;
      case 'happy':
      default:
        defaultMessage = '¡Hola! ¿Cómo estás hoy?';
        break;
    }

    final messageToShow = _currentMessage ?? defaultMessage;

    return GestureDetector(
      onTap: _handleTap,
      // Usamos un Stack para posicionar la burbuja en la esquina superior derecha
      child: Container(
        color: Colors.transparent, // Fondo transparente
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. LA MASCOTA (centrada, ligeramente más abajo)
            Padding(
              padding: const EdgeInsets.only(
                top: 35,
              ), // Baja la mascota un poco más
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  child: Lottie.asset(
                    'assets/animations/Happy_Dog.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
              ),
            ),
            // 2. LA BURBUJA (posición fija arriba y a la derecha de la mascota)
            if (messageToShow.isNotEmpty)
              Positioned(
                top: -20, // Más arriba (valor negativo para subir más)
                left:
                    widget.size *
                    0.3, // Más a la izquierda (reducido de 0.4 a 0.3)
                child: ZoomIn(
                  key: ValueKey(
                    messageToShow,
                  ), // Anima cada vez que cambia el mensaje
                  duration: const Duration(milliseconds: 600),
                  child: _SpeechBubble(message: messageToShow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget de burbuja de mensaje estilo cómic con triángulo apuntando hacia abajo-izquierda
class _SpeechBubble extends StatelessWidget {
  final String message;

  const _SpeechBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Calcular el tamaño dinámico basado en el contenido del mensaje
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: 200);

    // El ancho se ajusta dinámicamente al contenido, con límites
    final dynamicWidth = (textPainter.width + 32).clamp(120.0, 220.0);

    return CustomPaint(
      painter: _SpeechBubblePainter(),
      child: Container(
        width: dynamicWidth, // Ancho dinámico según el mensaje
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20,
        ), // Más padding abajo para el triángulo
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Painter para dibujar la burbuja con triángulo apuntando hacia abajo-izquierda
class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Dibujar el cuerpo principal de la burbuja (rectángulo redondeado)
    // El triángulo está abajo, así que el rectángulo termina antes del triángulo
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 12),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);

    // Dibujar el triángulo apuntando hacia abajo-izquierda (en la esquina inferior izquierda)
    final trianglePath = Path();
    final triangleWidth = 18.0;
    final triangleX =
        25.0; // Posición X del triángulo (más a la izquierda para apuntar a la mascota)
    final bottomY = size.height;

    trianglePath.moveTo(triangleX, size.height - 12);
    trianglePath.lineTo(triangleX + triangleWidth / 2, bottomY);
    trianglePath.lineTo(triangleX + triangleWidth, size.height - 12);
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
    canvas.drawPath(trianglePath, borderPaint);

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 4, size.width, size.height - 12),
        const Radius.circular(20),
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
