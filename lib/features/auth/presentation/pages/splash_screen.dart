import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

import '../bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isCheckingOnboarding = true;
  final AppLogger _logger = getIt<AppLogger>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _fadeController.forward();
  }

  void _checkAuthStatus() async {
    _logger.d('SplashScreen: Iniciando verificación de estado...');
    // Verificar estado de autenticación después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        _logger.d('SplashScreen: Verificando onboarding...');
        // Verificar si el onboarding ya fue completado
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;

        final onboardingCompleted =
            prefs.getBool('onboarding_completed') ?? false;

        _logger.d('SplashScreen: onboarding_completed = $onboardingCompleted');

        if (onboardingCompleted) {
          _logger.d(
            'SplashScreen: Onboarding completado, verificando autenticación...',
          );
          // Si el onboarding ya fue completado, verificar autenticación (offline primero)
          setState(() {
            _isCheckingOnboarding = false;
          });
          context.read<AuthBloc>().add(const CheckOfflineSessionRequested());
        } else {
          _logger.d(
            'SplashScreen: Onboarding NO completado, navegando a onboarding...',
          );
          // Si no, ir directamente al onboarding
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _logger.d(
            'SplashScreen: BlocListener recibió estado: ${state.runtimeType}',
          );
          // Solo escuchar el AuthBloc si no estamos verificando onboarding
          if (!_isCheckingOnboarding) {
            if (state is AuthAuthenticated) {
              _logger.d('SplashScreen: Usuario autenticado, navegando a /home');
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (state is AuthUnauthenticated || state is AuthFailure) {
              _logger.d(
                'SplashScreen: Usuario NO autenticado, navegando a /login',
              );
              Navigator.of(context).pushReplacementNamed('/login');
            }
          } else {
            _logger.d(
              'SplashScreen: Ignorando estado porque estamos verificando onboarding',
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF03A696), Color(0xFF26A69A), Color(0xFF4DB6AC)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/images/logo-completo2.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Título animado
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Gilact',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtítulo animado
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Tu compañero en la lactancia materna',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 60),

                // Indicador de carga
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),

                const SizedBox(height: 20),

                // Texto de carga
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Cargando...',
                    style: TextStyle(fontSize: 16, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
