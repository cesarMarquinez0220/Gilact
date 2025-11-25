import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../gamification/domain/entities/daily_challenge.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/domain/services/gamification_service.dart';
import '../../../gamification/presentation/widgets/xp_celebration_animation.dart';
import '../../../../core/di/injection.dart';

/// Sección de desafío diario de la página de compañera
class CompanionDailyChallengeSection extends StatelessWidget {
  final UserGamificationProfile profile;
  final DailyChallenge challenge;
  final String userId;

  const CompanionDailyChallengeSection({
    required this.profile,
    required this.challenge,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.isDone;
    final progress = challenge.progressPercentage;

    // Verificar si ya se otorgó XP hoy para este desafío
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final completedDate = profile.completedDailyChallenges[challenge.id];
    final wasCompletedToday =
        completedDate != null &&
        completedDate.year == todayStart.year &&
        completedDate.month == todayStart.month &&
        completedDate.day == todayStart.day;

    // Si se completó pero no se otorgó XP hoy, otorgarlo
    if (isCompleted && !wasCompletedToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _awardDailyChallengeXP(context, userId, challenge);
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [Colors.green[50]!, Colors.green[100]!]
              : [Colors.amber[50]!, Colors.amber[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green[300]! : Colors.amber[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[200] : Colors.amber[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    challenge.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'companion.dailyChallenge'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      challenge.title,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'companion.completed'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Descripción
          Text(
            challenge.description,
            style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'companion.progress'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${challenge.progress}/${challenge.requiredValue}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.green[700]
                          : Colors.amber[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green[400]! : Colors.amber[600]!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Recompensa XP
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  isCompleted
                      ? 'companion.youWonXP'.tr(
                          namedArgs: {'xp': challenge.xpReward.toString()},
                        )
                      : 'companion.reward'.tr() + ': ${challenge.xpReward} XP',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Otorga XP por completar un desafío diario
  Future<void> _awardDailyChallengeXP(
    BuildContext context,
    String userId,
    DailyChallenge challenge,
  ) async {
    try {
      final gamificationService = getIt<GamificationService>();
      final result = await gamificationService.addXPForDailyChallenge(
        userId: userId,
        challengeId: challenge.id,
        xpReward: challenge.xpReward,
        timestamp: DateTime.now(),
      );

      result.fold(
        (error) {
          if (kDebugMode) {
            print('❌ Error otorgando XP por desafío: $error');
          }
        },
        (updatedProfile) {
          // Actualizar el BLoC con el nuevo perfil
          context.read<GamificationBloc>().add(
            UpdateGamificationProfile(updatedProfile),
          );

          // Mostrar animación de XP
          if (context.mounted) {
            XPCelebrationAnimation.show(
              context,
              challenge.xpReward,
              showStars: true,
            );
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Excepción otorgando XP por desafío: $e');
      }
    }
  }
}
