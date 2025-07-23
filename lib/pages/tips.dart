import 'package:flutter/material.dart';
import 'dart:ui';
import 'PerfilContinuacion/perfilnuevo.dart';
import 'completeinfo/alimentacion_complem.dart';
import 'completeinfo/beneficios_bebe.dart';
import 'completeinfo/beneficios_mama.dart';
import 'completeinfo/calostro.dart';
import 'completeinfo/consejos.dart';
import 'completeinfo/continuacion_extraccion.dart';
import 'completeinfo/continuacion_higiene.dart';
import 'completeinfo/encasode.dart';  
import 'completeinfo/extraccion.dart';
import 'completeinfo/higiene.dart';
import 'completeinfo/lactancia_exitosa.dart';
import 'completeinfo/padre_lactancia.dart';
import 'completeinfo/postura_agarre.dart';
import 'completeinfo/shape_decoration/shape.dart';
import 'completeinfo/suplementacion_hierro.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class Tips extends StatefulWidget {
  const Tips({super.key});

  @override
  _TipsState createState() => _TipsState();
}

class _TipsState extends State<Tips> with TickerProviderStateMixin {
  final _controller = PageController();
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _backgroundController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            _buildBackgroundElements(width, height),
            
            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  // Header con progreso
                  _buildProgressHeader(),
                  
                  // PageView con contenido
                  Expanded(
                    child: _buildPageView(),
                  ),
                  
                  // Indicador de páginas modernizado
                  _buildModernPageIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Tips de Lactancia',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildBackgroundElements(double width, double height) {
    return Stack(
      children: [
        // Círculos decorativos animados
        Positioned(
          top: -height * 0.1,
          right: -width * 0.1,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Partículas flotantes
        ...List.generate(6, (index) => _buildFloatingParticle(index)),
        
        // Elementos decorativos originales con glassmorphism
        Positioned(
          top: -height * .13,
          right: width * .05,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const BezierContainer(),
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: -height * .15,
          right: width * 0.1 + 190,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Ovalstatic1(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final animationValue = _pulseController.value;
        final left = (index * 60.0) % MediaQuery.of(context).size.width;
        final top = (index * 100.0) % MediaQuery.of(context).size.height;
        
        return Positioned(
          left: left + (animationValue * 25 * (index % 2 == 0 ? 1 : -1)),
          top: top + (animationValue * 20 * (index % 3 == 0 ? 1 : -1)),
          child: Opacity(
            opacity: 0.4 + (animationValue * 0.3),
            child: Container(
              width: 6 + (index % 3) * 2.0,
              height: 6 + (index % 3) * 2.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_currentPage + 1} / 14',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / 14,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                
                // Navegar a la siguiente pantalla en la última página
                if (index == 13) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Perfilnuevo(),
                      ),
                    );
                  });
                }
              },
              children: [
                _buildTipPage(const AlimentacionComplementariaInfo()),
                _buildTipPage(const SuplementoHierroInfo()),
                _buildTipPage(const BeneficiosBB()),
                _buildTipPage(const beneficios_mama()),
                _buildTipPage(const PosturaAgarreInfo()),
                _buildTipPage(const CalostroInfo()),
                _buildTipPage(const ConsejosLactanciaInfo()),
                _buildTipPage(const ExtraccionAlmacenamientoInfo()),
                _buildTipPage(const ContinuacionExtraccionInfo()),
                _buildTipPage(const HigieneLactanciaInfo()),
                _buildTipPage(const ContinuacionHigieneLactanciaInfo()),
                _buildTipPage(const LactanciaExitosa()),
                _buildTipPage(const RolPadreLactanciaInfo()),
                _buildTipPage(const ProblemasLactanciaInfo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipPage(Widget tipContent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del tip con estilo mejorado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _getTipTitle(_currentPage),
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Contenido del tip con estilo mejorado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: const Color(0xFF2D3748),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              child: tipContent,
            ),
          ),
        ],
      ),
    );
  }

  String _getTipTitle(int pageIndex) {
    final titles = [
      'Alimentación Complementaria',
      'Suplementación de Hierro',
      'Beneficios para el Bebé',
      'Beneficios para la Mamá',
      'Postura y Agarre',
      'Calostro',
      'Consejos de Lactancia',
      'Extracción y Almacenamiento',
      'Continuación Extracción',
      'Higiene en Lactancia',
      'Continuación Higiene',
      'Lactancia Exitosa',
      'Rol del Padre',
      'Problemas Comunes',
    ];
    return titles[pageIndex];
  }

  Widget _buildModernPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: SmoothPageIndicator(
        controller: _controller,
        count: 14,
        effect: const WormEffect(
          activeDotColor: Colors.white,
          dotColor: Colors.white54,
          dotHeight: 8,
          dotWidth: 8,
          spacing: 8,
          strokeWidth: 24,
          type: WormType.thin,
        ),
      ),
    );
  }
}
