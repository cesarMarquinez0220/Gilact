import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/services/user_subcollections_service.dart';
import '../widgets/situation_option_widget.dart';

class SituationSelectionPage extends StatefulWidget {
  const SituationSelectionPage({super.key});

  @override
  State<SituationSelectionPage> createState() => _SituationSelectionPageState();
}

class _SituationSelectionPageState extends State<SituationSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  String? _selectedSituation;

  @override
  void initState() {
    super.initState();
    print('🔍 SituationSelectionPage: Inicializando...');
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _particleController.repeat();
  }

  Future<void> _saveSituation(String situation) async {
    try {
      // Obtener el usuario actual
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('profile.noUserAuthenticated'.tr());
      }

      final userId = authState.user.id;
      final subcollectionsService = GetIt.instance<UserSubcollectionsService>();

      // Solo guardar la selección temporalmente (sin crear subcolecciones aún)
      await subcollectionsService.saveTemporarySituation(userId, situation);

      // Navegar al formulario correspondiente
      if (mounted) {
        if (situation == 'preparto') {
          Navigator.of(context).pushNamed('/prepartum-form');
        } else if (situation == 'postparto') {
          Navigator.of(context).pushNamed('/postpartum-form');
        }
      }
    } catch (e) {
      print('❌ Error en _saveSituation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'common.error'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
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
              Color(0xFF2C5F5D), // Azul teal oscuro
              Color(0xFF1A365D), // Azul marino oscuro
              Color(0xFF4FD1C7), // Verde azulado medio vibrante
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Partículas de fondo
            _buildParticles(),

            // Contenido principal
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Header con corazón
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Título principal
                        Text(
                          'onboarding.chooseSituation'.tr(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtítulo
                        Text(
                          'onboarding.selectSituationDescription'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Opciones de situación
                        Expanded(
                          child: Column(
                            children: [
                              // Opción Pre-parto
                              Expanded(
                                child: SituationOptionWidget(
                                  title: 'onboarding.preParto'.tr(),
                                  description: 'onboarding.prePartoDescription'.tr(),
                                  illustrationPath: 'assets/images/mamapre.png',
                                  backgroundColor: const Color(0xFF4FD1C7),
                                  isSelected: _selectedSituation == 'preparto',
                                  onTap: () async {
                                    setState(() {
                                      _selectedSituation = 'preparto';
                                    });
                                    await _saveSituation('preparto');
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Opción Post-parto
                              Expanded(
                                child: SituationOptionWidget(
                                  title: 'onboarding.postParto'.tr(),
                                  description: 'onboarding.postPartoDescription'.tr(),
                                  illustrationPath:
                                      'assets/images/mamapost.png',
                                  backgroundColor: const Color(0xFF1A365D),
                                  isSelected: _selectedSituation == 'postparto',
                                  onTap: () async {
                                    setState(() {
                                      _selectedSituation = 'postparto';
                                    });
                                    await _saveSituation('postparto');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
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
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Crear partículas flotantes más pequeñas y dispersas
    for (int i = 0; i < 30; i++) {
      final x = (size.width * (i / 30.0) + animationValue * 80) % size.width;
      final y =
          size.height * 0.2 +
          (i * 25.0) +
          (animationValue * 40 * (i % 3 == 0 ? 1 : -1));

      final radius = 1.5 + (i % 2);
      final opacity = 0.1 + (animationValue * 0.2);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Partículas más grandes en el fondo
    for (int i = 0; i < 12; i++) {
      final x = size.width * (i / 12.0) + animationValue * 25;
      final y = size.height * 0.6 + (i * 35.0);

      final radius = 2.5 + (i % 2);
      final opacity = 0.05 + (animationValue * 0.15);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Partículas adicionales para mayor densidad
    for (int i = 0; i < 20; i++) {
      final x =
          (size.width * 0.3 + i * 20.0 + animationValue * 15) % size.width;
      final y = size.height * 0.4 + (i * 30.0);

      final radius = 1.0 + (i % 3) * 0.5;
      final opacity = 0.08 + (animationValue * 0.12);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
