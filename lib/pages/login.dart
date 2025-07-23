// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'claseGlobal/detector.dart';
import 'recuperacion.dart';
import 'registro_page.dart';
import '../gradient.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PerfilContinuacion/user_data_storage.dart';
import '../alerta_dialoge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
// variable para controlar intento de sesiones
  int loginAttempts = 0;
  bool saveCredentials = false;
  AnimationController? _animationController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  Animation<double>? _pulseAnimation;

// controladores
  TextEditingController emailAPP = TextEditingController();
  TextEditingController contrasena = TextEditingController();
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    _loadCredentialsFromCache();
    
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

  //funcion para validar datos
  validarDatos() async {
    print('🔍 Iniciando validación de credenciales...');
    print('Email: "${emailAPP.text}"');
    print('Contraseña: "${contrasena.text}"');
    
    try {
      print('🌐 Intentando conectar a Firebase...');
      // Intentar conectar a Firebase con timeout más corto
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot usuario = await ref.get().timeout(const Duration(seconds: 2));

      print('✅ Conexión a Firebase exitosa');
      // ignore: prefer_is_empty
      if (usuario.docs.length != 0) {
        //verificacion si hay docs en la base de datos
        for (var cursor in usuario.docs) {
          //iteracion para verificar informacion
          if (cursor.get('email') == emailAPP.text) {
            //verifica si es igual el texto escrito de lo que hya en la BD
            if (cursor.get('contrasena') == contrasena.text) {
              print('✅ Credenciales válidas en Firebase');
              return true; // Credenciales válidas
            }
          }
        }
        print('❌ Credenciales no encontradas en Firebase');
      } else {
        print('⚠️ NO hay docs en la coleccion Firebase');
      }
      return false; // Credenciales inválidas
    } catch (e) {
      print('🔥 Error conectando a Firebase: $e');
      print('🔄 Cambiando a modo offline...');
      
      // Modo offline - validar con usuarios hardcodeados
      return _validarDatosOffline();
    }
  }

  // Validación offline con usuarios de prueba
  bool _validarDatosOffline() {
    print('📱 === MODO OFFLINE ACTIVADO ===');
    print('Validando credenciales localmente...');
    
    Map<String, String> usuariosOffline = {
      'admin@test.com': '123456',
      'demo@gilact.com': 'demo123',
      'test@example.com': 'test123',
    };

    String email = emailAPP.text.toLowerCase().trim();
    String password = contrasena.text;

    print('Email ingresado: "$email"');
    print('Contraseña ingresada: "$password"');
    print('Usuarios disponibles offline: ${usuariosOffline.keys.toList()}');

    if (usuariosOffline.containsKey(email) && usuariosOffline[email] == password) {
      print('✅ Login offline exitoso para: $email');
      return true;
    }

    print('❌ Credenciales offline incorrectas para: $email');
    print('Contraseña esperada: "${usuariosOffline[email]}"');
    return false;
  }

