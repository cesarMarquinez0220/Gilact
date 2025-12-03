import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/services/user_subcollections_service.dart';
import '../../../../alerta_dialoge.dart';
import '../../../../core/services/app_initialization_service.dart';

class PostpartumFormPage extends StatefulWidget {
  const PostpartumFormPage({super.key});

  @override
  State<PostpartumFormPage> createState() => _PostpartumFormPageState();
}

class _PostpartumFormPageState extends State<PostpartumFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _babyNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthTimeController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _lastMenstruationController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  DateTime? _selectedBirthDate;
  DateTime? _selectedMenstruationDate;
  int _calculatedGestationalAge = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
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

  void _setupListeners() {
    _birthDateController.addListener(_calculateGestationalAge);
    _lastMenstruationController.addListener(_calculateGestationalAge);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _babyNameController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    _birthWeightController.dispose();
    _lastMenstruationController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
      _calculateGestationalAge();
    }
  }

  Future<void> _selectBirthTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _birthTimeController.text = time.format(context);
      });
    }
  }

  Future<void> _selectLastMenstruation() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 280)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedMenstruationDate = date;
        _lastMenstruationController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(date);
      });
      _calculateGestationalAge();
    }
  }

  void _calculateGestationalAge() {
    if (_selectedBirthDate != null && _selectedMenstruationDate != null) {
      final difference = _selectedBirthDate!.difference(
        _selectedMenstruationDate!,
      );
      final gestationalAgeInWeeks = difference.inDays ~/ 7;

      setState(() {
        _calculatedGestationalAge = gestationalAgeInWeeks;
      });
    }
  }

  Future<void> _savePostpartumInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null || _selectedMenstruationDate == null) {
      DialogExample.showValidationErrorDialog(context, 'onboarding.dateRequired'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el usuario actual
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('profile.noUserAuthenticated'.tr());
      }

      final userId = authState.user.id;
      final subcollectionsService = GetIt.instance<UserSubcollectionsService>();

      // Preparar datos del formulario
      final formData = {
        'babyName': _babyNameController.text.trim(),
        'birthDate': _selectedBirthDate!.toIso8601String(),
        'birthTime': _birthTimeController.text.trim(),
        'birthPlace': _birthPlaceController.text.trim(),
        'birthWeight': double.parse(_birthWeightController.text.trim()),
        'gestationalAge': _calculatedGestationalAge,
        'lastMenstruation': _selectedMenstruationDate!.toIso8601String(),
        'formType': 'postpartum',
        'completedAt': DateTime.now().toIso8601String(),
      };

      // Completar el proceso de onboarding (crear subcolecciones y guardar datos)
      await subcollectionsService.completeOnboardingProcess(userId, formData);

      if (mounted) {
        // Usar AppInitializationService para cargar correctamente el perfil antes de navegar
        // Esto asegura que el UserProfileBloc tenga los datos correctos del nuevo usuario
        await AppInitializationService.refreshAndGoHome(context);
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
            Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Column(
                    children: [
                      // Contenido scrolleable
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              // Logo y título
                              Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.child_care,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'onboarding.babyRegistration'.tr(),
                                    style: const TextStyle(
                                      fontSize: 24,
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
                                  const SizedBox(height: 6),
                                  Text(
                                    'onboarding.completeBabyInfo'.tr(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Campo nombre del bebé
                              _buildLargerTextField(
                                label: 'onboarding.babyName'.tr(),
                                hint: 'onboarding.babyNameHint'.tr(),
                                controller: _babyNameController,
                                icon: Icons.child_care_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'onboarding.nameRequired'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Campos de fecha y hora en fila
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildLargerDateField(
                                      label: 'onboarding.date'.tr(),
                                      hint: 'onboarding.dateHint'.tr(),
                                      controller: _birthDateController,
                                      onTap: _selectBirthDate,
                                      icon: Icons.calendar_today_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'onboarding.dateRequired'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildLargerTimeField(
                                      label: 'onboarding.time'.tr(),
                                      hint: 'onboarding.timeHint'.tr(),
                                      controller: _birthTimeController,
                                      onTap: _selectBirthTime,
                                      icon: Icons.access_time_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'onboarding.timeRequired'.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Campo lugar de nacimiento
                              _buildLargerTextField(
                                label: 'onboarding.birthPlace'.tr(),
                                hint: 'onboarding.birthPlaceHint'.tr(),
                                controller: _birthPlaceController,
                                icon: Icons.location_on_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'onboarding.placeRequired'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Campo peso al nacer
                              _buildLargerTextField(
                                label: 'onboarding.birthWeight'.tr(),
                                hint: 'onboarding.birthWeightHint'.tr(),
                                controller: _birthWeightController,
                                icon: Icons.monitor_weight_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'onboarding.weightRequired'.tr();
                                  }
                                  final weight = double.tryParse(value);
                                  if (weight == null || weight <= 0) {
                                    return 'onboarding.invalidWeight'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Campo última menstruación
                              _buildLargerDateField(
                                label: 'onboarding.lastMenstruation'.tr(),
                                hint: 'onboarding.lastMenstruationHint'.tr(),
                                controller: _lastMenstruationController,
                                onTap: _selectLastMenstruation,
                                icon: Icons.calendar_today_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'onboarding.dateRequired'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Botón principal - Guardar
                              Container(
                                width: double.infinity,
                                height: 50,
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
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _savePostpartumInfo,
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
                                      : Text(
                                          'common.save'.tr(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Botón de cancelar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
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
                                  child: Text(
                                    'common.cancel'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargerTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            enabled: !_isLoading,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              // Reduce el padding interno del TextField
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargerDateField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            validator: validator,
            enabled: !_isLoading,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargerTimeField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            validator: validator,
            enabled: !_isLoading,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              // Reduce el padding interno del TextField
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: PostpartumBackgroundPainter(_pulseAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class PostpartumBackgroundPainter extends CustomPainter {
  final double animationValue;

  PostpartumBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Círculos decorativos animados distribuidos por toda la pantalla
    final circles = [
      {
        'center': Offset(size.width * 0.15, size.height * 0.2),
        'radius': 80.0 + (animationValue * 20),
        'color': const Color(0xFF4FD1C7).withValues(alpha: 0.1),
      },
      {
        'center': Offset(size.width * 0.85, size.height * 0.3),
        'radius': 60.0 + (animationValue * 15),
        'color': const Color(0xFF1A365D).withValues(alpha: 0.15),
      },
      {
        'center': Offset(size.width * 0.2, size.height * 0.7),
        'radius': 100.0 + (animationValue * 25),
        'color': const Color(0xFF2C5F5D).withValues(alpha: 0.08),
      },
      {
        'center': Offset(size.width * 0.8, size.height * 0.8),
        'radius': 70.0 + (animationValue * 18),
        'color': const Color(0xFF4FD1C7).withValues(alpha: 0.12),
      },
    ];

    for (final circle in circles) {
      paint.color = circle['color'] as Color;
      canvas.drawCircle(
        circle['center'] as Offset,
        circle['radius'] as double,
        paint,
      );
    }

    // Partículas flotantes distribuidas por toda la pantalla
    paint.color = Colors.white.withValues(alpha: 0.05);
    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i / 15.0) + animationValue * 50) % size.width;
      final y =
          size.height * 0.1 + (i * 60.0) + (animationValue * 30 * math.sin(i));

      final radius = 2.0 + (i % 3);
      paint.color = Colors.white.withValues(alpha: 0.05 + (animationValue * 0.1));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Ondas decorativas centradas
    paint.color = const Color(0xFF4FD1C7).withValues(alpha: 0.03);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final center = Offset(size.width * 0.5, size.height * 0.5);
      final radius = 150.0 + (i * 50.0) + (animationValue * 20);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
          .withValues(alpha: 0.4) // Gris muy claro (secundario)
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
          .withValues(alpha: 0.2) // Verde azulado medio vibrante (primario)
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
