import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_helper.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/registration_background_widget.dart';
import '../widgets/registration_form_widget.dart';
import '../../../../alerta_dialoge.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _motherNameController = TextEditingController();

  // Controladores de animación
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  Map<String, String> _errors = {};
  double _profileCompletion = 0.0;
  final AppLogger _logger = getIt<AppLogger>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedData();
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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
    _ageController.dispose();
    _idNumberController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            DialogExample.showErrorDialog(
              context,
              'Error de Registro',
              state.message,
            );
          } else if (state is AuthAuthenticated) {
            _logger.success(
              'RegistrationPage: Usuario registrado exitosamente',
            );
            _handleSuccessfulRegistration();
          }
        },
        child: Container(
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
              // Fondo animado
              RegistrationBackgroundWidget(
                pulseController: _pulseController,
                pulseAnimation: _pulseAnimation,
              ),

              // Contenido principal
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Widget del formulario (reutilizable)
                    final formWidget = Form(
                      key: _formKey,
                      child: RegistrationFormWidget(
                        currentStep: _currentStep,
                        slideAnimation: _slideAnimation,
                        fadeAnimation: _fadeAnimation,
                        isLoading: context.watch<AuthBloc>().state is AuthLoading,
                        errors: _errors,
                        profileCompletion: _profileCompletion,
                        onNextStep: _nextStep,
                        onPreviousStep: _previousStep,
                        onRegister: _register,
                        onBirthDateTap: _selectBirthDate,
                        onFieldChanged: _onFieldChanged,
                        onBackToLogin: _backToLogin,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        phoneController: _phoneController,
                        locationController: _locationController,
                        birthDateController: _birthDateController,
                        ageController: _ageController,
                        idNumberController: _idNumberController,
                        motherNameController: _motherNameController,
                      ),
                    );
                    
                    // En pantallas muy pequeñas, usar SingleChildScrollView directamente
                    // En pantallas más grandes, usar Center para centrar verticalmente
                    final isShortScreen = constraints.maxHeight < 700;
                    
                    if (isShortScreen) {
                      return SingleChildScrollView(child: formWidget);
                    } else {
                      return Center(
                        child: SingleChildScrollView(child: formWidget),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 1) { // Reducido de 2 a 1 paso
        // Animación de salida suave
        _slideController.reverse().then((_) {
          setState(() {
            _currentStep++;
          });
          // Animación de entrada suave
          _slideController.forward();
          _saveFormData(); // Guardar datos automáticamente
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      // Animación de salida suave
      _slideController.reverse().then((_) {
        setState(() {
          _currentStep--;
        });
        // Animación de entrada suave
        _slideController.forward();
        _saveFormData(); // Guardar datos automáticamente
      });
    }
  }

  void _onFieldChanged(String field) {
    // Limpiar error del campo cuando el usuario empiece a escribir
    if (_errors.containsKey(field)) {
      setState(() {
        _errors.remove(field);
      });
    }
    // Actualizar progreso de completitud
    _updateProfileCompletion();
  }

  void _updateProfileCompletion() {
    int completedFields = 0;
    int totalFields = 4; // Reducido a 4 campos: Name, Email, Password, BirthDate

    // Campos obligatorios
    if (_nameController.text.trim().isNotEmpty) completedFields++;
    if (_emailController.text.trim().isNotEmpty) completedFields++;
    if (_passwordController.text.isNotEmpty) completedFields++;
    if (_birthDateController.text.isNotEmpty) completedFields++;

    setState(() {
      _profileCompletion = completedFields / totalFields;
    });
  }

  bool _validateCurrentStep() {
    Map<String, String> newErrors = {};

    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          newErrors['name'] = 'auth.register.validation.nameRequired'.tr();
        }
        if (_emailController.text.trim().isEmpty) {
          newErrors['email'] = 'auth.register.validation.emailRequired'.tr();
        } else if (!RegExp(r'^[\w-\.\+]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text.trim())) {
          newErrors['email'] = 'auth.register.validation.emailInvalid'.tr();
        }
        if (_passwordController.text.isEmpty) {
          newErrors['password'] = 'auth.register.validation.passwordRequired'.tr();
        } else if (_passwordController.text.length < 6) {
          newErrors['password'] = 'auth.register.validation.passwordShort'.tr();
        }
        break;
      case 1:
        if (_birthDateController.text.trim().isEmpty) {
          newErrors['birthDate'] = 'auth.register.validation.birthDateRequired'.tr();
        } else {
          try {
            final date = DateTime.parse(_birthDateController.text.trim());
            final now = DateTime.now();
            if (date.isAfter(now)) {
              newErrors['birthDate'] = 'La fecha de nacimiento no puede ser futura';
            } else if (now.year - date.year < 16) {
              newErrors['birthDate'] = 'Debes tener al menos 16 años para registrarte';
            }
          } catch (e) {
            newErrors['birthDate'] = 'Formato de fecha inválido';
          }
        }
        break;
    }

    setState(() {
      _errors = newErrors;
    });

    return _errors.isEmpty;
  }

  void _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
        // Calcular edad automáticamente
        final now = DateTime.now();
        int age = now.year - date.year;
        if (now.month < date.month ||
            (now.month == date.month && now.day < date.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  void _register() async {
    // Mostrar pantalla de confirmación antes del registro
    final confirmed = await _showDataConfirmationDialog();
    if (!confirmed) return;

    // Validar todos los pasos
    bool isValid = true;
    for (int i = 0; i <= _currentStep; i++) {
      int tempStep = _currentStep;
      _currentStep = i;
      if (!_validateCurrentStep()) {
        isValid = false;
      }
      _currentStep = tempStep;
    }

    if (!isValid) {
      return;
    }

    // Verificar conectividad
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.isConnected();

    if (!mounted) return;

    if (!isConnected) {
      DialogExample.showNetworkErrorDialog(context);
      return;
    }

    // Marcar que es un registro nuevo ANTES de registrar
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_new_registration', true);
    _logger.d(
      'RegistrationPage: Flag is_new_registration marcado ANTES del registro',
    );

    if (!mounted) return;

    // Registrar usuario
    // Registrar usuario
    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        phone: null,
        location: null,
        idNumber: null,
        motherName: null,
      ),
    );
  }

  Future<bool> _showDataConfirmationDialog() async {
    final isTablet = ResponsiveHelper.isTablet(context);
    final dialogWidth = isTablet ? 500.0 : double.infinity;

    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
                      context,
                      small: 24,
                      medium: 32,
                      large: 40,
  
                    )),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Icono de confirmación
                      Container(
                        width: ResponsiveHelper.getResponsiveValue(context, small: 60, medium: 70, large: 80),
                        height: ResponsiveHelper.getResponsiveValue(context, small: 60, medium: 70, large: 80),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF4FD1C7), Color(0xFF1A365D)],
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: ResponsiveHelper.getResponsiveValue(context, small: 30, medium: 35, large: 40),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveValue(context, small: 20, medium: 24, large: 28)),
      
                      // Título
                      Text(
                        'auth.register.confirmRegistration'.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A365D),
                        ),
                      ),
      
                      SizedBox(height: ResponsiveHelper.getResponsiveValue(context, small: 16, medium: 20, large: 24)),
      
                      // Resumen de datos
                      Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(context, small: 16, medium: 20, large: 24)),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildConfirmationRow(
                              '${'profile.name'.tr()}:',
                              _nameController.text.trim(),
                            ),
                            _buildConfirmationRow(
                              '${'profile.email'.tr()}:',
                              _emailController.text.trim(),
                            ),
                            _buildConfirmationRow(
                              '${'profile.birthDate'.tr()}:',
                              _birthDateController.text.trim(),
                            ),
                          ],
                        ),
                      ),
      
                      SizedBox(height: ResponsiveHelper.getResponsiveValue(context, small: 20, medium: 24, large: 28)),
      
                      // Texto de confirmación
                      Text(
                        'auth.register.confirmRegistrationMessage'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
      
                      SizedBox(height: ResponsiveHelper.getResponsiveValue(context, small: 24, medium: 32, large: 40)),
      
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'common.cancel'.tr(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FD1C7),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'auth.register.confirm'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ))) ??
        false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveHelper.getResponsiveValue(context, small: 120, medium: 140, large: 160),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A365D),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey, 
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _backToLogin() {
    Navigator.of(context).pop();
  }

  Future<void> _handleSuccessfulRegistration() async {
    _logger.d('RegistrationPage: Manejando registro exitoso...');

    // Limpiar datos guardados después del registro exitoso
    await _clearSavedData();

    if (!mounted) return;

    // Navegar directamente al onboarding sin mostrar diálogo de éxito
    _logger.d('RegistrationPage: Navegando a onboarding...');
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _nameController.text = prefs.getString('reg_name') ?? '';
      _emailController.text = prefs.getString('reg_email') ?? '';
      _phoneController.text = prefs.getString('reg_phone') ?? '';
      _locationController.text = prefs.getString('reg_location') ?? '';
      _birthDateController.text = prefs.getString('reg_birth_date') ?? '';
      _ageController.text = prefs.getString('reg_age') ?? '';
      _idNumberController.text = prefs.getString('reg_id_number') ?? '';
      _motherNameController.text = prefs.getString('reg_mother_name') ?? '';
      _currentStep = prefs.getInt('reg_current_step') ?? 0;
    } catch (e) {
      // Error al cargar datos guardados, continuar normalmente
    }
  }

  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reg_name', _nameController.text);
      await prefs.setString('reg_email', _emailController.text);
      await prefs.setString('reg_phone', _phoneController.text);
      await prefs.setString('reg_location', _locationController.text);
      await prefs.setString('reg_birth_date', _birthDateController.text);
      await prefs.setString('reg_age', _ageController.text);
      await prefs.setString('reg_id_number', _idNumberController.text);
      await prefs.setString('reg_mother_name', _motherNameController.text);
      await prefs.setInt('reg_current_step', _currentStep);
    } catch (e) {
      // Error al guardar datos, continuar normalmente
    }
  }

  Future<void> _clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reg_name');
      await prefs.remove('reg_email');
      await prefs.remove('reg_phone');
      await prefs.remove('reg_location');
      await prefs.remove('reg_birth_date');
      await prefs.remove('reg_age');
      await prefs.remove('reg_id_number');
      await prefs.remove('reg_mother_name');
      await prefs.remove('reg_current_step');

      // Limpiar flag de onboarding para que el nuevo usuario vea el onboarding
      await prefs.remove('onboarding_completed');
      _logger.d(
        'RegistrationPage: Flag de onboarding limpiado para nuevo usuario',
      );
    } catch (e) {
      // Error al limpiar datos, continuar normalmente
    }
  }
}
