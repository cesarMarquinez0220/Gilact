// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings


import 'package:flutter/material.dart';
import 'claseGlobal/detector.dart';
import 'recuperacion.dart';
import 'registro_page.dart';
import '../gradient.dart';
import 'splash_screen.dart';
import '../alerta_dialoge.dart';
import 'login_components/login_auth_service.dart';
import 'login_components/login_background.dart';
import 'login_components/login_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Variables de control
  int loginAttempts = 0;
  bool saveCredentials = false;
  AnimationController? _animationController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  Animation<double>? _pulseAnimation;

  // Controladores
  TextEditingController emailAPP = TextEditingController();
  TextEditingController contrasena = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentialsFromCache();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));
    
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  // Cargar credenciales desde caché
  Future<void> _loadCredentialsFromCache() async {
    String cachedEmail = await LoginAuthService.loadCredentialsFromCache();
    setState(() {
      emailAPP.text = cachedEmail;
    });
  }

  // Guardar credenciales en caché
  Future<void> _saveCredentialsInCache() async {
    await LoginAuthService.saveCredentialsInCache(emailAPP.text, saveCredentials);
  }

  // Manejar el login
  Future<void> _handleLogin() async {
    if (emailAPP.text.isEmpty || contrasena.text.isEmpty) {
      DialogExample.showAlertDialog(
        context,
        'Campos Requeridos',
        'Por favor, ingresa tu email y contraseña para continuar.',
      );
      return;
    }

    bool isValid = await LoginAuthService.validateCredentials(emailAPP.text, contrasena.text);
    
    if (!isValid) {
      setState(() {
        loginAttempts++;
      });
      DialogExample.showErrorDialog(
        context,
        'Credenciales Incorrectas',
        'El email o la contraseña no son correctos. Verifica tus datos e inténtalo nuevamente.',
      );
      return;
    }

    bool foundUser = await LoginAuthService.findUserName(emailAPP.text);
    
    if (foundUser) {
      setState(() {
        loginAttempts = 0;
      });

      print('🎉 Login exitoso - navegando a WelcomeScreen');
      
      detection.login();
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      });
    } else {
      print('❌ No se pudo encontrar el usuario');
      DialogExample.showErrorDialog(
        context,
        'Error de Usuario',
        'No se pudo encontrar la información del usuario. Por favor verifica tus credenciales.',
      );
    }
  }

  // Navegar a recuperación de contraseña
  void _navigateToRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const recuperacion()),
    );
  }

  // Navegar a registro
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroAPP()),
    );
  }

  // Manejar cambio en checkbox "Recordar"
  void _onRememberChanged(bool? value) {
    setState(() {
      saveCredentials = value ?? false;
    });
    _saveCredentialsInCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: Gradientslogin.myGradient,
        ),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            LoginBackground(
              pulseController: _pulseController,
              pulseAnimation: _pulseAnimation,
            ),
            // Contenido principal
            SingleChildScrollView(
              child: LoginLayout(
                emailController: emailAPP,
                passwordController: contrasena,
                loginAttempts: loginAttempts,
                saveCredentials: saveCredentials,
                slideAnimation: _slideAnimation,
                fadeAnimation: _fadeAnimation,
                onRecoveryTap: _navigateToRecovery,
                onSignUpTap: _navigateToSignUp,
                onRememberChanged: _onRememberChanged,
                onLoginPressed: _handleLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
