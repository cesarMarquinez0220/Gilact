import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../gamification/domain/entities/achievement.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../../core/di/injection.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../lactation/data/datasources/lactation_database.dart';
import '../../../lessons/data/repositories/lesson_repository_impl.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';

/// Diálogo de detalles de logro con carga optimizada de estadísticas
class CompanionAchievementDialog extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final UserGamificationProfile profile;

  const CompanionAchievementDialog({
    required this.achievement,
    required this.isUnlocked,
    required this.profile,
    super.key,
  });

  static void show(
    BuildContext context,
    Achievement achievement, {
    required bool isUnlocked,
    required UserGamificationProfile profile,
  }) {
    showDialog(
      context: context,
      builder: (context) => CompanionAchievementDialog(
        achievement: achievement,
        isUnlocked: isUnlocked,
        profile: profile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAssetPath = achievement.icon.startsWith('assets/');
    final initialDescription = _getDefaultProgressDescription(achievement);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _AchievementDetailsDialogContent(
        achievement: achievement,
        isUnlocked: isUnlocked,
        initialProgressDescription: initialDescription,
        isAssetPath: isAssetPath,
        profile: profile,
      ),
    );
  }

  String _getDefaultProgressDescription(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.lactation:
        if (achievement.id.startsWith('milestone_')) {
          return 'gamification.messages.achievementDescriptions.milestone'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id.startsWith('complete_')) {
          return 'gamification.messages.achievementDescriptions.complete'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id.startsWith('daily_')) {
          return 'gamification.messages.achievementDescriptions.daily'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id == 'nocturnal_10') {
          return 'gamification.messages.achievementDescriptions.nocturnal'.tr();
        }
        return 'gamification.messages.achievementDescriptions.lactation'.tr(
          namedArgs: {'value': achievement.requiredValue.toString()},
        );
      case AchievementType.lesson:
        if (achievement.id == 'trivia_perfect_5') {
          return 'gamification.messages.achievementDescriptions.triviaPerfect'
              .tr();
        }
        return 'gamification.messages.achievementDescriptions.lesson'.tr(
          namedArgs: {'value': achievement.requiredValue.toString()},
        );
      case AchievementType.streak:
        return 'gamification.messages.achievementDescriptions.streak'.tr(
          namedArgs: {'value': achievement.requiredValue.toString()},
        );
      case AchievementType.special:
        if (achievement.id.startsWith('level_')) {
          return 'gamification.messages.achievementDescriptions.level'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id == 'weight_10') {
          return 'gamification.messages.achievementDescriptions.weight'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id == 'sleep_20') {
          return 'gamification.messages.achievementDescriptions.sleep'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        } else if (achievement.id.startsWith('first_') ||
            achievement.id.startsWith('three_') ||
            achievement.id.startsWith('six_')) {
          return 'gamification.messages.achievementDescriptions.appUsage'.tr(
            namedArgs: {'value': achievement.requiredValue.toString()},
          );
        }
        return 'gamification.messages.achievementDescriptions.default'.tr();
    }
  }
}

/// Contenido del diálogo con carga asíncrona optimizada
class _AchievementDetailsDialogContent extends StatefulWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final String initialProgressDescription;
  final bool isAssetPath;
  final UserGamificationProfile profile;

  const _AchievementDetailsDialogContent({
    required this.achievement,
    required this.isUnlocked,
    required this.initialProgressDescription,
    required this.isAssetPath,
    required this.profile,
  });

  @override
  State<_AchievementDetailsDialogContent> createState() =>
      _AchievementDetailsDialogContentState();
}

