import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/services/user_subcollections_service.dart';
import '../../domain/entities/prepartum_info.dart';
import '../../../../alerta_dialoge.dart';

class PrepartumFormPage extends StatefulWidget {
  const PrepartumFormPage({super.key});

  @override
  State<PrepartumFormPage> createState() => _PrepartumFormPageState();
}

class _PrepartumFormPageState extends State<PrepartumFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _expectedBirthDateController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones con delays escalonados
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _expectedBirthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectExpectedBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        const Duration(days: 90),
      ), // 3 meses por defecto
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Máximo 1 año
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _expectedBirthDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(date);
      });
    }
  }

  Future<void> _savePrepartumInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      DialogExample.showValidationErrorDialog(
        context,
        'fecha aproximada de nacimiento',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el usuario actual
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('Usuario no autenticado');
      }

      final userId = authState.user.id;
      final subcollectionsService = GetIt.instance<UserSubcollectionsService>();

      // Preparar datos del formulario
      final formData = {
        'expectedBirthDate': _selectedDate!.toIso8601String(),
        'formType': 'prepartum',
        'completedAt': DateTime.now().toIso8601String(),
      };

      // Completar el proceso de onboarding (crear subcolecciones y guardar datos)
      await subcollectionsService.completeOnboardingProcess(userId, formData);

      if (mounted) {
        DialogExample.showSuccessDialog(
          context,
          '¡Onboarding Completado!',
          'Tu información de preparto ha sido guardada exitosamente. ¡Bienvenida a Gilact!',
          () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        DialogExample.showErrorDialog(
          context,
          'Error',
          'Error al completar el onboarding: $e',
        );
      }
    }
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
            // Fondo animado con partículas
            _buildAnimatedBackground(),

            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_slideAnimation),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),

                            // Logo y título
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.pregnant_woman,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Información de Preparto',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Cuéntanos cuándo esperas a tu bebé',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            const SizedBox(height: 48),

                            // Campo de fecha esperada
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _expectedBirthDateController,
                                readOnly: true,
                                onTap: _selectExpectedBirthDate,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor selecciona la fecha aproximada de nacimiento';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Selecciona la fecha esperada',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Botón de guardar
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(
                                      0xFF1A365D,
                                    ), // Azul marino oscuro (primario)
                                    Color(
                                      0xFF4FD1C7,
                                    ), // Verde azulado medio vibrante (primario)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4FD1C7,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _savePrepartumInfo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Guardar',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Botón de cancelar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
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

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Círculos decorativos animados más grandes y suaves
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF2C5F5D,
                        ).withOpacity(0.15), // Azul teal oscuro (secundario)
                        const Color(
                          0xFF2C5F5D,
                        ).withOpacity(0.05), // Azul teal oscuro (secundario)
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -120,
          left: -120,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.7,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4FD1C7).withOpacity(
                          0.1,
                        ), // Verde azulado medio vibrante (primario)
                        const Color(0xFF4FD1C7).withOpacity(
                          0.03,
                        ), // Verde azulado medio vibrante (primario)
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Elementos decorativos adicionales
        Positioned(
          top: 150,
          right: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFFE2E8F0,
                  ).withOpacity(0.08), // Gris muy claro (secundario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 60,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFFB794F6,
                  ).withOpacity(0.06), // Lavanda suave (primario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Patrón de puntos decorativos mejorado
        Positioned(
          top: 120,
          right: 30,
          child: Container(
            width: 80,
            height: 80,
            child: CustomPaint(painter: DotsPainter()),
          ),
        ),
        // Líneas decorativas sutiles
        Positioned(
          top: 300,
          left: 20,
          child: Container(
            width: 2,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(
                    0xFF4FD1C7,
                  ).withOpacity(0.1), // Verde azulado medio vibrante (primario)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
          .withOpacity(0.4) // Gris muy claro (secundario)
      ..style = PaintingStyle.fill;

    // Crear un patrón de puntos más elegante
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final x = i * 20.0;
        final y = j * 20.0;
        final radius = (i + j) % 2 == 0 ? 2.5 : 1.5;

        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Agregar algunos puntos más pequeños para mayor detalle
    final smallPaint = Paint()
      ..color = const Color(0xFF4FD1C7)
          .withOpacity(0.2) // Verde azulado medio vibrante (primario)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = i * 25.0 + 10.0;
        final y = j * 25.0 + 10.0;
        canvas.drawCircle(Offset(x, y), 1.0, smallPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
