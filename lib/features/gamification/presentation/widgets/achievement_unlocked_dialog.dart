import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../../domain/entities/achievement.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/di/injection.dart';

/// Diálogo que muestra cuando se desbloquea un logro
class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;
  final int xpReward;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.xpReward,
  });

  @override
  State<AchievementUnlockedDialog> createState() =>
      _AchievementUnlockedDialogState();

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
      // Usar vibración tipo Duolingo que funciona incluso en modo silencio
      // Ejecutar de forma asíncrona sin bloquear
      vibrationService.vibrateOnAchievementDuolingoStyle().catchError((error) {
        // Si falla, usar el método de fallback
        vibrationService.vibrateOnAchievement();
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.7,
      ), // Fondo oscuro semitransparente
      builder: (context) => AchievementUnlockedDialog(
        achievement: achievement,
        xpReward: xpReward,
      ),
    );
  }
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Iniciar confeti después de un pequeño delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Confeti en toda la pantalla (detrás del diálogo)
        // Múltiples emisores distribuidos a lo largo de la parte superior
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: List.generate(5, (index) {
                // Distribuir emisores a lo largo del ancho de la pantalla
                final position = (screenWidth / 6) * (index + 1);
                return Positioned(
                  top: 0,
                  left: position - 50, // Centrar cada emisor
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: math.pi / 2, // Hacia abajo
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 8,
                    gravity: 0.1,
                    colors: const [
                      Colors.amber,
                      Colors.orange,
                      Colors.yellow,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.green,
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        // Diálogo centrado
        Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3498DB), Color(0xFF2ECC71)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                ],
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
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(80),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Efecto de brillo "Sunburst" girando (más visible y mágico)
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * math.pi,
                                child: Opacity(
                                  opacity:
                                      0.25, // Aumentado de 0.1 a 0.25 para más visibilidad
                                  child: CustomPaint(
                                    size: const Size(160, 160),
                                    painter: _SunburstPainter(),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Badge/Icono
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: widget.achievement.icon.startsWith('assets/')
                                ? Image.asset(
                                    widget.achievement.icon,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.emoji_events,
                                        size: 100,
                                        color: Colors.amber[700],
                                      );
                                    },
                                  )
                                : Text(
                                    widget.achievement.icon,
                                    style: const TextStyle(fontSize: 80),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      widget.achievement.title,
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
                      widget.achievement.description,
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
                            '+${widget.xpReward} XP',
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
          ),
        ),
      ],
    );
  }
}

/// Painter para el efecto de brillo "Sunburst" mejorado y más mágico
class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Capa 1: Gradiente radial central más intenso y mágico
    final centralGradient = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.6), // Más brillante en el centro
          Colors.orange.withValues(alpha: 0.5),
          Colors.yellow.withValues(alpha: 0.4),
          Colors.orange.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Capa 2: Rayos principales brillantes (20 rayos para más densidad)
    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2) / 20;
      final startRadius = radius * 0.4; // Más cerca del centro
      final endRadius = radius * 0.98; // Hasta el borde

      final startX = center.dx + math.cos(angle) * startRadius;
      final startY = center.dy + math.sin(angle) * startRadius;
      final endX = center.dx + math.cos(angle) * endRadius;
      final endY = center.dy + math.sin(angle) * endRadius;

      // Rayos principales con gradiente de color (más brillante en el centro)
      final rayRect = Rect.fromPoints(
        Offset(startX, startY),
        Offset(endX, endY),
      );

      final rayGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.amber.withValues(alpha: 0.5),
          Colors.orange.withValues(alpha: 0.4),
          Colors.yellow.withValues(alpha: 0.2),
        ],
      );

      final rayPaint = Paint()
        ..shader = rayGradient.createShader(rayRect)
        ..strokeWidth =
            5 // Más gruesos
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }

    // Capa 3: Rayos secundarios más sutiles entre los principales
    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2) / 20;
      final secondaryAngle = angle + (math.pi / 20);
      final startRadius = radius * 0.45;
      final endRadius = radius * 0.92;

      final secStartX = center.dx + math.cos(secondaryAngle) * startRadius;
      final secStartY = center.dy + math.sin(secondaryAngle) * startRadius;
      final secEndX = center.dx + math.cos(secondaryAngle) * endRadius;
      final secEndY = center.dy + math.sin(secondaryAngle) * endRadius;

      final secondaryRayPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.25)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(secStartX, secStartY),
        Offset(secEndX, secEndY),
        secondaryRayPaint,
      );
    }

    // Capa 4: Círculo central brillante con gradiente mejorado
    canvas.drawCircle(center, radius * 0.35, centralGradient);

    // Capa 5: Anillos concéntricos brillantes para profundidad
    for (int i = 1; i <= 3; i++) {
      final ringRadius = radius * (0.5 + (i * 0.15));
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.amber
            .withValues(alpha: 0.2 / i) // Más sutil hacia afuera
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Capa 6: Círculo exterior brillante con gradiente
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.2),
          Colors.orange.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.95, outerRingPaint);

    // Capa 7: Puntos brillantes en los extremos de los rayos principales
    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2) / 20;
      final pointX = center.dx + math.cos(angle) * radius * 0.95;
      final pointY = center.dy + math.sin(angle) * radius * 0.95;

      final pointPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pointX, pointY), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
