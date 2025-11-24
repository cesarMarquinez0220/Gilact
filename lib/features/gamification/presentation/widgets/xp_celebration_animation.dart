import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget que muestra una animación de celebración cuando se gana XP
class XPCelebrationAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onComplete;
  final bool showStars;

  const XPCelebrationAnimation({
    super.key,
    required this.xpAmount,
    this.onComplete,
    this.showStars = true,
  });

  /// Muestra la animación como overlay
  static void show(
    BuildContext context,
    int xpAmount, {
    VoidCallback? onComplete,
    bool withVibration = true,
    bool showStars = true, // Control para mostrar estrellitas
  }) {
    // Log de debug
    debugPrint(
      '⭐ XPCelebrationAnimation.show: xpAmount=$xpAmount, showStars=$showStars',
    );

    // Vibración al mostrar
    if (withVibration) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    }

    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        debugPrint('⭐ XPCelebrationAnimation: Construyendo widget en overlay');
        return XPCelebrationAnimation(
          xpAmount: xpAmount,
          showStars: showStars,
          onComplete: () {
            overlayEntry.remove();
            onComplete?.call();
          },
        );
      },
    );

    overlay.insert(overlayEntry);
    debugPrint('⭐ XPCelebrationAnimation: Overlay insertado');

    // Remover automáticamente después de 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        onComplete?.call();
      }
    });
  }

  @override
  State<XPCelebrationAnimation> createState() => _XPCelebrationAnimationState();
}

