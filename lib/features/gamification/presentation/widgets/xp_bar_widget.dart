import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/services/level_service.dart';

/// Widget que muestra la barra de XP y nivel del usuario
class XPBarWidget extends StatelessWidget {
  final UserGamificationProfile profile;
  final LevelService _levelService = LevelService();

   XPBarWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final progress = profile.levelProgress;
    final tierEmoji = _levelService.getLevelTierEmoji(profile.currentLevel);
    final tierName = _levelService.getLevelTier(profile.currentLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    tierEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel ${profile.currentLevel}',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        tierName,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.totalXP} XP',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3498DB),
                    ),
                  ),
                  Text(
                    '${profile.currentLevelXP}/${profile.nextLevelXP}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: Colors.grey[200]!,
            progressColor: const Color(0xFF3498DB),
            barRadius: const Radius.circular(4),
            animation: true,
            animationDuration: 500,
          ),
        ],
      ),
    );
  }
}

