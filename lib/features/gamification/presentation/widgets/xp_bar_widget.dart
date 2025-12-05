import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/services/level_service.dart';

/// Widget que muestra la barra de XP y nivel del usuario
class XPBarWidget extends StatelessWidget {
  final UserGamificationProfile profile;
  final LevelService _levelService = LevelService();

  XPBarWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final progress = profile.levelProgress;
    final tierEmoji = _levelService.getLevelTierEmoji(profile.currentLevel);
    final tierNameKey = _levelService.getLevelTier(profile.currentLevel);
    final tierName = tierNameKey.tr();

    // Obtener el badge del nivel (mapear a los badges disponibles)
    String levelBadgePath;
    if (profile.currentLevel >= 20) {
      levelBadgePath = 'assets/images/badges/badge_level_20.png';
    } else if (profile.currentLevel >= 15) {
      levelBadgePath = 'assets/images/badges/badge_level_15.png';
    } else if (profile.currentLevel >= 10) {
      levelBadgePath = 'assets/images/badges/badge_level_10.png';
    } else if (profile.currentLevel >= 5) {
      levelBadgePath = 'assets/images/badges/badge_level_5.png';
    } else if (profile.currentLevel >= 3) {
      levelBadgePath = 'assets/images/badges/badge_level_3.png';
    } else {
      levelBadgePath = 'assets/images/badges/badge_level_1.png';
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      levelBadgePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            tierEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'gamification.level'.tr()} ${profile.currentLevel}',
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
                    '${profile.currentLevelXP} XP',
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
