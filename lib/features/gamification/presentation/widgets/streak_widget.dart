import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/entities/daily_streak.dart';

/// Widget que muestra la racha diaria del usuario
class StreakWidget extends StatelessWidget {
  final UserGamificationProfile profile;
  final DailyStreak? streak;
  final StreakService _streakService = StreakService();

   StreakWidget({
    super.key,
    required this.profile,
    this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final streakStatus = streak != null
        ? _streakService.checkStreakStatus(streak!)
        : StreakStatus.noActivity;
    final message = streak != null
        ? _streakService.getEmpatheticMessage(streakStatus, profile.currentStreak)
        : '¡Comienza tu primera racha hoy!';

    Color streakColor;
    IconData streakIcon;
    String streakEmoji;

    switch (streakStatus) {
      case StreakStatus.active:
        streakColor = const Color(0xFFE74C3C);
        streakIcon = Icons.local_fire_department;
        streakEmoji = '🔥';
        break;
      case StreakStatus.atRisk:
        streakColor = const Color(0xFFF39C12);
        streakIcon = Icons.warning_amber_rounded;
        streakEmoji = '⚠️';
        break;
      case StreakStatus.lost:
        streakColor = Colors.grey;
        streakIcon = Icons.refresh;
        streakEmoji = '💙';
        break;
      case StreakStatus.paused:
        streakColor = const Color(0xFF3498DB);
        streakIcon = Icons.pause_circle;
        streakEmoji = '⏸️';
        break;
      case StreakStatus.noActivity:
        streakColor = Colors.grey;
        streakIcon = Icons.local_fire_department_outlined;
        streakEmoji = '💤';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: streakColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                streakEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(streakIcon, color: streakColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Racha',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.currentStreak} días',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: streakColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (profile.canUseRestDay && !profile.isPauseModeActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${profile.restDaysAvailable} días\nde descanso',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  color: const Color(0xFF3498DB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