class _AchievementDetailsDialogContentState
    extends State<_AchievementDetailsDialogContent> {
  String _progressDescription = '';
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _progressDescription = widget.initialProgressDescription;

    // OPTIMIZACIÓN: Solo cargar estadísticas si el logro está bloqueado
    // Y solo cargar los datos específicos necesarios para este logro
    if (!widget.isUnlocked) {
      _loadOptimizedStatistics();
    }
  }

  /// Carga solo las estadísticas necesarias para este logro específico
  /// En lugar de cargar todas las estadísticas del usuario
  Future<void> _loadOptimizedStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Cargar solo los datos necesarios según el tipo de logro
      String progressText = widget.initialProgressDescription;

      switch (widget.achievement.type) {
        case AchievementType.lactation:
          if (widget.achievement.id.startsWith('milestone_') ||
              widget.achievement.id.startsWith('complete_')) {
            // Solo necesitamos el total de registros
            final localDb = LactationDatabase();
            final allRecords = await localDb.getAllRecords();
            final totalRecords = allRecords.length;
            final completeRecords = allRecords
                .where((r) => r.vecesPecho > 0 || r.vecesBiberon > 0)
                .length;

            if (widget.achievement.id.startsWith('milestone_')) {
              progressText =
                  '$totalRecords/${widget.achievement.requiredValue} registros de lactancia en total.';
            } else {
              progressText =
                  '$completeRecords/${widget.achievement.requiredValue} registros completos (con todos los detalles).';
            }
          } else if (widget.achievement.id.startsWith('daily_')) {
            // Solo necesitamos los registros de hoy
            final today = DateTime.now();
            final lactationService = getIt<LactationService>();
            final todayRecords = await lactationService.getRecordsForDate(
              today,
            );
            progressText =
                '${todayRecords.length}/${widget.achievement.requiredValue} registros en un solo día.';
          } else if (widget.achievement.id == 'nocturnal_10') {
            // Solo necesitamos registros nocturnos
            final localDb = LactationDatabase();
            final allRecords = await localDb.getAllRecords();
            final nocturnalRecords = allRecords.where((r) {
              final hour = r.timestamp.hour;
              return hour >= 0 && hour < 6;
            }).length;
            progressText =
                '$nocturnalRecords/10 registros entre las 12am y las 6am.';
          }
          break;

        case AchievementType.lesson:
          if (widget.achievement.id == 'trivia_perfect_5') {
            // TODO: Implementar lógica para trivias perfectas
            // Por ahora, usar descripción por defecto
          } else {
            // Solo necesitamos lecciones completadas
            final lessonRepo = getIt<LessonRepositoryImpl>();
            final lessonsResult = await lessonRepo.getAllLessons();
            lessonsResult.fold((failure) => null, (lessons) {
              final completed = lessons.where((l) => l.isCompleted).length;
              progressText =
                  '$completed/${widget.achievement.requiredValue} lecciones completadas.';
            });
          }
          break;

        case AchievementType.streak:
          // Los logros de racha no necesitan estadísticas adicionales
          break;

        case AchievementType.special:
          if (widget.achievement.id == 'weight_10') {
            // Solo necesitamos registros de peso
            final weightDataSource = getIt<BabyWeightOfflineLocalDataSource>();
            final weightRecords = await weightDataSource.getAllRecords();
            progressText =
                '${weightRecords.length}/${widget.achievement.requiredValue} registros de peso del bebé.';
          } else if (widget.achievement.id == 'sleep_20') {
            // Solo necesitamos registros de sueño
            final sleepDataSource = getIt<SleepOfflineLocalDataSource>();
            final sleepRecords = await sleepDataSource.getAllRecords();
            progressText =
                '${sleepRecords.length}/${widget.achievement.requiredValue} registros de sueño del bebé.';
          } else if (widget.achievement.id.startsWith('first_') ||
              widget.achievement.id.startsWith('three_') ||
              widget.achievement.id.startsWith('six_')) {
            // Solo necesitamos días usando la app
            final daysUsingApp = DateTime.now()
                .difference(widget.profile.createdAt)
                .inDays;
            progressText =
                '$daysUsingApp/${widget.achievement.requiredValue} días usando la app.';
          }
          break;
      }

      if (mounted) {
        setState(() {
          _progressDescription = progressText;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          // Mantener descripción inicial si falla
        });
      }
    }
  }

  // Método no usado - mantenido para uso futuro
  // ignore: unused_element
  String? _getUserId() {
    try {
      final userState = context.read<UserProfileBloc>().state;
      if (userState is UserProfileLoaded) {
        return userState.profile.id;
      } else if (userState is UserProfileUpdated) {
        return userState.profile.id;
      }
    } catch (e) {
      // Ignorar errores
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: widget.isAssetPath
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      widget.achievement.icon,
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
                      widget.achievement.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            widget.achievement.title,
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
            widget.achievement.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          // Si está bloqueado, mostrar objetivos
          if (!widget.isUnlocked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Objetivos para desbloquear:',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Mostrar descripción inicial, luego actualizar con estadísticas reales
                  if (_isLoadingStats)
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cargando progreso...',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _progressDescription.isNotEmpty
                          ? _progressDescription
                          : widget.initialProgressDescription,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Recompensa XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isUnlocked ? Colors.amber[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: widget.isUnlocked
                      ? Colors.amber[800]
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${widget.achievement.xpReward} XP',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isUnlocked
                        ? Colors.amber[800]
                        : Colors.grey[600],
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: Colors.amber[700],
            ),
            child: Text(
              'gamification.messages.great'.tr(),
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