//funcion para buscar el nombre de usuario a partir del correo electronico
  Future<bool> buscarNombreDeUsuario(String email) async {
    print('👤 Buscando nombre de usuario para: $email');
    
    try {
      print('🌐 Conectando a Firebase para buscar usuario...');
      // Intentar conectar a Firebase con timeout más corto
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot usuario = await ref.where('email', isEqualTo: email).get().timeout(const Duration(seconds: 2));

      if (usuario.docs.isNotEmpty) {
        // Verifica si se encontró un usuario con el correo electrónico
        String nombreUsuario = usuario.docs.first.get('usuario');

        print('✅ Usuario encontrado en Firebase: $nombreUsuario');

        // Guarda el nombre de usuario en UserDataStorage
        UserDataStorage.setUserName(nombreUsuario);
        UserDataStorage.setUserEmail(email);

        return true; // Se encontró un usuario con el correo electrónico
      } else {
        print('❌ No se encontró un usuario con el correo electrónico proporcionado en Firebase.');
        return false; // No se encontró un usuario con el correo electrónico
      }
    } catch (e) {
      print('🔥 Error en buscarNombreDeUsuario: $e');
      print('🔄 Cambiando a búsqueda offline...');
      
      // Modo offline - buscar en usuarios hardcodeados
      return _buscarNombreUsuarioOffline(email);
    }
  }

  // Búsqueda offline de nombre de usuario
  bool _buscarNombreUsuarioOffline(String email) {
    print('📱 === BÚSQUEDA OFFLINE ACTIVADA ===');
    print('Buscando nombre de usuario localmente para: $email');
    
    Map<String, String> usuariosOffline = {
      'admin@test.com': 'admin_test',
      'demo@gilact.com': 'user_demo',
      'test@example.com': 'test_user',
    };

    String emailLower = email.toLowerCase().trim();
    print('Email normalizado: $emailLower');
    print('Usuarios disponibles: ${usuariosOffline.keys.toList()}');

    if (usuariosOffline.containsKey(emailLower)) {
      String nombreUsuario = usuariosOffline[emailLower]!;
      
      print('✅ Usuario offline encontrado: $nombreUsuario');
      
      // Guarda el nombre de usuario en UserDataStorage
      UserDataStorage.setUserName(nombreUsuario);
      UserDataStorage.setUserEmail(email);
      
      return true;
    }

    print('❌ Usuario offline no encontrado para: $email');
    return false;
  }

  _saveCredentialsInCache(bool saveCredentials) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (saveCredentials) {
      prefs.setString('email', emailAPP.text);
    } else {
      prefs.remove('email');
    }
  }

  _loadCredentialsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailAPP.text = prefs.getString('email') ?? '';
    });
  }

