import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';

/// Resumen de estadísticas de la página de compañera
class CompanionStatsSummary extends StatelessWidget {
  final UserGamificationProfile profile;

  const CompanionStatsSummary({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'companion.summary'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'companion.totalXP'.tr(),
                value: '${profile.totalXP}',
              ),
              _StatItem(
                label: 'companion.level'.tr(),
                value: '${profile.currentLevel}',
              ),
              _StatItem(
                label: 'companion.streak'.tr(),
                value: '${profile.currentStreak} ${'companion.days'.tr()}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
