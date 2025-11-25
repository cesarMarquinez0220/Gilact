import 'package:flutter/material.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

class OnboardingSlideWidget extends StatefulWidget {
  final int slideIndex;
  final bool isLastSlide;

  const OnboardingSlideWidget({
    super.key,
    required this.slideIndex,
    required this.isLastSlide,
  });

  @override
  State<OnboardingSlideWidget> createState() => _OnboardingSlideWidgetState();
}

class _OnboardingSlideWidgetState extends State<OnboardingSlideWidget>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
    _particleController.repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoints mejorados para responsividad
    final isExtraSmall = screenHeight < 600;
    final isSmall = screenHeight < 700 && screenHeight >= 600;
    final isMedium = screenHeight < 800 && screenHeight >= 700;
    final isLarge = screenHeight >= 800;

    // Ajustar proporciones según el tamaño de pantalla
    final contentPadding = isExtraSmall ? 0.03 : 0.04;

    return Stack(
      children: [
        // Fondo con animación de partículas optimizada
        _buildParticleBackground(),

        // Contenido principal
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * contentPadding,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Imagen: más grande para mejor aprovechamiento del espacio
              SizedBox(
                width: screenWidth * 0.75, // Más ancha para mayor impacto
                height:
                    screenHeight *
                    0.35, // Más alta para llenar mejor el espacio
                child: _buildCompactIllustration(),
              ),

              SizedBox(
                height: screenHeight * 0.025,
              ), // Espacio reducido entre imagen y contenido
              // Contenido: centrado y con mejor espaciado
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: _buildCompactContent(
                    context,
                    isExtraSmall,
                    isSmall,
                    isMedium,
                    isLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCompactIllustration() {
    switch (widget.slideIndex) {
      case 0:
        return _buildFirstSlideIllustration();
      case 1:
        return _buildSecondSlideIllustration();
      case 2:
        return _buildThirdSlideIllustration();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFirstSlideIllustration() {
    return Image.asset(
      'assets/images/mother.png',
      fit: BoxFit.contain, // Cambiado para evitar recortes
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.family_restroom,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildSecondSlideIllustration() {
    return Image.asset(
      'assets/images/mother2.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.child_care, size: 60, color: Colors.white),
        );
      },
    );
  }

  Widget _buildThirdSlideIllustration() {
    return Image.asset(
      'assets/images/mother3.png',
      fit: BoxFit.contain, // Cambiado para evitar recortes
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.health_and_safety,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
    bool isLarge,
  ) {
    switch (widget.slideIndex) {
      case 0:
        return _buildFirstSlideContent(
          context,
          isExtraSmall,
          isSmall,
          isMedium,
          isLarge,
        );
      case 1:
        return _buildSecondSlideContent(
          context,
          isExtraSmall,
          isSmall,
          isMedium,
          isLarge,
        );
      case 2:
        return _buildThirdSlideContent(
          context,
          isExtraSmall,
          isSmall,
          isMedium,
          isLarge,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFirstSlideContent(
    BuildContext context,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
    bool isLarge,
  ) {
    // Calcular tamaños de fuente optimizados - más grandes
    double titleSize = isExtraSmall
        ? 22
        : isSmall
        ? 24
        : isMedium
        ? 26
        : 28;
    double subtitleSize = isExtraSmall
        ? 14
        : isSmall
        ? 15
        : isMedium
        ? 16
        : 17;
    double spacing = isExtraSmall
        ? 6
        : isSmall
        ? 8
        : isMedium
        ? 10
        : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Título centrado con efecto de gradiente mejorado
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF4FD1C7), Colors.white],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'onboarding.slides.babyBenefits'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  titleSize + 2, // Un poco más grande para el layout vertical
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Subtítulo integrado sin caja separada
        Text(
          'onboarding.slides.decreasesRisk'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Lista de beneficios simplificada
        _buildSimpleBenefitList(
          context,
          [
            'onboarding.slides.diseases.diabetes'.tr(),
            'onboarding.slides.diseases.hypertension'.tr(),
            'onboarding.slides.diseases.obesity'.tr(),
            'onboarding.slides.diseases.cancer'.tr(),
          ],
          isExtraSmall,
          isSmall,
          isMedium,
          isLarge,
        ),
      ],
    );
  }

  Widget _buildSecondSlideContent(
    BuildContext context,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
    bool isLarge,
  ) {
    // Calcular tamaños de fuente optimizados - más grandes
    double titleSize = isExtraSmall
        ? 22
        : isSmall
        ? 24
        : isMedium
        ? 26
        : 28;
    double subtitleSize = isExtraSmall
        ? 14
        : isSmall
        ? 15
        : isMedium
        ? 16
        : 17;
    double spacing = isExtraSmall
        ? 6
        : isSmall
        ? 8
        : isMedium
        ? 10
        : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Título centrado con efecto de gradiente mejorado
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF4FD1C7), Colors.white],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'onboarding.slides.babyBenefits'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize + 2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Subtítulo integrado sin caja separada
        Text(
          'onboarding.slides.protectionAgainst'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Lista de beneficios simplificada
        _buildSimpleBenefitList(
          context,
          [
            'onboarding.slides.diseases.diarrhea'.tr(),
            'onboarding.slides.diseases.allergies'.tr(),
            'onboarding.slides.diseases.colds'.tr(),
            'onboarding.slides.diseases.earInfections'.tr(),
            'onboarding.slides.diseases.sids'.tr(),
          ],
          isExtraSmall,
          isSmall,
          isMedium,
          isLarge,
        ),
      ],
    );
  }

  Widget _buildThirdSlideContent(
    BuildContext context,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
    bool isLarge,
  ) {
    // Calcular tamaños de fuente optimizados - más grandes
    double titleSize = isExtraSmall
        ? 18
        : isSmall
        ? 20
        : isMedium
        ? 22
        : 24;
    double mainTitleSize = isExtraSmall
        ? 22
        : isSmall
        ? 24
        : isMedium
        ? 26
        : 28;
    double contentSize = isExtraSmall
        ? 13
        : isSmall
        ? 14
        : isMedium
        ? 15
        : 16;
    double callToActionSize = isExtraSmall
        ? 14
        : isSmall
        ? 15
        : isMedium
        ? 16
        : 17;
    double spacing = isExtraSmall
        ? 6
        : isSmall
        ? 8
        : isMedium
        ? 10
        : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Título principal con gradiente especial y centrado
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF4FD1C7), Colors.white],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'onboarding.slides.nothingCompares'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize + 1,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(height: spacing * 0.5),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4FD1C7), Colors.white, Color(0xFF4FD1C7)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'onboarding.slides.breastMilk'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: mainTitleSize + 2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Contenido principal con mejor diseño
        Container(
          padding: EdgeInsets.all(spacing * 1.2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            'onboarding.slides.bestFood'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: contentSize,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: spacing * 1.5),

        // Mensaje final con diseño destacado
        Container(
          padding: EdgeInsets.all(spacing * 1.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4FD1C7).withValues(alpha: 0.25),
                const Color(0xFF4FD1C7).withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4FD1C7).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FD1C7).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            'onboarding.slides.breastfeedWithPride'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: callToActionSize + 1,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBenefitList(
    BuildContext context,
    List<String> benefits,
    bool isExtraSmall,
    bool isSmall,
    bool isMedium,
    bool isLarge,
  ) {
    double fontSize = isExtraSmall
        ? 14
        : isSmall
        ? 15
        : isMedium
        ? 16
        : 17;
    double spacing = isExtraSmall
        ? 10
        : isSmall
        ? 12
        : isMedium
        ? 14
        : 16;

    return Column(
      children: benefits
          .map(
            (benefit) => Padding(
              padding: EdgeInsets.only(bottom: spacing * 0.8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4FD1C7),
                    size: fontSize + 3,
                  ),
                  SizedBox(width: spacing * 0.7),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// Clase para pintar partículas optimizada para dispositivos de bajo rendimiento
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Solo 8 partículas para optimizar rendimiento
    final particles = <Offset>[
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.9),
    ];

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final offset = animationValue * 2 * 3.14159; // Movimiento circular suave
      final x = particle.dx + (i % 2 == 0 ? 1 : -1) * 10 * sin(offset + i);
      final y = particle.dy + (i % 3 == 0 ? 1 : -1) * 5 * cos(offset + i);

      canvas.drawCircle(
        Offset(x, y),
        2.0, // Radio pequeño para optimizar
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
