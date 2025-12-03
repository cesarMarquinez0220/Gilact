import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  /// Retorna un Future que se completa cuando el diálogo se cierra
  static Future<void> show(
    BuildContext context,
    Achievement achievement,
    int xpReward, {
    bool withVibration = true,
  }) async {
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

    await showDialog(
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
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

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

    // Controlador para la animación de escala del card completo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Animación de escala con curva elástica (de pequeño a grande)
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Iniciar animación de escala
    _scaleController.forward();

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
    _scaleController.dispose();
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
        // Diálogo centrado con animación de escala
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
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
                        Text(
                          '🎉 ¡Logro Desbloqueado!',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(110),
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
                              // Efecto de brillo "Sunburst" girando (estilo Clash Royale elegante)
                              AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _rotationController.value * 2 * math.pi,
                                    child: Opacity(
                                      opacity:
                                          0.5, // Opacidad suave y agradable
                                      child: CustomPaint(
                                        size: const Size(220, 220),
                                        painter: _SunburstPainter(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Badge/Icono (imagen más grande, menos padding)
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Center(
                                  child:
                                      widget.achievement.icon.startsWith(
                                        'assets/',
                                      )
                                      ? Image.asset(
                                          widget.achievement.icon,
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.emoji_events,
                                                  size: 120,
                                                  color: Colors.amber[700],
                                                );
                                              },
                                        )
                                      : Text(
                                          widget.achievement.icon,
                                          style: const TextStyle(fontSize: 100),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.achievement.title.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.achievement.description.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
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
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
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
                        const SizedBox(height: 24),
                        ElevatedButton(
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Capa 1: Halo exterior suave (resplandor base sutil)
    final outerHaloGradient = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.08),
          Colors.yellow.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));
    canvas.drawCircle(center, radius * 1.05, outerHaloGradient);

    // Capa 2: Gradiente radial central suave (núcleo dorado)
    final centralGradient = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.6),
          Colors.amber.withValues(alpha: 0.5),
          Colors.orange.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.5));
    canvas.drawCircle(center, radius * 0.5, centralGradient);

    // Capa 3: Rayos principales con ancho variable (delgados al inicio, gruesos al final)
    // Estilo Clash Royale: empiezan pequeños y se expanden hacia afuera
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2) / 16;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.98;

      // Ancho del rayo: delgado al inicio, grueso al final
      const startWidth = 2.0; // Delgado al inicio
      const endWidth = 10.0; // Grueso al final

      // Calcular los puntos para formar un trapecio (rayo con ancho variable)
      // Necesitamos calcular el ángulo perpendicular para el ancho
      final perpAngle = angle + (math.pi / 2);

      // Puntos del inicio (cerca del centro) - más delgados
      final startX1 =
          center.dx +
          math.cos(angle) * startRadius +
          math.cos(perpAngle) * (startWidth / 2);
      final startY1 =
          center.dy +
          math.sin(angle) * startRadius +
          math.sin(perpAngle) * (startWidth / 2);
      final startX2 =
          center.dx +
          math.cos(angle) * startRadius +
          math.cos(perpAngle) * (-startWidth / 2);
      final startY2 =
          center.dy +
          math.sin(angle) * startRadius +
          math.sin(perpAngle) * (-startWidth / 2);

      // Puntos del final (cerca del borde) - más gruesos
      final endX1 =
          center.dx +
          math.cos(angle) * endRadius +
          math.cos(perpAngle) * (endWidth / 2);
      final endY1 =
          center.dy +
          math.sin(angle) * endRadius +
          math.sin(perpAngle) * (endWidth / 2);
      final endX2 =
          center.dx +
          math.cos(angle) * endRadius +
          math.cos(perpAngle) * (-endWidth / 2);
      final endY2 =
          center.dy +
          math.sin(angle) * endRadius +
          math.sin(perpAngle) * (-endWidth / 2);

      // Crear el path del trapecio (rayo con ancho variable)
      final rayPath = Path()
        ..moveTo(startX1, startY1)
        ..lineTo(endX1, endY1)
        ..lineTo(endX2, endY2)
        ..lineTo(startX2, startY2)
        ..close();

      // Rayos con gradiente suave desde el centro hacia afuera
      final rayGradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment(math.cos(angle).toDouble(), math.sin(angle).toDouble()),
        colors: [
          Colors.yellow.withValues(alpha: 0.7),
          Colors.amber.withValues(alpha: 0.6),
          Colors.orange.withValues(alpha: 0.4),
          Colors.orange.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final rayPaint = Paint()
        ..shader = rayGradient.createShader(
          Rect.fromPoints(Offset(startX1, startY1), Offset(endX2, endY2)),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(rayPath, rayPaint);
    }

    // Capa 4: Puntos blancos brillantes en el perímetro (como pequeñas luces)
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2) / 16;
      final pointX = center.dx + math.cos(angle) * radius * 0.96;
      final pointY = center.dy + math.sin(angle) * radius * 0.96;

      // Halo suave alrededor del punto
      final pointHaloPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pointX, pointY), 4, pointHaloPaint);

      // Punto central blanco brillante
      final pointPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pointX, pointY), 2.5, pointPaint);
    }

    // Capa 5: Anillo exterior sutil para definir el borde
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.98, outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
