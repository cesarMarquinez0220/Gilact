import 'package:flutter/material.dart';
import 'dart:math' as math;

class RegistrationBackgroundWidget extends StatelessWidget {
  final AnimationController pulseController;
  final Animation<double> pulseAnimation;

  const RegistrationBackgroundWidget({
    super.key,
    required this.pulseController,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: RegistrationBackgroundPainter(pulseAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class RegistrationBackgroundPainter extends CustomPainter {
  final double animationValue;

  RegistrationBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Círculos decorativos animados
    final circles = [
      {
        'center': Offset(size.width * 0.15, size.height * 0.2),
        'radius': 80.0 + (animationValue * 20),
        'color': const Color(0xFF4FD1C7).withOpacity(0.1),
      },
      {
        'center': Offset(size.width * 0.85, size.height * 0.3),
        'radius': 60.0 + (animationValue * 15),
        'color': const Color(0xFF1A365D).withOpacity(0.15),
      },
      {
        'center': Offset(size.width * 0.2, size.height * 0.7),
        'radius': 100.0 + (animationValue * 25),
        'color': const Color(0xFF2C5F5D).withOpacity(0.08),
      },
      {
        'center': Offset(size.width * 0.8, size.height * 0.8),
        'radius': 70.0 + (animationValue * 18),
        'color': const Color(0xFF4FD1C7).withOpacity(0.12),
      },
    ];

    for (final circle in circles) {
      paint.color = circle['color'] as Color;
      canvas.drawCircle(
        circle['center'] as Offset,
        circle['radius'] as double,
        paint,
      );
    }

    // Partículas flotantes
    paint.color = Colors.white.withOpacity(0.05);
    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i / 15.0) + animationValue * 50) % size.width;
      final y =
          size.height * 0.1 + (i * 60.0) + (animationValue * 30 * math.sin(i));

      final radius = 2.0 + (i % 3);
      paint.color = Colors.white.withOpacity(0.05 + (animationValue * 0.1));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Ondas decorativas
    paint.color = const Color(0xFF4FD1C7).withOpacity(0.03);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final center = Offset(size.width * 0.5, size.height * 0.5);
      final radius = 150.0 + (i * 50.0) + (animationValue * 20);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
