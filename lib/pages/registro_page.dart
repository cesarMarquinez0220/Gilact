import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../alerta_dialoge.dart';
import 'login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../gradient.dart';

class RegistroAPP extends StatefulWidget {
  // ignore: use_super_parameters
  const RegistroAPP({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegistroAPPState createState() => _RegistroAPPState();
}

class _RegistroAPPState extends State<RegistroAPP> with TickerProviderStateMixin {
  TextEditingController _birthdateController = TextEditingController();
  late FocusNode _birthdateFocusNode;
  AnimationController? _animationController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _birthdateController = TextEditingController();
    _birthdateFocusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
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
      begin: 80.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));
    
    _animationController!.forward();
  }

  TextEditingController usuarioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController nombreMadreController = TextEditingController();
  TextEditingController fechaNacimientoController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  SwiperController swiperController = SwiperController();
  int currentIndex = 0; //indicador de numeros de puntos

  @override
  void dispose() {
    _animationController?.dispose();
    _pulseController?.dispose();
    _birthdateController.dispose();
    _birthdateFocusNode.dispose();
    cedulaController.dispose();
    super.dispose();
  }

  // constructor del indicador
  Widget buildIndicatorRow() {
    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                width: index == currentIndex ? 16.0 : 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: index == currentIndex
                        ? [
                            const Color.fromRGBO(27, 167, 214, 1),
                            const Color.fromRGBO(15, 120, 160, 1),
                          ]
                        : [
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.2),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: index == currentIndex
                          ? const Color.fromRGBO(27, 167, 214, 0.3)
                          : Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

// funcion para validar la cedula
  bool isValidCedula(String cedula) {
    RegExp regex = RegExp(
        r'^\d{7}$'); // Formato para personas naturales sin la primera letra
    return regex.hasMatch(cedula);
  }

// funcion para validar correo electronico
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // ignore: non_constant_identifier_names
  final Firebase = FirebaseFirestore.instance;
  // Función para crear usuarios de prueba (versión offline)
  Future<void> _createTestUsers() async {
    try {
      print('Creando usuarios de prueba (modo offline)...');
      
      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));
      
      List<Map<String, dynamic>> testUsers = [
        {
          'usuario': 'admin_test',
          'email': 'admin@test.com',
          'contrasena': '123456',
          'nombre madre': 'María García',
          'fechaNacimiento': '1990-05-15',
          'edad': 33,
          'cedula': '1-2345-6789',
          'ubicacion': 'San José, Costa Rica',
          'telefono': '88887777',
          'fechaRegistro': DateTime.now().toIso8601String(),
        },
        {
          'usuario': 'user_demo',
          'email': 'demo@gilact.com',
          'contrasena': 'demo123',
          'nombre madre': 'Ana López',
          'fechaNacimiento': '1985-08-22',
          'edad': 38,
          'cedula': '2-3456-7890',
          'ubicacion': 'Cartago, Costa Rica',
          'telefono': '77776666',
          'fechaRegistro': DateTime.now().toIso8601String(),
        },
        {
          'usuario': 'test_user',
          'email': 'test@example.com',
          'contrasena': 'test123',
          'nombre madre': 'Carmen Rodríguez',
          'fechaNacimiento': '1992-12-03',
          'edad': 31,
          'cedula': '3-4567-8901',
          'ubicacion': 'Alajuela, Costa Rica',
          'telefono': '66665555',
          'fechaRegistro': DateTime.now().toIso8601String(),
        }
      ];

      // Intentar crear en Firebase, pero manejar errores de conectividad
      try {
        for (var userData in testUsers) {
          // Verificar si el usuario ya existe
          QuerySnapshot existingUser = await Firebase.collection('Users')
              .where('email', isEqualTo: userData['email'])
              .get()
              .timeout(const Duration(seconds: 5));
          
          if (existingUser.docs.isEmpty) {
            await Firebase.collection('Users')
                .add(userData)
                .timeout(const Duration(seconds: 5));
            print('✓ Usuario creado en Firebase: ${userData['email']}');
          } else {
            print('⚠️ Usuario ya existe en Firebase: ${userData['email']}');
          }
        }
        
        // Si llegamos aquí, Firebase funcionó
        // ignore: use_build_context_synchronously
        DialogExample.showSuccessDialog(
          context,
          '¡Usuarios Creados en Firebase!',
          'Se han creado los siguientes usuarios:\n\n'
          '• admin@test.com (123456)\n'
          '• demo@gilact.com (demo123)\n'
          '• test@example.com (test123)\n\n'
          'Puedes usar cualquiera para hacer login.',
          null,
        );
        
      } catch (e) {
        print('Error de conectividad con Firebase: $e');
        
        // Modo offline - mostrar información sin crear en Firebase
        // ignore: use_build_context_synchronously
        DialogExample.showInfoDialog(
          context,
          'Modo Sin Conexión',
          'No hay conexión a internet. Aquí están las credenciales de prueba:\n\n'
          '📧 admin@test.com\n🔑 123456\n\n'
          '📧 demo@gilact.com\n🔑 demo123\n\n'
          '📧 test@example.com\n🔑 test123\n\n'
          'Nota: Los usuarios se crearán cuando haya conexión.',
        );
      }
      
    } catch (e) {
      print('Error general creando usuarios de prueba: $e');
      // ignore: use_build_context_synchronously
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudieron crear los usuarios de prueba. Revisa la conexión a internet.',
      );
    }
  }

  //funcion para enviar los datos a la base de datos
  _registerMDButtonPressed() async {
    print('=== INICIANDO PROCESO DE REGISTRO ===');
    
    // Validar que todos los campos estén llenos
    if (usuarioController.text.isEmpty ||
        emailController.text.isEmpty ||
        contrasenaController.text.isEmpty ||
        nombreMadreController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        edadController.text.isEmpty ||
        cedulaController.text.isEmpty ||
        ubicacionController.text.isEmpty ||
        telefonoController.text.isEmpty) {
      print('ERROR: Campos vacíos detectados');
      print('Usuario: "${usuarioController.text}"');
      print('Email: "${emailController.text}"');
      print('Contraseña: "${contrasenaController.text}"');
      print('Nombre madre: "${nombreMadreController.text}"');
      print('Fecha nacimiento: "${_birthdateController.text}"');
      print('Edad: "${edadController.text}"');
      print('Cédula: "${cedulaController.text}"');
      print('Ubicación: "${ubicacionController.text}"');
      print('Teléfono: "${telefonoController.text}"');
      
      DialogExample.showAlertDialog(
        context,
        'Campos Incompletos',
        'Por favor, completa todos los campos para continuar con el registro.',
      );
      return false;
    }

    print('✓ Todos los campos están llenos');

    // Validar formato de email
    if (!_isValidEmail(emailController.text)) {
      print('ERROR: Email inválido: ${emailController.text}');
      DialogExample.showInvalidEmailDialog(context);
      return false;
    }

    print('✓ Email válido: ${emailController.text}');

    try {
      print('Iniciando conexión con Firebase...');
      
      // Verificar si el email ya existe
      print('Verificando si el email ya existe...');
      QuerySnapshot emailCheck = await Firebase.collection('Users')
          .where('email', isEqualTo: emailController.text)
          .get();
      
      print('Resultado de verificación de email: ${emailCheck.docs.length} documentos encontrados');
      
      if (emailCheck.docs.isNotEmpty) {
        print('ERROR: Email ya registrado');
        // ignore: use_build_context_synchronously
        DialogExample.showUserAlreadyExistsDialog(context);
        return false;
      }

      print('✓ Email disponible, procediendo con el registro...');

      // Preparar datos para guardar
      Map<String, dynamic> userData = {
        'usuario': usuarioController.text,
        'email': emailController.text,
        'contrasena': contrasenaController.text,
        'nombre madre': nombreMadreController.text,
        'fechaNacimiento': _birthdateController.text,
        'edad': int.parse(edadController.text),
        'cedula': cedulaController.text,
        'ubicacion': ubicacionController.text,
        'telefono': telefonoController.text,
        'fechaRegistro': DateTime.now().toIso8601String(),
      };

      print('Datos a guardar: $userData');

      // Crear el documento del usuario
      DocumentReference docRef = await Firebase.collection('Users').add(userData);
      
      print('✓ Usuario registrado exitosamente con ID: ${docRef.id}');
      
      // Mostrar mensaje de éxito con el nuevo diálogo
      // ignore: use_build_context_synchronously
      DialogExample.showRegistrationSuccessDialog(
        context,
        () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
      );
      
      // Limpiar los controladores
      usuarioController.clear();
      emailController.clear();
      contrasenaController.clear();
      nombreMadreController.clear();
      _birthdateController.clear();
      edadController.clear();
      cedulaController.clear();
      ubicacionController.clear();
      telefonoController.clear();
      
      print('✓ Controladores limpiados');
      return true;
    } catch (e) {
      print('❌ ERROR EN REGISTRO: $e');
      print('Stack trace: ${StackTrace.current}');
      
      // ignore: use_build_context_synchronously
      DialogExample.showErrorDialog(
        context,
        'Error de Registro',
        'Ocurrió un error inesperado durante el registro. Por favor, verifica tu conexión e inténtalo nuevamente.',
      );
      return false;
    }
  }

  //////////////////////construcor principal//////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: Gradients.myGradient,
        ),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            _buildBackgroundElements(),
            // Contenido principal
            ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                AnimatedBuilder(
                  animation: _slideAnimation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation!.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation!,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/logo-completo2.png",
                            alignment: Alignment.center,
                            height: 0.2 * MediaQuery.of(context).size.height,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Swiper(
                      controller: swiperController,
                      onIndexChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return buildFirstCard();
                        } else {
                          return buildSecondCard();
                        }
                      },
                      viewportFraction: 0.85,
                      loop: false,
                      layout: SwiperLayout.DEFAULT,
                      itemWidth: null,
                      itemHeight: null,
                      scale: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                buildIndicatorRow(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Elementos decorativos de fondo
  Widget _buildBackgroundElements() {
    if (_pulseController == null || _pulseAnimation == null) {
      return const SizedBox.shrink();
    }
    
    return Stack(
      children: [
        // Círculos decorativos animados
        AnimatedBuilder(
          animation: _pulseController!,
          builder: (context, child) {
            return Positioned(
              top: -120,
              left: -120,
              child: Transform.scale(
                scale: _pulseController!.isAnimating ? _pulseAnimation!.value : 1.0,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _pulseController!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pulseController!.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Partículas flotantes
        if (_pulseController != null)
          ...List.generate(8, (index) => _buildFloatingParticle(index)),
      ],
    );
  }

  Widget _buildFloatingParticle(int index) {
    if (_pulseController == null) return const SizedBox.shrink();
    
    final random = math.Random(index + 10);
    final size = 3.0 + random.nextDouble() * 6.0;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final top = random.nextDouble() * MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (context, child) {
        final animationValue = _pulseController!.isAnimating ? _pulseController!.value : 0.0;
        final calculatedOpacity = 0.2 + math.sin(animationValue * 2 * math.pi + index) * 0.2;
        final clampedOpacity = calculatedOpacity.clamp(0.0, 1.0);
        
        return Positioned(
          left: left + math.sin(animationValue * 2 * math.pi + index) * 25,
          top: top + math.cos(animationValue * 2 * math.pi + index) * 20,
          child: Opacity(
            opacity: clampedOpacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// primer card
  Widget buildFirstCard() {
    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation!.value * 0.3),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Botón temporal para crear usuarios de prueba
                      GestureDetector(
                        onTap: _createTestUsers,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            'TEST',
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _buildInputField(
                    hintText: "Usuario",
                    icon: Icons.person,
                    controller: usuarioController,
                  ),
                  const SizedBox(height: 4),
                  _buildInputField(
                    hintText: "Email",
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),
                  const SizedBox(height: 4),
                  _buildInputField(
                    hintText: "Contraseña",
                    icon: Icons.work_outline,
                    obscureText: true,
                    controller: contrasenaController,
                  ),
                  const SizedBox(height: 35.0),
                  _buildButton(context, 'Siguiente'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSecondCard() {
    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation!.value * 0.3),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Datos Personales',
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      hintText: "Nombre de la madre",
                      icon: Icons.pregnant_woman,
                      controller: nombreMadreController,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            hintText: "Fecha de nacimiento",
                            icon: Icons.calendar_today,
                            controller: _birthdateController,
                            focusNode: _birthdateFocusNode,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: _buildInputField(
                            hintText: "Edad",
                            icon: Icons.portrait,
                            controller: edadController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              AgeInputFormatter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(
                      hintText: "Cédula",
                      icon: Icons.credit_card,
                      controller: cedulaController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                        CustomCedulaInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(
                      hintText: "Ubicación",
                      icon: Icons.location_on_outlined,
                      controller: ubicacionController,
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(
                      hintText: "Teléfono Celular",
                      icon: Icons.phone,
                      controller: telefonoController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildButton(context, 'Registrar'),
                    const SizedBox(height: 25),
                    _buildSignUpText(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //constructor para redigir a la pagina de inicio
  Widget _buildSignUpText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ya tienes una cuenta?',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Text(
            ' Ingresa',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color.fromRGBO(27, 167, 214, 1),
            ),
          ),
        ],
      ),
    );
  }

  //constructor de los campos
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onTap: onTap,
        obscureText: obscureText,
        validator: validator,
        inputFormatters: inputFormatters,
        style: GoogleFonts.quicksand(
          fontSize: 15,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 15,
            color: Colors.black54,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(27, 167, 214, 0.2),
                  const Color.fromRGBO(27, 167, 214, 0.1),
                ],
              ),
            ),
            child: Icon(
              icon,
              color: const Color.fromRGBO(27, 167, 214, 1),
              size: 18.0,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  // constructor del boton de registro
  Widget _buildButton(BuildContext context, String text) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(27, 167, 214, 1),
            Color.fromRGBO(20, 140, 180, 1),
            Color.fromRGBO(15, 120, 160, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(27, 167, 214, 0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Siguiente') {
            swiperController.next();
          } else {
            _registerMDButtonPressed();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  //funcion para el selector de la fecha
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _birthdateController.text = formattedDate;
      });
    }
  }
}

//clase para validar datos de cedula
class CustomCedulaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyCustomCedulaFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyCustomCedulaFormat(String input) {
    input = input.replaceAll('-', ''); // Elimina guiones existentes
    final length = input.length;

    if (length <= 3) {
      return input;
    } else if (length <= 6) {
      return '${input.substring(0, 1)}-${input.substring(1, length)}';
    } else if (length <= 9) {
      return '${input.substring(0, 1)}-${input.substring(1, 4)}-${input.substring(4, length)}';
    } else if (length <= 12) {
      return '${input.substring(0, 1)}-${input.substring(1, 4)}-${input.substring(4, 7)}-${input.substring(7, length)}';
    }
    return '${input.substring(0, 1)}-${input.substring(1, 4)}-${input.substring(4, 7)}-${input.substring(7, 10)}';
  }
}

//clase para ajustar la edad
class AgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyAgeFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyAgeFormat(String input) {
    final length = input.length;
    if (length <= 3) {
      final age = int.tryParse(input) ?? 0;
      if (age > 100) {
        return '100';
      }
      return input;
    }
    return input.substring(0, 3); // Limita a 3 dígitos
  }
}

//clase para limitar el campo a 8 digitos
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyPhoneFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyPhoneFormat(String input) {
    final length = input.length;
    if (length <= 8) {
      return input;
    }
    return input.substring(0, 8); // Limita a 8 dígitos
  }
}