//widget para mostrar el mensaje de error de los intentos
  Widget _buildInputFieldWithErrorMessage({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    String errorMessage = '',
  }) {
    return Column(
      children: [
        _buildInputField(
          hintText: hintText,
          icon: icon,
          controller: controller,
          obscureText: obscureText,
        ),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: errorMessage,
                    style: GoogleFonts.quicksand(color: Colors.red),
                  ),
                  if (loginAttempts >= 3)
                    TextSpan(
                      text: ' Recordar',
                      style: GoogleFonts.quicksand(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Aquí puedes agregar la navegación a la otra pantalla
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const recuperacion()),
                          );
                        },
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

//constructor que lanza el widget principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: Gradientslogin.myGradient //constante de gradient
            ),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            _buildBackgroundElements(),
            // Contenido principal
            SingleChildScrollView(
              child: OrientationBuilder(builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  // Diseño vertical (retrato)
                  return _buildPortraitLayout();
                } else {
                  // Diseño horizontal (paisaje)
                  return _buildLandscapeLayout();
                }
              }),
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
              top: -100,
              right: -100,
              child: Transform.scale(
                scale: _pulseController!.isAnimating ? _pulseAnimation!.value : 1.0,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
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
          bottom: -150,
          left: -150,
          child: AnimatedBuilder(
            animation: _pulseController!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pulseController!.value * 2 * math.pi,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
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
          ...List.generate(6, (index) => _buildFloatingParticle(index)),
      ],
    );
  }

  Widget _buildFloatingParticle(int index) {
    if (_pulseController == null) return const SizedBox.shrink();
    
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 8.0;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final top = random.nextDouble() * MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (context, child) {
        final animationValue = _pulseController!.isAnimating ? _pulseController!.value : 0.0;
        final calculatedOpacity = 0.3 + math.sin(animationValue * 2 * math.pi + index) * 0.2;
        final clampedOpacity = calculatedOpacity.clamp(0.0, 1.0);
        
        return Positioned(
          left: left + math.sin(animationValue * 2 * math.pi + index) * 20,
          top: top + math.cos(animationValue * 2 * math.pi + index) * 15,
          child: Opacity(
            opacity: clampedOpacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// widget encargado de crear el contenedor donde se coloca la informacion asi como su diseno
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
  }) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    if (_slideAnimation == null || _fadeAnimation == null) {
      return Container(
        height: height * .07,
        width: width * .8,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.quicksand(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 18,
              color: Colors.black54,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.black54,
              size: 24.0,
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

    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation!.value),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Container(
              height: height * .07,
              width: width * .8,
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
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
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
                      size: 20.0,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // widget encargado del boton para enviar los datos y su diseño
  Widget _buildButton(BuildContext context, String text) {
    final double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation!.value),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Padding(
              padding: EdgeInsets.only(right: width * .05, left: width * .05),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
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
                  onPressed: () async {
                    if (emailAPP.text.isEmpty || contrasena.text.isEmpty) {
                      DialogExample.showAlertDialog(
                        context,
                        'Campos Requeridos',
                        'Por favor, ingresa tu email y contraseña para continuar.',
                      );
                    } else {
                      bool isValid = await validarDatos();
                      if (!isValid) {
                        setState(() {
                          loginAttempts++; // Incrementar el contador de intentos
                        });
                        // ignore: use_build_context_synchronously
                        DialogExample.showErrorDialog(
                          context,
                          'Credenciales Incorrectas',
                          'El email o la contraseña no son correctos. Verifica tus datos e inténtalo nuevamente.',
                        );
                      } else {
                        bool foundUser = await buscarNombreDeUsuario(emailAPP.text);
                        //query para extraer el nombre de usuario a partir del correo
                        if (foundUser) {
                          setState(() {
                            loginAttempts = 0; // Restablecer el contador de intentos
                          });

                          print('🎉 Login exitoso - navegando a WelcomeScreen');
                          
                          // inicio de sesión exitoso
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
                          // ignore: use_build_context_synchronously
                          DialogExample.showErrorDialog(
                            context,
                            'Error de Usuario',
                            'No se pudo encontrar la información del usuario. Por favor verifica tus credenciales.',
                          );
                        }
                      }
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
              ),
            ),
          ),
        );
      },
    );
  }

// widget que pone las palabras de abajo si no tiene cuenta y redirige
  Widget _buildSignUpText(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation!.value),
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroAPP(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Aún no tienes una cuenta?',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    ' Aquí',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color.fromRGBO(27, 167, 214, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //orientacion vertical
  Widget _buildPortraitLayout() {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          bottom: 30,
          left: 20,
          right: 20),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                        height: 0.3 * MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.05,
            ),
            AnimatedBuilder(
              animation: _slideAnimation!,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation!.value * 0.5),
                  child: FadeTransition(
                    opacity: _fadeAnimation!,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          Text(
                            'Ingresar',
                            style: GoogleFonts.quicksand(
                              fontSize: 33,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 35),
                          _buildInputField(
                            hintText: "Email",
                            icon: Icons.mail_outline,
                            controller: emailAPP,
                          ),
                          const SizedBox(height: 4),
                          _buildInputFieldWithErrorMessage(
                            hintText: "Password",
                            icon: Icons.lock_outline,
                            obscureText: true,
                            controller: contrasena,
                            errorMessage:
                                loginAttempts >= 3 ? 'Contraseña incorrecta?' : '',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 45),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                      ),
                                    ),
                                  ),
                                  child: Checkbox(
                                    side: BorderSide(
                                      color: Colors.blue.withOpacity(0.7),
                                      width: 2.0,
                                    ),
                                    activeColor: const Color.fromRGBO(27, 167, 214, 0.8),
                                    value: saveCredentials,
                                    onChanged: (value) {
                                      setState(() {
                                        saveCredentials = value!;
                                      });
                                      _saveCredentialsInCache(saveCredentials);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recordar',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          _buildButton(context, 'Entrar'),
                          const SizedBox(height: 35),
                          _buildSignUpText(context),
                          const SizedBox(height: 45),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //orientacion horizontal
  Widget _buildLandscapeLayout() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _slideAnimation!,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation!.value),
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
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
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Text(
                                'Ingresar',
                                style: GoogleFonts.quicksand(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            _buildInputField(
                              hintText: "Email",
                              icon: Icons.mail_outline,
                              controller: emailAPP,
                            ),
                            const SizedBox(height: 15),
                            _buildInputField(
                              hintText: "Password",
                              icon: Icons.lock_outline,
                              obscureText: true,
                              controller: contrasena,
                            ),
                            const SizedBox(height: 25),
                            _buildButton(context, 'Entrar'),
                            const SizedBox(height: 25),
                            _buildSignUpText(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
