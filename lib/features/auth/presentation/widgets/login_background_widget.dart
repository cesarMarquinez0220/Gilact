import 'package:flutter/material.dart';

class LoginBackgroundWidget extends StatelessWidget {
  final AnimationController? pulseController;
  final Animation<double>? pulseAnimation;

  const LoginBackgroundWidget({
    super.key,
    this.pulseController,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Círculos decorativos animados más grandes y suaves
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation?.value ?? 1.0,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF2C5F5D,
                        ).withOpacity(0.15), // Azul teal oscuro (secundario)
                        const Color(
                          0xFF2C5F5D,
                        ).withOpacity(0.05), // Azul teal oscuro (secundario)
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -120,
          left: -120,
          child: AnimatedBuilder(
            animation: pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: (pulseAnimation?.value ?? 1.0) * 0.7,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4FD1C7).withOpacity(
                          0.1,
                        ), // Verde azulado medio vibrante (primario)
                        const Color(0xFF4FD1C7).withOpacity(
                          0.03,
                        ), // Verde azulado medio vibrante (primario)
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Elementos decorativos adicionales
        Positioned(
          top: 150,
          right: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFFE2E8F0,
                  ).withOpacity(0.08), // Gris muy claro (secundario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 60,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFFB794F6,
                  ).withOpacity(0.06), // Lavanda suave (primario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Patrón de puntos decorativos mejorado
        Positioned(
          top: 120,
          right: 30,
          child: Container(
            width: 80,
            height: 80,
            child: CustomPaint(painter: DotsPainter()),
          ),
        ),
        // Líneas decorativas sutiles
        Positioned(
          top: 300,
          left: 20,
          child: Container(
            width: 2,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(
                    0xFF4FD1C7,
                  ).withOpacity(0.1), // Verde azulado medio vibrante (primario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
          .withOpacity(0.4) // Gris muy claro (secundario)
      ..style = PaintingStyle.fill;

    // Crear un patrón de puntos más elegante
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final x = i * 20.0;
        final y = j * 20.0;
        final radius = (i + j) % 2 == 0 ? 2.5 : 1.5;

        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Agregar algunos puntos más pequeños para mayor detalle
    final smallPaint = Paint()
      ..color = const Color(0xFF4FD1C7)
          .withOpacity(0.2) // Verde azulado medio vibrante (primario)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = i * 25.0 + 10.0;
        final y = j * 25.0 + 10.0;
        canvas.drawCircle(Offset(x, y), 1.0, smallPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
