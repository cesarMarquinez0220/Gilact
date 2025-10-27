import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/services/credentials_cache_service.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../onboarding/data/services/user_subcollections_service.dart';
import '../../../lactation/data/services/sleep_notification_service.dart';

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
    print('🔍 WelcomeScreen: initState() - INICIANDO WelcomeScreen...');
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
    print('🔍 _startWelcomeSequence: INICIANDO secuencia de bienvenida...');

    // Iniciar animación principal
    _mainController.forward();

    // Iniciar animación de texto con delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    // Iniciar partículas
    _particleController.repeat();

    print(
      '🔍 _startWelcomeSequence: Animaciones iniciadas, esperando 3 segundos...',
    );

    // Después de las animaciones, verificar onboarding y situación del usuario
    Future.delayed(const Duration(seconds: 3), () {
      print(
        '🔍 _startWelcomeSequence: Delay completado, iniciando verificación...',
      );
      _checkOnboardingAndUserSituation();
    });
  }

  Future<void> _checkOnboardingAndUserSituation() async {
    print(
      '🔍 _checkOnboardingAndUserSituation: INICIANDO verificación de onboarding...',
    );

    // Verificar si es un registro nuevo
    final prefs = await SharedPreferences.getInstance();
    final isNewRegistration = prefs.getBool('is_new_registration') ?? false;

    print(
      '🔍 _checkOnboardingAndUserSituation: is_new_registration = $isNewRegistration',
    );

    if (isNewRegistration) {
      print(
        '✅ _checkOnboardingAndUserSituation: Es un registro nuevo, limpiando flag y saliendo...',
      );
      // Limpiar el flag de registro nuevo
      await prefs.remove('is_new_registration');
      // No hacer nada más, el registro ya navegó al onboarding
      return;
    }

    print(
      '🔍 _checkOnboardingAndUserSituation: No es registro nuevo, verificando estado del onboarding...',
    );

    // Verificar estado del onboarding desde Firestore y sincronizar con SharedPreferences
    await _checkAndSyncOnboardingStatus();
  }

  /// Verifica el estado del onboarding desde Firestore y sincroniza con SharedPreferences
  Future<void> _checkAndSyncOnboardingStatus() async {
    try {
      // Obtener email del usuario
      String email = await _getUserEmail();
      print('🔍 _checkAndSyncOnboardingStatus: Email obtenido: "$email"');

      if (email.isEmpty) {
        print(
          '❌ ERROR _checkAndSyncOnboardingStatus: Email vacío, navegando a onboarding por defecto',
        );
        Navigator.of(context).pushReplacementNamed('/onboarding');
        return;
      }

      print(
        '🔍 _checkAndSyncOnboardingStatus: Buscando usuario en Firestore con email: "$email"',
      );

      // Buscar el documento del usuario por email
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print(
        '🔍 _checkAndSyncOnboardingStatus: Query completada. Documentos encontrados: ${userQuery.docs.length}',
      );

      if (userQuery.docs.isNotEmpty) {
        final userDocId = userQuery.docs.first.id;
        print(
          '✅ _checkAndSyncOnboardingStatus: Usuario encontrado con ID: $userDocId',
        );

        // Verificar el estado del onboarding en Firestore
        final situacionDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userDocId)
            .collection('situacion')
            .doc('seleccion')
            .get();

        print(
          '🔍 _checkAndSyncOnboardingStatus: Documento de situación existe: ${situacionDoc.exists}',
        );

        if (situacionDoc.exists) {
          final data = situacionDoc.data();
          print('🔍 _checkAndSyncOnboardingStatus: Datos del documento: $data');

          final onboardingCompletedInFirestore =
              data?['onboardingCompleted'] as bool? ?? false;

          print(
            '🔍 _checkAndSyncOnboardingStatus: onboardingCompleted en Firestore = $onboardingCompletedInFirestore',
          );

          // Sincronizar con SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(
            'onboarding_completed',
            onboardingCompletedInFirestore,
          );

          print(
            '🔍 _checkAndSyncOnboardingStatus: SharedPreferences actualizado con onboarding_completed = $onboardingCompletedInFirestore',
          );

          if (onboardingCompletedInFirestore) {
            print(
              '✅ _checkAndSyncOnboardingStatus: Onboarding completado, verificando situación del usuario...',
            );
            await _checkUserSituation();
          } else {
            print(
              '⚠️ _checkAndSyncOnboardingStatus: Onboarding NO completado, navegando a onboarding...',
            );
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        } else {
          print(
            '❌ _checkAndSyncOnboardingStatus: Documento de situación no existe, navegando a onboarding...',
          );
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      } else {
        print(
          '❌ _checkAndSyncOnboardingStatus: Usuario no encontrado en Firestore, navegando a onboarding...',
        );
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      print(
        '❌ ERROR _checkAndSyncOnboardingStatus: Error verificando onboarding: $e',
      );
      print(
        '🔍 _checkAndSyncOnboardingStatus: Stack trace: ${StackTrace.current}',
      );

      // En caso de error, usar SharedPreferences como fallback
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      print(
        '🔍 _checkAndSyncOnboardingStatus: Fallback - onboarding_completed desde SharedPreferences = $onboardingCompleted',
      );

      if (onboardingCompleted) {
        print(
          '✅ _checkAndSyncOnboardingStatus: Fallback - Onboarding completado, verificando situación...',
        );
        await _checkUserSituation();
      } else {
        print(
          '⚠️ _checkAndSyncOnboardingStatus: Fallback - Onboarding NO completado, navegando a onboarding...',
        );
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
      print(
        '🔍 WelcomeScreen: Estado inicial del UserProfileBloc: ${context.read<UserProfileBloc>().state.runtimeType}',
      );

      // 0. Reinicializar el UserProfileBloc para el nuevo usuario (sin desconectar)
      print(
        '🔄 WelcomeScreen: Reinicializando UserProfileBloc para nuevo usuario...',
      );
      context.read<UserProfileBloc>().add(ResetUserProfileRequested());

      // Esperar un momento para que se procese el reinicio
      await Future.delayed(const Duration(milliseconds: 100));

      print(
        '🔍 WelcomeScreen: Estado del UserProfileBloc después de reinicio: ${context.read<UserProfileBloc>().state.runtimeType}',
      );

      // 1. Cargar perfil básico del usuario y esperar a que se complete
      print('🔍 WelcomeScreen: Enviando GetUserProfileRequested...');
      context.read<UserProfileBloc>().add(
        GetUserProfileRequested(userId: userId),
      );

      // Esperar a que el perfil se cargue completamente
      await _waitForUserProfileToLoad();

      print(
        '🔍 WelcomeScreen: Estado del UserProfileBloc después de cargar perfil: ${context.read<UserProfileBloc>().state.runtimeType}',
      );

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
        print('🔍 WelcomeScreen: Enviando UpdateUserSituationRequested...');
        print('🔍 WelcomeScreen: userId = $userId');
        print(
          '🔍 WelcomeScreen: isPrePartum = $isPrePartum, isPostPartum = $isPostPartum',
        );

        context.read<UserProfileBloc>().add(
          UpdateUserSituationRequested(
            userId: userId,
            isPrePartum: isPrePartum,
            isPostPartum: isPostPartum,
            situationData: situationData,
          ),
        );

        print('🔍 WelcomeScreen: UpdateUserSituationRequested enviado');

        // Esperar un momento para que se procese la información
        await Future.delayed(const Duration(milliseconds: 500));

        // Verificar el estado después de la actualización
        final currentState = context.read<UserProfileBloc>().state;
        print(
          '🔍 WelcomeScreen: Estado del UserProfileBloc después de actualización: ${currentState.runtimeType}',
        );

        if (currentState is UserProfileUpdated) {
          print('✅ WelcomeScreen: Situación actualizada exitosamente');
        } else if (currentState is UserProfileFailure) {
          print(
            '❌ WelcomeScreen: Error actualizando situación: ${currentState.message}',
          );
        } else {
          print(
            '⚠️ WelcomeScreen: Estado inesperado después de actualización: $currentState',
          );
        }
      } else {
        print('⚠️ WelcomeScreen: No se encontró información de situación');
      }

      // 3. Programar notificación diaria de sueño si es postparto
      if (situationData != null &&
          situationData['situationType'] == 'postparto') {
        print(
          '🌙 WelcomeScreen: Usuario es postparto, programando notificación diaria',
        );
        await _scheduleSleepNotification();
      } else {
        print(
          '⚠️ WelcomeScreen: Usuario no es postparto, no se programará notificación',
        );
      }

      // 4. Navegar a home con toda la información cargada
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
      print(
        '🔍 WelcomeScreen: Intento $attempts - Estado actual: ${currentState.runtimeType}',
      );

      if (currentState is UserProfileLoaded ||
          currentState is UserProfileUpdated) {
        print('✅ WelcomeScreen: Perfil del usuario cargado exitosamente');
        print('🔍 WelcomeScreen: Estado final: $currentState');
        return;
      }

      if (currentState is UserProfileFailure) {
        print(
          '❌ WelcomeScreen: Error cargando perfil del usuario: ${currentState.message}',
        );
        return;
      }

      // Esperar 500ms antes del siguiente intento
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    print(
      '⚠️ WelcomeScreen: Timeout esperando perfil del usuario después de $maxAttempts intentos',
    );
  }

  Future<String> _getUserEmail() async {
    try {
      print('🔍 _getUserEmail: Iniciando obtención de email...');

      // Intentar obtener desde Firebase Auth primero
      final firebaseUser = FirebaseAuth.instance.currentUser;
      print(
        '🔍 _getUserEmail: Firebase Auth currentUser: ${firebaseUser?.uid}',
      );
      print('🔍 _getUserEmail: Firebase Auth email: "${firebaseUser?.email}"');

      if (firebaseUser?.email != null && firebaseUser!.email!.isNotEmpty) {
        print(
          '✅ _getUserEmail: Email obtenido desde Firebase Auth: "${firebaseUser.email}"',
        );
        return firebaseUser.email!;
      }

      print(
        '⚠️ _getUserEmail: Firebase Auth email vacío, intentando SharedPreferences...',
      );

      // Fallback a SharedPreferences
      String email = await CredentialsCacheService.loadCredentialsFromCache();
      print('🔍 _getUserEmail: Email desde SharedPreferences: "$email"');

      if (email.isEmpty) {
        print(
          '❌ ERROR _getUserEmail: Email vacío tanto en Firebase Auth como en SharedPreferences',
        );
        print(
          '🔍 _getUserEmail: Verificando SharedPreferences directamente...',
        );

        // Verificación adicional de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final cachedEmail = prefs.getString('cached_email');
        final saveCredentials = prefs.getBool('save_credentials');
        print('🔍 _getUserEmail: cached_email directo: "$cachedEmail"');
        print('🔍 _getUserEmail: save_credentials: $saveCredentials');

        if (cachedEmail != null && cachedEmail.isNotEmpty) {
          print(
            '✅ _getUserEmail: Email encontrado en SharedPreferences directo: "$cachedEmail"',
          );
          return cachedEmail;
        }
      } else {
        print(
          '✅ _getUserEmail: Email obtenido desde SharedPreferences: "$email"',
        );
        return email;
      }

      return '';
    } catch (e) {
      print('❌ ERROR _getUserEmail: Error obteniendo email del usuario: $e');
      return '';
    }
  }

  /// Programar notificación diaria de sueño a las 8 AM
  Future<void> _scheduleSleepNotification() async {
    try {
      final notificationService = GetIt.instance<SleepNotificationService>();
      await notificationService.scheduleDailySleepNotification();
      print('✅ WelcomeScreen: Notificación diaria programada exitosamente');
    } catch (e) {
      print('❌ WelcomeScreen: Error programando notificación: $e');
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
