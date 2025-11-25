import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/achievement.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/di/injection.dart';

/// Diálogo que muestra cuando se desbloquea un logro
class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  final int xpReward;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.xpReward,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3498DB), Color(0xFF2ECC71)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                '🎉 ¡Logro Desbloqueado!',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: achievement.icon.startsWith('assets/')
                      ? Image.asset(
                          achievement.icon,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 50),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 400),
              child: Text(
                achievement.title,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 500),
              child: Text(
                achievement.description,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '+$xpReward XP',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 700),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'gamification.messages.great'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra el diálogo
  static void show(
    BuildContext context,
    Achievement achievement,
    int xpReward, {
    bool withVibration = true,
  }) {
    // Vibración y sonido de éxito al mostrar el logro (usando servicios)
    if (withVibration) {
      final SoundService soundService = getIt<SoundService>();
      final VibrationService vibrationService = getIt<VibrationService>();
      soundService.playAchievementSound(); // Usar sonido específico de logro
      vibrationService
          .vibrateOnAchievement(); // Usar vibración especial para logros
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockedDialog(
        achievement: achievement,
        xpReward: xpReward,
      ),
    );
  }
}