class _XPCelebrationAnimationState extends State<XPCelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _starsController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _starsAnimation;

  // Lista de estrellitas con posiciones y animaciones
  final List<_StarParticle> _stars = [];

  @override
  void initState() {
    super.initState();

    debugPrint(
      '⭐ XPCelebrationAnimation.initState: showStars=${widget.showStars}, xpAmount=${widget.xpAmount}',
    );

    // Controlador principal para el contenedor de XP
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controlador para las estrellitas (más largo para mejor visibilidad)
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _starsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _starsController, curve: Curves.easeOut));

    // Crear estrellitas con posiciones aleatorias
    _generateStars();
    debugPrint(
      '⭐ XPCelebrationAnimation: Generadas ${_stars.length} estrellitas',
    );

    _mainController.forward();
    debugPrint('⭐ XPCelebrationAnimation: Controlador principal iniciado');

    // Iniciar las estrellitas después de un pequeño delay (solo si showStars es true)
    if (widget.showStars) {
      debugPrint(
        '⭐ XPCelebrationAnimation: Iniciando animación de estrellitas...',
      );
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _starsController.forward();
          debugPrint(
            '⭐ XPCelebrationAnimation: Controlador de estrellitas iniciado',
          );
        } else {
          debugPrint(
            '⚠️ XPCelebrationAnimation: Widget no montado, no se puede iniciar estrellitas',
          );
        }
      });
    } else {
      debugPrint(
        '⭐ XPCelebrationAnimation: showStars=false, no se mostrarán estrellitas',
      );
    }
  }

  void _generateStars() {
    _stars.clear();
    // Crear más estrellitas (20) para un efecto más impactante
    for (int i = 0; i < 20; i++) {
      // Ángulos distribuidos en un arco desde abajo hacia arriba y los lados
      // -90 grados es hacia abajo, distribuimos desde -135° hasta -45° (arco de 90°)
      // y también hacia los lados (0° y 180°)
      double angle;
      if (i < 8) {
        // Estrellitas hacia arriba (arco principal)
        angle = (-135 + (i * 30)) * (3.14159 / 180);
      } else if (i < 14) {
        // Estrellitas hacia los lados izquierdo
        angle = (-180 + ((i - 8) * 15)) * (3.14159 / 180);
      } else {
        // Estrellitas hacia los lados derecho
        angle = ((i - 14) * 15) * (3.14159 / 180);
      }

      final distance = 150.0 + (i % 4) * 40.0; // Distancia variable más grande
      _stars.add(
        _StarParticle(
          angle: angle,
          distance: distance,
          size: 16.0 + (i % 4) * 6.0, // Tamaño más grande
          delay: i * 30, // Delay escalonado más rápido
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Estrellitas que salen volando (solo si showStars es true)
                if (widget.showStars)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _starsAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _StarsPainter(
                            stars: _stars,
                            progress: _starsAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                // Contenedor principal de XP
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Contenedor principal con gradiente
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF03A696),
                                    Color(0xFF26A69A),
                                    Color(0xFF4DB6AC),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icono de estrella animado
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 600),
                                    builder: (context, value, child) {
                                      return Transform.rotate(
                                        angle: value * 2 * 3.14159,
                                        child: Transform.scale(
                                          scale: 0.5 + (value * 0.5),
                                          child: const Icon(
                                            Icons.star_rounded,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  // Texto de XP
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '+${widget.xpAmount}',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.0,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Text(
                                        'XP Ganados',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Mensaje de felicitación
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 300),
                              child: Text(
                                '¡Excelente trabajo!',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clase para representar una partícula de estrella
class _StarParticle {
  final double angle;
  final double distance;
  final double size;
  final int delay;

  _StarParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

/// CustomPainter para dibujar las estrellitas que salen volando
class _StarsPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double progress;

  _StarsPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Punto de origen: centro horizontal, 70% desde arriba (cerca del botón de XP en el diálogo)
    final startPoint = Offset(size.width / 2, size.height * 0.7);

    for (final star in stars) {
      // Calcular el progreso de esta estrella (con delay en milisegundos)
      // progress va de 0 a 1, lo convertimos a milisegundos (0-2000ms)
      final totalTime = progress * 2000;
      final adjustedTime = totalTime - star.delay;

      // Si aún no ha comenzado o ya terminó, saltar
      if (adjustedTime < 0) continue;

      // Duración de animación para esta estrella (2000ms - delay)
      final starDuration = 2000 - star.delay;
      if (starDuration <= 0) continue;

      final starProgress = math.min(1.0, adjustedTime / starDuration);
      if (starProgress > 1 || starProgress < 0) continue;

      // Usar una curva más suave para el movimiento (easeOut para aceleración inicial)
      final easedProgress = 1 - math.pow(1 - starProgress, 3).toDouble();

      // Calcular posición actual (desde el punto de inicio)
      final currentDistance = star.distance * easedProgress;
      final x = startPoint.dx + currentDistance * math.cos(star.angle);
      final y = startPoint.dy + currentDistance * math.sin(star.angle);

      // Calcular opacidad (aparece rápido, desaparece suavemente)
      final opacity = starProgress < 0.2
          ? starProgress /
                0.2 // Aparece en los primeros 20%
          : starProgress < 0.8
          ? 1.0 // Mantiene opacidad completa
          : 1.0 - ((starProgress - 0.8) / 0.2); // Desaparece en los últimos 20%

      // Calcular escala (crece rápido, luego se mantiene, luego se reduce)
      final scale = starProgress < 0.2
          ? 0.3 +
                (starProgress / 0.2) *
                    0.7 // Crece de 0.3 a 1.0
          : starProgress < 0.7
          ? 1.0 // Mantiene tamaño completo
          : 1.0 - ((starProgress - 0.7) / 0.3) * 0.4; // Se reduce ligeramente

      if (opacity <= 0 || scale <= 0) continue;

      // Dibujar estrella con brillo
      final starSize = star.size * scale;

      // Brillo exterior (más grande y semi-transparente)
      final outerGlowPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.2)
        ..style = PaintingStyle.fill;

      // Brillo medio
      final midGlowPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.fill;

      // Estrella principal (blanca brillante)
      final mainPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Dibujar brillos desde afuera hacia adentro para efecto de resplandor
      _drawStar(canvas, Offset(x, y), starSize * 2.0, outerGlowPaint);
      _drawStar(canvas, Offset(x, y), starSize * 1.5, midGlowPaint);
      _drawStar(canvas, Offset(x, y), starSize, mainPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    if (size <= 0) return;

    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final spikes = 5;

    for (int i = 0; i < spikes * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.14159) / spikes - 3.14159 / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Agregar un pequeño círculo brillante en el centro para más visibilidad
    if (size > 5) {
      final centerPaint = Paint()
        ..color = paint.color.withOpacity(
          math.min(1.0, paint.color.opacity * 1.3),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size * 0.15, centerPaint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
