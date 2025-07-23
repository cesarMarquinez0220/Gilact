// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:ui';
import 'PerfilContinuacion/user_data_storage.dart';
import 'registro_bebe.dart';
import 'package:flutter/services.dart';
import 'registro_pre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Prepost extends StatefulWidget {
  const Prepost({super.key});

  @override
  _PrepostState createState() => _PrepostState();
}

class _PrepostState extends State<Prepost> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  late String email;
  bool _isHoveringPre = false;
  bool _isHoveringPost = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveUserSituation(String situation) async {
    String email = UserDataStorage.getUserEmail();
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDocument = usersSnapshot.docs.first;
        DocumentReference userRef = userDocument.reference;
        DocumentReference situationRef =
            userRef.collection('situacion').doc(situation);
        await situationRef.set(<String, dynamic>{});
        print('Situación registrada con éxito para el usuario: $email');
      } else {
        print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      print('Error por parte de: $e');
    }
  }

  void _handlePrepartoTap() async {
    _saveUserSituation('Pre-Parto');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroPre()),
    );
  }

  void _handlePostpartoTap() async {
    _saveUserSituation('Post-Parto');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroBebe()),
    );
  }

  void _onHover(bool isHovering, bool isPre) {
    setState(() {
      if (isPre) {
        _isHoveringPre = isHovering;
      } else {
        _isHoveringPost = isHovering;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return Scaffold(
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
            _buildBackgroundElements(),
            
            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  // Header con título
                  _buildHeader(),
                  
                  // Opciones de selección
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Opción Pre-Parto
                          Expanded(
                            child: _buildOptionCard(
                              title: 'Pre-Parto',
                              subtitle: 'Estoy embarazada',
                              imagePath: 'assets/images/mamapre.png',
                              gradientColors: const [
                                Color(0xFF03A696),
                                Color(0xFF02C3A4),
                              ],
                              onTap: _handlePrepartoTap,
                              isHovering: _isHoveringPre,
                              isPre: true,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Opción Post-Parto
                          Expanded(
                            child: _buildOptionCard(
                              title: 'Post-Parto',
                              subtitle: 'Ya tuve mi bebé',
                              imagePath: 'assets/images/mamapost.png',
                              gradientColors: const [
                                Color(0xFF03588C),
                                Color(0xFF0468B0),
                              ],
                              onTap: _handlePostpartoTap,
                              isHovering: _isHoveringPost,
                              isPre: false,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Círculos decorativos animados
        Positioned(
          top: -100,
          right: -100,
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
                        Colors.white.withOpacity(0.1),
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
        ...List.generate(8, (index) => _buildFloatingParticle(index)),
      ],
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final animationValue = _pulseController.value;
        final left = (index * 50.0) % MediaQuery.of(context).size.width;
        final top = (index * 80.0) % MediaQuery.of(context).size.height;
        
        return Positioned(
          left: left + (animationValue * 20 * (index % 2 == 0 ? 1 : -1)),
          top: top + (animationValue * 15 * (index % 3 == 0 ? 1 : -1)),
          child: Opacity(
            opacity: 0.3 + (animationValue * 0.2),
            child: Container(
              width: 4 + (index % 3) * 2.0,
              height: 4 + (index % 3) * 2.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
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

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Icono decorativo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Título principal
                  Text(
                    'Elige tu situación actual',
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    'Selecciona la opción que mejor describa tu momento',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isHovering,
    required bool isPre,
  }) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: onTap,
              onTapDown: (_) => _onHover(true, isPre),
              onTapUp: (_) => _onHover(false, isPre),
              onTapCancel: () => _onHover(false, isPre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: isHovering ? 20 : 10,
                      spreadRadius: isHovering ? 2 : 1,
                      offset: Offset(0, isHovering ? 8 : 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            // Contenido de texto
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    subtitle,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Botón de acción
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Seleccionar',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Imagen
                            Expanded(
                              flex: 3,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
