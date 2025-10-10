import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/connectivity_service.dart';
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
            print('🔍 RegistrationPage: Usuario registrado exitosamente');
            _clearSavedData(); // Limpiar datos guardados después del registro exitoso
            DialogExample.showRegistrationSuccessDialog(context, () {
              print('🔍 RegistrationPage: Navegando a onboarding...');
              Navigator.of(context).pushReplacementNamed('/onboarding');
            });
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
                child: SingleChildScrollView(
                  child: Form(
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
                  ),
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
      if (_currentStep < 2) {
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
    int totalFields = 8; // Total de campos del formulario

    // Campos obligatorios
    if (_nameController.text.trim().isNotEmpty) completedFields++;
    if (_emailController.text.trim().isNotEmpty) completedFields++;
    if (_passwordController.text.isNotEmpty) completedFields++;
    if (_birthDateController.text.trim().isNotEmpty) completedFields++;

    // Campos opcionales
    if (_phoneController.text.trim().isNotEmpty) completedFields++;
    if (_locationController.text.trim().isNotEmpty) completedFields++;
    if (_idNumberController.text.trim().isNotEmpty) completedFields++;
    if (_motherNameController.text.trim().isNotEmpty) completedFields++;

    setState(() {
      _profileCompletion = completedFields / totalFields;
    });
  }

  bool _validateCurrentStep() {
    Map<String, String> errors = {};

    switch (_currentStep) {
      case 0:
        // Validar paso 1: información básica (OBLIGATORIOS)
        if (_nameController.text.trim().isEmpty) {
          errors['name'] = 'El nombre es requerido';
        } else if (_nameController.text.trim().length < 3) {
          errors['name'] = 'El nombre debe tener al menos 3 caracteres';
        }

        if (_emailController.text.trim().isEmpty) {
          errors['email'] = 'El email es requerido';
        } else if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_emailController.text.trim())) {
          errors['email'] = 'Por favor ingresa un email válido';
        }

        if (_passwordController.text.isEmpty) {
          errors['password'] = 'La contraseña es requerida';
        } else if (_passwordController.text.length < 6) {
          errors['password'] = 'La contraseña debe tener al menos 6 caracteres';
        }
        break;

      case 1:
        // Validar paso 2: datos personales
        if (_phoneController.text.isNotEmpty) {
          if (!RegExp(r'^\d{8}$').hasMatch(_phoneController.text.trim())) {
            errors['phone'] = 'Formato de teléfono inválido (8 dígitos)';
          }
        }

        if (_ageController.text.isNotEmpty) {
          int? age = int.tryParse(_ageController.text.trim());
          if (age == null || age < 16 || age > 50) {
            errors['age'] = 'La edad debe estar entre 16 y 50 años';
          }
        }

        // FECHA DE NACIMIENTO OBLIGATORIA
        if (_birthDateController.text.trim().isEmpty) {
          errors['birthDate'] = 'La fecha de nacimiento es requerida';
        } else {
          // Validar formato de fecha
          try {
            final date = DateTime.parse(_birthDateController.text.trim());
            final now = DateTime.now();
            if (date.isAfter(now)) {
              errors['birthDate'] =
                  'La fecha de nacimiento no puede ser futura';
            } else if (now.year - date.year > 100) {
              errors['birthDate'] =
                  'La fecha de nacimiento no puede ser anterior a 100 años';
            } else if (now.year - date.year < 16) {
              errors['birthDate'] =
                  'Debes tener al menos 16 años para registrarte';
            }
          } catch (e) {
            errors['birthDate'] = 'Formato de fecha inválido';
          }
        }
        break;

      case 2:
        // Validar paso 3: información adicional (opcional)
        if (_idNumberController.text.isNotEmpty) {
          if (!RegExp(r'^\d{8,9}$').hasMatch(_idNumberController.text.trim())) {
            errors['idNumber'] = 'Formato de cédula inválido (8-9 dígitos)';
          }
        }
        break;
    }

    setState(() {
      _errors = errors;
    });

    return errors.isEmpty;
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

    if (!isConnected) {
      DialogExample.showNetworkErrorDialog(context);
      return;
    }

    // Registrar usuario
    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        idNumber: _idNumberController.text.trim().isNotEmpty
            ? _idNumberController.text.trim()
            : null,
        motherName: _motherNameController.text.trim().isNotEmpty
            ? _motherNameController.text.trim()
            : null,
      ),
    );
  }

  Future<bool> _showDataConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FD1C7), Color(0xFF1A365D)],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Confirmar Registro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Resumen de datos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConfirmationRow(
                          'Nombre:',
                          _nameController.text.trim(),
                        ),
                        _buildConfirmationRow(
                          'Email:',
                          _emailController.text.trim(),
                        ),
                        _buildConfirmationRow(
                          'Fecha de nacimiento:',
                          _birthDateController.text.trim(),
                        ),
                        if (_phoneController.text.trim().isNotEmpty)
                          _buildConfirmationRow(
                            'Teléfono:',
                            _phoneController.text.trim(),
                          ),
                        if (_locationController.text.trim().isNotEmpty)
                          _buildConfirmationRow(
                            'Ubicación:',
                            _locationController.text.trim(),
                          ),
                        if (_motherNameController.text.trim().isNotEmpty)
                          _buildConfirmationRow(
                            'Nombre de la madre:',
                            _motherNameController.text.trim(),
                          ),
                        if (_idNumberController.text.trim().isNotEmpty)
                          _buildConfirmationRow(
                            'Cédula:',
                            _idNumberController.text.trim(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Texto de confirmación
                  const Text(
                    '¿Estás seguro de que quieres crear tu cuenta con esta información?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
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
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
        ) ??
        false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A365D),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _backToLogin() {
    Navigator.of(context).pop();
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
      print(
        '🔍 RegistrationPage: Flag de onboarding limpiado para nuevo usuario',
      );
    } catch (e) {
      // Error al limpiar datos, continuar normalmente
    }
  }
}
