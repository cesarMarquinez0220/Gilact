import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/user_gamification_profile.dart';

/// Widget mejorado que muestra el muñequito animado con información de gamificación
/// Estados: happy, celebrating, thinking, worried, supporting, sleeping
class MascotWidget extends StatelessWidget {
  final UserGamificationProfile profile;
  final double size;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    required this.profile,
    this.size = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String animationPath;
    String message;
    Color messageColor;
    Color cardGradientStart;
    Color cardGradientEnd;

    switch (profile.mascotState) {
      case 'celebrating':
        animationPath = 'assets/animations/Happy_Dog.json';
        message = '¡Excelente trabajo! 🎉';
        messageColor = const Color(0xFFE74C3C);
        cardGradientStart = const Color(0xFFFFE5E5);
        cardGradientEnd = Colors.white;
        break;
      case 'thinking':
        animationPath = 'assets/animations/Happy_Dog.json';
        message = 'Estás muy cerca de subir de nivel';
        messageColor = const Color(0xFF3498DB);
        cardGradientStart = const Color(0xFFE3F2FD);
        cardGradientEnd = Colors.white;
        break;
      case 'worried':
        animationPath = 'assets/animations/Happy_Dog.json';
        message =
            'Tu racha está en riesgo, pero puedes usar un día de descanso';
        messageColor = const Color(0xFFF39C12);
        cardGradientStart = const Color(0xFFFFF3E0);
        cardGradientEnd = Colors.white;
        break;
      case 'supporting':
        animationPath = 'assets/animations/Happy_Dog.json';
        message = 'Tómate el tiempo que necesites, estaremos aquí 💙';
        messageColor = const Color(0xFF3498DB);
        cardGradientStart = const Color(0xFFE3F2FD);
        cardGradientEnd = Colors.white;
        break;
      case 'sleeping':
        animationPath = 'assets/animations/Happy_Dog.json';
        message = 'Descansa bien, te esperamos mañana';
        messageColor = Colors.grey;
        cardGradientStart = const Color(0xFFF5F5F5);
        cardGradientEnd = Colors.white;
        break;
      case 'happy':
      default:
        animationPath = 'assets/animations/Happy_Dog.json';
        message = '¡Hola! ¿Cómo estás hoy?';
        messageColor = const Color(0xFF2ECC71);
        cardGradientStart = const Color(0xFFE8F5E9);
        cardGradientEnd = Colors.white;
        break;
    }

    // Calcular progreso del nivel
    final levelProgress = profile.nextLevelXP > 0
        ? profile.currentLevelXP / profile.nextLevelXP
        : 0.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardGradientStart, cardGradientEnd],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: messageColor.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Icono decorativo en esquina superior derecha
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: messageColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStateIcon(profile.mascotState),
                    color: messageColor,
                    size: 18,
                  ),
                ),
              ),

              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animación de la mascota
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: messageColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          animationPath,
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mensaje del estado
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: messageColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Información de nivel y XP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Nivel
                        _buildStatItem(
                          icon: Icons.star,
                          label: 'Nivel',
                          value: '${profile.currentLevel}',
                          color: messageColor,
                        ),

                        // Racha
                        if (profile.currentStreak > 0)
                          _buildStatItem(
                            icon: Icons.local_fire_department,
                            label: 'Racha',
                            value: '${profile.currentStreak}',
                            color: const Color(0xFFFF6B35),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Barra de progreso del nivel
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso al nivel ${profile.currentLevel + 1}',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              '${profile.currentLevelXP}/${profile.nextLevelXP} XP',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: messageColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: levelProgress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              messageColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Badges recientes (si hay)
                    if (profile.unlockedAchievements.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.unlockedAchievements.length} logros',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un item de estadística
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  /// Obtiene el icono según el estado de la mascota
  IconData _getStateIcon(String state) {
    switch (state) {
      case 'celebrating':
        return Icons.celebration;
      case 'thinking':
        return Icons.lightbulb;
      case 'worried':
        return Icons.warning_amber;
      case 'supporting':
        return Icons.favorite;
      case 'sleeping':
        return Icons.bedtime;
      case 'happy':
      default:
        return Icons.mood;
    }
  }
}
