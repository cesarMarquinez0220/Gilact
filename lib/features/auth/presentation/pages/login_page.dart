import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../../domain/services/auth_validation_service.dart';
import '../../domain/services/credentials_cache_service.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_background_widget.dart';
import '../widgets/login_form_widget.dart';
import '../../../lactation/data/services/push_notification_service.dart';

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
  bool _showBiometricButton = false;
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final AppLogger _logger = getIt<AppLogger>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCachedCredentials();
    _checkBiometricAvailability();
  }

  /// Habilita la autenticación biométrica si está disponible
  Future<void> _enableBiometricIfAvailable() async {
    try {
      final isBiometricAvailable = await _biometricAuthService
          .isBiometricAvailable();
      if (isBiometricAvailable) {
        await _biometricAuthService.setBiometricEnabled(true);
        if (mounted) {
          setState(() {
            _showBiometricButton = true;
          });
        }
        _logger.success(
          'LoginPage: Autenticación biométrica habilitada automáticamente',
        );
      } else {
        _logger.w(
          'LoginPage: Autenticación biométrica no disponible en este dispositivo',
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'LoginPage: Error habilitando autenticación biométrica',
        e,
        stackTrace,
      );
    }
  }

  /// Verifica si la autenticación biométrica está disponible y habilitada
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricAuthService.isBiometricAvailable();
      final isEnabled = await _biometricAuthService.isBiometricEnabled();
      final hasCredentials = await _biometricAuthService.hasStoredCredentials();

      // Mostrar el botón si:
      // 1. El dispositivo soporta biométrica Y
      // 2. Hay credenciales guardadas
      // (No requerimos que esté habilitada, porque el usuario puede habilitarla al usarla)
      final shouldShow = isAvailable && hasCredentials;

      if (mounted) {
        setState(() {
          _showBiometricButton = shouldShow;
        });
      }

      _logger.d('LoginPage: Autenticación biométrica disponible: $isAvailable');
      _logger.d('LoginPage: Autenticación biométrica habilitada: $isEnabled');
      _logger.d('LoginPage: Credenciales guardadas: $hasCredentials');
      _logger.d('LoginPage: Mostrar botón biométrico: $shouldShow');

      // Información adicional para depuración
      if (isAvailable) {
        final availableTypes = await _biometricAuthService
            .getAvailableBiometrics();
        _logger.d('LoginPage: Tipos biométricos disponibles: $availableTypes');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'LoginPage: Error verificando autenticación biométrica',
        e,
        stackTrace,
      );
    }
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
                } else if (state is AuthPasswordResetSent) {
                  // Resetear el estado de carga cuando se envía el reset de contraseña
                  // (el diálogo maneja su propio mensaje, pero necesitamos resetear _isLoading)
                  setState(() {
                    _isLoading = false;
                  });
                } else if (state is AuthAuthenticated) {
                  setState(() {
                    _isLoading = false;
                  });

                  // Guardar credenciales si está marcado
                  if (_saveCredentials) {
                    _logger.d('LoginPage: Guardando credenciales en caché...');
                    _logger.d(
                      'LoginPage: Email a guardar: "${_emailController.text.trim()}"',
                    );
                    CredentialsCacheService.saveCredentialsInCache(
                      _emailController.text.trim(),
                      true,
                    );

                    // Habilitar autenticación biométrica si está disponible (async sin await)
                    _enableBiometricIfAvailable();
                  } else {
                    _logger.d(
                      'LoginPage: No se guardarán credenciales (_saveCredentials = false)',
                    );
                  }

                  // Guardar última vez de login
                  CredentialsCacheService.saveLastLogin();

                  // Verificar si es un registro nuevo
                  _handlePostLoginNavigation();
                } else if (state is AuthLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Widget del formulario (reutilizable)
                    final formWidget = Form(
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
                        onBiometricPressed: _signInWithBiometrics,
                        showBiometricButton: _showBiometricButton,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePostLoginNavigation() async {
    try {
      if (!mounted) return;
      final currentContext = context;
      final navigator = Navigator.of(currentContext);

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final isNewRegistration = prefs.getBool('is_new_registration') ?? false;

      if (isNewRegistration) {
        // Es un registro nuevo, no navegar desde aquí
        // El RegistrationPage ya se encarga de la navegación
        _logger.d(
          'LoginPage: Detectado registro nuevo, no navegando desde aquí',
        );
        await prefs.remove('is_new_registration');
        if (!mounted) return;
      } else {
        // Es un login normal, verificar notificación pendiente primero
        _logger.d(
          'LoginPage: Login normal, verificando notificación pendiente...',
        );

        // Verificar si hay notificación pendiente
        if (!currentContext.mounted) return;
        await PushNotificationService.handlePendingNotification(currentContext);

        // Si no había notificación pendiente o ya fue manejada, navegar a welcome
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          if (navigator.canPop() == false) {
            // Solo navegar si no hay una navegación pendiente de la notificación
            navigator.pushReplacementNamed('/welcome');
          }
        });
      }
    } catch (e, stackTrace) {
      _logger.e('LoginPage: Error en navegación post-login', e, stackTrace);
    }
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

    // Iniciar sesión (AuthBloc manejará online/offline automáticamente)
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

  /// Inicia sesión usando autenticación biométrica
  Future<void> _signInWithBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Autenticar con biométrica
      final credentials = await _biometricAuthService
          .authenticateWithBiometrics();

      if (credentials == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final email = credentials['email'] ?? '';
      if (email.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron credenciales guardadas'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Cargar email en el campo
      _emailController.text = email;

      // Usar el AuthBloc para manejar el login biométrico
      // El bloc verificará la sesión offline y autenticará al usuario
      if (!mounted) return;
      context.read<AuthBloc>().add(BiometricSignInRequested(email: email));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en autenticación biométrica: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetPassword() {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthPasswordResetSent) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Se ha enviado un email con instrucciones para restablecer tu contraseña. Por favor revisa tu bandeja de entrada y carpeta de spam.',
                      style: GoogleFonts.quicksand(),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (state is AuthFailure) {
                setDialogState(() {
                  isSending = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is AuthLoading) {
                setDialogState(() {
                  isSending = true;
                });
              }
            },
            child: AlertDialog(
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isSending,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (isSending) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enviando solicitud...',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.quicksand(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor ingresa tu email'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          // Validar formato de email básico
                          if (!email.contains('@') || !email.contains('.')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor ingresa un email válido',
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          context.read<AuthBloc>().add(
                            ResetPasswordRequested(email: email),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.buttonDisabled,
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Enviar',
                          style: GoogleFonts.quicksand(color: Colors.white),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
