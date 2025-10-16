import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/services/auth_validation_service.dart';
import '../../domain/services/credentials_cache_service.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_background_widget.dart';
import '../widgets/login_form_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _saveCredentials = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCachedCredentials();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadCachedCredentials() async {
    final shouldSave = await CredentialsCacheService.shouldSaveCredentials();
    if (shouldSave) {
      final cachedEmail =
          await CredentialsCacheService.loadCredentialsFromCache();
      if (cachedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = cachedEmail;
          _saveCredentials = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
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
            // Fondo animado
            LoginBackgroundWidget(
              pulseController: _pulseController,
              pulseAnimation: _pulseAnimation,
            ),

            // Contenido principal
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  setState(() {
                    _isLoading = false;
                  });

                  // Guardar credenciales si está marcado
                  if (_saveCredentials) {
                    print('🔍 LoginPage: Guardando credenciales en caché...');
                    print(
                      '🔍 LoginPage: Email a guardar: "${_emailController.text.trim()}"',
                    );
                    CredentialsCacheService.saveCredentialsInCache(
                      _emailController.text.trim(),
                      true,
                    );
                  } else {
                    print(
                      '🔍 LoginPage: No se guardarán credenciales (_saveCredentials = false)',
                    );
                  }

                  // Guardar última vez de login
                  CredentialsCacheService.saveLastLogin();

                  // Verificar si es un registro nuevo
                  SharedPreferences.getInstance().then((prefs) async {
                    final isNewRegistration =
                        prefs.getBool('is_new_registration') ?? false;

                    if (isNewRegistration) {
                      // Es un registro nuevo, no navegar desde aquí
                      // El RegistrationPage ya se encarga de la navegación
                      print(
                        '🔍 LoginPage: Detectado registro nuevo, no navegando desde aquí',
                      );
                      await prefs.remove('is_new_registration');
                    } else {
                      // Es un login normal, navegar a welcome
                      print('🔍 LoginPage: Login normal, navegando a welcome');
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.of(context).pushReplacementNamed('/welcome');
                      });
                    }
                  });
                } else if (state is AuthLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: LoginFormWidget(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      saveCredentials: _saveCredentials,
                      slideAnimation: _slideAnimation,
                      fadeAnimation: _fadeAnimation,
                      isLoading: _isLoading,
                      emailError: _emailError,
                      passwordError: _passwordError,
                      onRecoveryTap: _resetPassword,
                      onSignUpTap: _signUp,
                      onRememberChanged: (value) {
                        setState(() {
                          _saveCredentials = value ?? false;
                        });
                      },
                      onLoginPressed: _signIn,
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

  Future<void> _signIn() async {
    // Limpiar errores previos
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validar formulario
    final errors = AuthValidationService.validateLoginForm(
      email: _emailController.text.trim(),
      contrasena: _passwordController.text,
    );

    if (errors.isNotEmpty) {
      setState(() {
        _emailError = errors['email'];
        _passwordError = errors['contrasena'];
      });
      return;
    }

    // Verificar conectividad
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.isConnected();

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sin conexión a internet'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Iniciar sesión
    context.read<AuthBloc>().add(
      SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _signUp() {
    Navigator.of(context).pushNamed('/register');
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recuperar Contraseña',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu email para recibir instrucciones de recuperación:',
              style: GoogleFonts.quicksand(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'Enviar',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
