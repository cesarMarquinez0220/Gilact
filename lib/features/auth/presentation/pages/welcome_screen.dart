import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/credentials_cache_service.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../onboarding/data/services/user_subcollections_service.dart';

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

    // Después de las animaciones, verificar onboarding y situación del usuario
    Future.delayed(const Duration(seconds: 3), () {
      _checkOnboardingAndUserSituation();
    });
  }

  Future<void> _checkOnboardingAndUserSituation() async {
    print('🔍 WelcomeScreen: Iniciando verificación de onboarding...');

    // Verificar si es un registro nuevo
    final prefs = await SharedPreferences.getInstance();
    final isNewRegistration = prefs.getBool('is_new_registration') ?? false;

    if (isNewRegistration) {
      print(
        '🔍 WelcomeScreen: Es un registro nuevo, limpiando flag y saliendo...',
      );
      // Limpiar el flag de registro nuevo
      await prefs.remove('is_new_registration');
      // No hacer nada más, el registro ya navegó al onboarding
      return;
    }

    // Verificar estado del onboarding desde Firestore y sincronizar con SharedPreferences
    await _checkAndSyncOnboardingStatus();
  }

  /// Verifica el estado del onboarding desde Firestore y sincroniza con SharedPreferences
  Future<void> _checkAndSyncOnboardingStatus() async {
    try {
      // Obtener email del usuario
      String email = await _getUserEmail();
      print('🔍 WelcomeScreen: Verificando onboarding para email: $email');

      // Buscar el documento del usuario por email
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDocId = userQuery.docs.first.id;
        print('🔍 WelcomeScreen: Usuario encontrado con ID: $userDocId');

        // Verificar el estado del onboarding en Firestore
        final situacionDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userDocId)
            .collection('situacion')
            .doc('seleccion')
            .get();

        if (situacionDoc.exists) {
          final data = situacionDoc.data();
          final onboardingCompletedInFirestore =
              data?['onboardingCompleted'] as bool? ?? false;

          print(
            '🔍 WelcomeScreen: onboardingCompleted en Firestore = $onboardingCompletedInFirestore',
          );

          // Sincronizar con SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(
            'onboarding_completed',
            onboardingCompletedInFirestore,
          );

          if (onboardingCompletedInFirestore) {
            print(
              '🔍 WelcomeScreen: Onboarding completado, verificando situación del usuario...',
            );
            await _checkUserSituation();
          } else {
            print(
              '🔍 WelcomeScreen: Onboarding NO completado, navegando a onboarding...',
            );
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        } else {
          print(
            '🔍 WelcomeScreen: Documento de situación no existe, navegando a onboarding...',
          );
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      } else {
        print(
          '🔍 WelcomeScreen: Usuario no encontrado, navegando a onboarding...',
        );
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      print('❌ WelcomeScreen: Error verificando onboarding: $e');
      // En caso de error, usar SharedPreferences como fallback
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      if (onboardingCompleted) {
        await _checkUserSituation();
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
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
      print('🔄 Redirigiendo a home por defecto...');
      _navigateToHome();
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
              print('⏰ Timeout en consulta Firestore - redirigiendo a home');
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
        String userId = userDocument.id;

        print(
          '👤 Usuario encontrado en Firestore con ID: $userId, cargando información completa...',
        );

        // Cargar información completa del usuario y situación
        await _loadCompleteUserData(userId, email);
      } else {
        // El usuario no existe en la base de datos.
        print('❌ Usuario no encontrado en Firestore - redirigiendo a home');
        _navigateToHome();
      }
    } catch (e) {
      print('❌ Error en _checkUserSituation: $e');
      print('🔄 Redirigiendo a home por error...');

      // En caso de error, redirigir a home
      _navigateToHome();
    }
  }

  Future<void> _loadCompleteUserData(String userId, String email) async {
    try {
      print('🔄 WelcomeScreen: Cargando datos completos del usuario...');

      // 1. Cargar perfil básico del usuario y esperar a que se complete
      context.read<UserProfileBloc>().add(
        GetUserProfileRequested(userId: userId),
      );

      // Esperar a que el perfil se cargue completamente
      await _waitForUserProfileToLoad();

      // 2. Cargar información de situación usando UserSubcollectionsService
      final userSubcollectionsService = UserSubcollectionsService(
        FirebaseFirestore.instance,
      );
      final situationData = await userSubcollectionsService
          .getUserSituationData(userId);

      if (situationData != null) {
        print(
          '✅ WelcomeScreen: Información de situación cargada: $situationData',
        );

        // Determinar si es preparto o postparto
        final situationType = situationData['situationType'] as String?;
        final isPrePartum = situationType == 'preparto';
        final isPostPartum = situationType == 'postparto';

        print('🔍 WelcomeScreen: situationType = $situationType');
        print(
          '🔍 WelcomeScreen: isPrePartum = $isPrePartum, isPostPartum = $isPostPartum',
        );

        // Actualizar el UserProfileBloc con la información de situación
        context.read<UserProfileBloc>().add(
          UpdateUserSituationRequested(
            userId: userId,
            isPrePartum: isPrePartum,
            isPostPartum: isPostPartum,
            situationData: situationData,
          ),
        );

        // Esperar un momento para que se procese la información
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        print('⚠️ WelcomeScreen: No se encontró información de situación');
      }

      // 3. Navegar a home con toda la información cargada
      print('🚀 WelcomeScreen: Navegando a home con datos completos...');
      _navigateToHome();
    } catch (e) {
      print('❌ Error cargando datos completos: $e');
      _navigateToHome();
    }
  }

  Future<void> _waitForUserProfileToLoad() async {
    print(
      '⏳ WelcomeScreen: Esperando a que se cargue el perfil del usuario...',
    );

    // Esperar hasta que el UserProfileBloc tenga un perfil cargado
    int attempts = 0;
    const maxAttempts = 20; // Máximo 10 segundos (20 * 500ms)

    while (attempts < maxAttempts) {
      final currentState = context.read<UserProfileBloc>().state;

      if (currentState is UserProfileLoaded ||
          currentState is UserProfileUpdated) {
        print('✅ WelcomeScreen: Perfil del usuario cargado exitosamente');
        return;
      }

      if (currentState is UserProfileFailure) {
        print('❌ WelcomeScreen: Error cargando perfil del usuario');
        return;
      }

      // Esperar 500ms antes del siguiente intento
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    print('⚠️ WelcomeScreen: Timeout esperando perfil del usuario');
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

  void _navigateToHome() {
    // Navegar a la página principal con toda la información ya cargada
    Navigator.pushReplacementNamed(context, '/home');
    print('🔄 Navegando a Home con datos completos cargados');
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
