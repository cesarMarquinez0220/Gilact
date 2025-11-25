import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../../gamification/domain/entities/user_gamification_profile.dart';

/// Widget wrapper que agrega interactividad a la mascota
class CompanionMascotWrapper extends StatefulWidget {
  final UserGamificationProfile profile;
  final double size;

  const CompanionMascotWrapper({
    required this.profile,
    required this.size,
    super.key,
  });

  @override
  State<CompanionMascotWrapper> createState() => _CompanionMascotWrapperState();
}

class _CompanionMascotWrapperState extends State<CompanionMascotWrapper>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  String? _currentMessage;

  // Mensajes rotativos para la mascota (se traducirán dinámicamente)
  List<String> get _messages => [
    'gamification.messages.helloHowAreYou'.tr(),
    'companion.mascotMessages.keepGoing'.tr(),
    'companion.mascotMessages.everyRecordCounts'.tr(),
    'companion.mascotMessages.yourWellbeing'.tr(),
    'companion.mascotMessages.youAreAdvancing'.tr(),
    'companion.mascotMessages.takeYourTime'.tr(),
    'companion.mascotMessages.youAreSuperMom'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    // Controlador para animación de escala de la mascota
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Vibración suave
    HapticFeedback.lightImpact();

    // Animación de escala de la mascota
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Mostrar mensaje rotativo
    setState(() {
      _tapCount = (_tapCount + 1) % _messages.length;
      _currentMessage = _messages[_tapCount];
    });

    // Ocultar el mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener mensaje por defecto según el estado
    String defaultMessage;
    switch (widget.profile.mascotState) {
      case 'celebrating':
        defaultMessage = 'gamification.messages.excellentWork'.tr();
        break;
      case 'thinking':
        defaultMessage = 'gamification.messages.closeToLevelUp'.tr();
        break;
      case 'worried':
        defaultMessage = 'gamification.messages.streakAtRisk'.tr();
        break;
      case 'supporting':
        defaultMessage = 'gamification.messages.takeYourTime'.tr();
        break;
      case 'sleeping':
        defaultMessage = 'gamification.messages.restWell'.tr();
        break;
      case 'happy':
      default:
        defaultMessage = 'gamification.messages.helloHowAreYou'.tr();
        break;
    }

    final messageToShow = _currentMessage ?? defaultMessage;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. LA MASCOTA (centrada, ligeramente más abajo)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  child: Lottie.asset(
                    'assets/animations/Happy_Dog.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
              ),
            ),
            // 2. LA BURBUJA (posición fija arriba y a la derecha de la mascota)
            if (messageToShow.isNotEmpty)
              Positioned(
                top: -20,
                left: widget.size * 0.3,
                child: ZoomIn(
                  key: ValueKey(messageToShow),
                  duration: const Duration(milliseconds: 600),
                  child: CompanionSpeechBubble(message: messageToShow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget de burbuja de mensaje estilo cómic
class CompanionSpeechBubble extends StatelessWidget {
  final String message;

  const CompanionSpeechBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    // Calcular el tamaño dinámico basado en el contenido del mensaje
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
          height: 1.3,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: 200);

    // El ancho se ajusta dinámicamente al contenido, con límites
    final dynamicWidth = (textPainter.width + 32).clamp(120.0, 220.0);

    return CustomPaint(
      painter: _SpeechBubblePainter(),
      child: Container(
        width: dynamicWidth,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Painter para dibujar la burbuja con triángulo
class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Dibujar el cuerpo principal de la burbuja
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 12),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);

    // Dibujar el triángulo apuntando hacia abajo-izquierda
    final trianglePath = Path();
    final triangleWidth = 18.0;
    final triangleX = 25.0;
    final bottomY = size.height;

    trianglePath.moveTo(triangleX, size.height - 12);
    trianglePath.lineTo(triangleX + triangleWidth / 2, bottomY);
    trianglePath.lineTo(triangleX + triangleWidth, size.height - 12);
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
    canvas.drawPath(trianglePath, borderPaint);

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 4, size.width, size.height - 12),
        const Radius.circular(20),
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
