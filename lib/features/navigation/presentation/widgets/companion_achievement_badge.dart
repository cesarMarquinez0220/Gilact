import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../gamification/domain/entities/achievement.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import 'companion_achievement_dialog.dart';

/// Badge individual de logro (interactivo)
class CompanionAchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final UserGamificationProfile profile;

  const CompanionAchievementBadge({
    required this.achievement,
    required this.isUnlocked,
    required this.profile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAssetPath = achievement.icon.startsWith('assets/');

    return GestureDetector(
      onTap: () => CompanionAchievementDialog.show(
        context,
        achievement,
        isUnlocked: isUnlocked,
        profile: profile,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.grey[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Contenido principal del badge con layout fijo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // Icono/Badge con tamaño y posición fijos
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: isAssetPath
                            ? Image.asset(
                                achievement.icon,
                                width: 40,
                                height: 40,
                                    fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.emoji_events,
                                        size: 32,
                                    color: isUnlocked
                                        ? Colors.amber[700]
                                        : Colors.grey[600],
                                  );
                                },
                              )
                                : Center(
                                    child: Text(
                                achievement.icon,
                                style: TextStyle(
                                        fontSize: 30,
                                        color: isUnlocked
                                            ? null
                                            : Colors.grey[600],
                                      ),
                                    ),
                                ),
                              ),
                      ),
                        const SizedBox(height: 4),
                        // Título centrado con altura fija
                        Flexible(
                        child: Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                              fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? const Color(0xFF2C3E50)
                                : Colors.grey[600],
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                      ),
                  ),
                  // Overlay de bloqueo si no está desbloqueado
                  if (!isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 24),
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
}
