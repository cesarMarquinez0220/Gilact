import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/services/credentials_cache_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startWelcomeSequence();
  }

  void _initializeAnimations() {
    // Controlador principal para el logo
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Controlador para partículas decorativas
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Controlador para texto
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animación del logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Animación del texto
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    // Animación de partículas
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Animación del progreso
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void _startWelcomeSequence() {
    // Iniciar animación principal
    _mainController.forward();

    // Iniciar animación de texto con delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    // Iniciar partículas
    _particleController.repeat();

    // Después de las animaciones, verificar situación del usuario
    Future.delayed(const Duration(seconds: 3), () {
      _checkUserSituation();
    });
  }

  Future<void> _checkUserSituation() async {
    // Obtener email del usuario desde SharedPreferences o donde lo tengas almacenado
    String email = await _getUserEmail();

    // Debug: mostrar el email que se está usando
    print(
      '🔍 WelcomeScreen: Verificando situación del usuario con email: "$email"',
    );

    // Verificar que el email no esté vacío
    if (email.isEmpty) {
      print('❌ ERROR: Email del usuario está vacío');
      print('🔄 Redirigiendo a prepost por defecto...');
      _navigateToPrepost();
      return;
    }

    try {
      print('🌐 Consultando Firestore para usuario: $email');

      // Agregar timeout para evitar que se cuelgue indefinidamente
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏰ Timeout en consulta Firestore - redirigiendo a prepost');
              throw TimeoutException(
                'Consulta a Firestore excedió el tiempo límite',
              );
            },
          );

      print(
        '✅ Consulta Firestore completada. Documentos encontrados: ${usersSnapshot.docs.length}',
      );

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDocument = usersSnapshot.docs.first;
        DocumentReference userRef = userDocument.reference;

        print(
          '👤 Usuario encontrado en Firestore, verificando subcolección "situacion"',
        );

        bool situacionExists = await userRef
            .collection('situacion')
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.isNotEmpty);

        print('📁 Subcolección "situacion" existe: $situacionExists');

        if (situacionExists) {
          // El usuario ya tiene la subcolección "situacion"
          print('🔄 Usuario ya tiene situación - redirigiendo a Perfilnuevo');
          _navigateToPerfilNuevo();
        } else {
          // El usuario no tiene la subcolección "situacion", ir a prepost
          print('🔄 Usuario no tiene situación - redirigiendo a Prepost');
          _navigateToPrepost();
        }
      } else {
        // El usuario no existe en la base de datos.
        print('❌ Usuario no encontrado en Firestore - redirigiendo a prepost');
        _navigateToPrepost();
      }
    } catch (e) {
      print('❌ Error en _checkUserSituation: $e');
      print('🔄 Redirigiendo a prepost por error...');

      // En caso de error, redirigir a prepost
      _navigateToPrepost();
    }
  }

  Future<String> _getUserEmail() async {
    try {
      // Obtener email desde SharedPreferences usando CredentialsCacheService
      String email = await CredentialsCacheService.loadCredentialsFromCache();
      print('📧 Email obtenido desde caché: "$email"');
      return email;
    } catch (e) {
      print('❌ Error obteniendo email del usuario: $e');
      return '';
    }
  }

  void _navigateToPrepost() {
    // Navegar a la página principal con el nuevo diseño integrado
    Navigator.pushReplacementNamed(context, '/home');
    print('🔄 Navegando a Prepost (página principal con diseño integrado)');
  }

  void _navigateToPerfilNuevo() {
    // Navegar a la página principal con el nuevo diseño integrado
    Navigator.pushReplacementNamed(context, '/home');
    print('🔄 Navegando a Perfilnuevo (página principal con diseño integrado)');
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
              Color(0xFF1A365D), // Azul marino oscuro (primario)
              Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Partículas decorativas de fondo
            _buildParticles(),

            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con animación mejorada
                  _buildAnimatedLogo(),

                  const SizedBox(height: 60),

                  // Texto de bienvenida
                  _buildWelcomeText(),

                  const SizedBox(height: 80),

                  // Barra de progreso elegante
                  _buildProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticles() {
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4FD1C7).withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo-completo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textOpacity,
            child: Column(
              children: [
                Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Verificando tu perfil...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Barra de progreso personalizada
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 200 * _progressAnimation.value,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FD1C7), Colors.white],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4FD1C7).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Texto de estado
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Crear partículas flotantes
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20.0) + animationValue * 100) % size.width;
      final y =
          size.height * 0.3 +
          (i * 30.0) +
          (animationValue * 50 * (i % 2 == 0 ? 1 : -1));

      final radius = 2.0 + (i % 3);
      final opacity = 0.3 + (animationValue * 0.4);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Partículas más grandes en el fondo
    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8.0) + animationValue * 30;
      final y = size.height * 0.7 + (i * 40.0);

      final radius = 4.0 + (i % 2);
      final opacity = 0.1 + (animationValue * 0.2);

      paint.color = const Color(0xFF4FD1C7).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
