import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:flutter_login/pages/recuperacion.dart';
import 'package:flutter_login/pages/registro_page.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'PerfilContinuacion/user_data_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
// variable para controlar intento de sesiones
  int loginAttempts = 0;
// controladores
  TextEditingController emailAPP = TextEditingController();
  TextEditingController contrasena = TextEditingController();
  String nombreUsuario = '';
//funcion para buscar el nombre de usuario a partir del correo electronico
  Future<bool> buscarNombreDeUsuario(String email) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot usuario = await ref.where('email', isEqualTo: email).get();

      if (usuario.docs.isNotEmpty) {
        // Verifica si se encontró un usuario con el correo electrónico
        String nombreUsuario = usuario.docs.first.get('usuario');

        // Guarda el nombre de usuario en UserDataStorage
        UserDataStorage.setUserName(nombreUsuario);
        UserDataStorage.setUserEmail(email);

        return true; // Se encontró un usuario con el correo electrónico
      } else {
        print(
            'No se encontró un usuario con el correo electrónico proporcionado.');
        return false; // No se encontró un usuario con el correo electrónico
      }
    } catch (e) {
      print('Error: $e');
      return false; // Error al buscar el nombre de usuario
    }
  }

//funcion para validar datos
  validarDatos() async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot usuario = await ref.get();

      if (usuario.docs.length != 0) {
        //verificacion si hay docs en la base de datos
        for (var cursor in usuario.docs) {
          //iteracion para verificar informacion
          if (cursor.get('email') == emailAPP.text) {
            //verifica si es igual el texto escrito de lo que hya en la BD
            if (cursor.get('contrasena') == contrasena.text) {
              return true; // Credenciales válidas
            }
          }
        }
      } else {
        print('NO hay docs en la coleccion');
      }
      return false; // Credenciales inválidas
    } catch (e) {
      print('Erro haaaa' + e.toString());
      return false; // Credenciales inválidas debido a un error
    }
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
        //padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
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
      ),
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

    return Container(
      height: height * .1,
      width: width * .8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 156, 155, 155).withOpacity(0.5),
            spreadRadius: 0.1,
            blurRadius: 5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 18,
            color: Color.fromARGB(255, 204, 202, 202),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
            size: 24.0,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // widget encargado del boton para enviar los datos y su diseño
  Widget _buildButton(BuildContext context, String text) {
    final double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: width * .05, left: width * .05),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        child: ElevatedButton(
          onPressed: () async {
            if (emailAPP.text.isEmpty || contrasena.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      textAlign: TextAlign.center,
                      "Alerta",
                      style: TextStyle(color: Color.fromARGB(255, 253, 40, 40)),
                    ),
                    content: Text(
                        textAlign: TextAlign.center,
                        'Todos los campos son obligatorios'),
                  );
                },
              );
            } else {
              bool isValid = await validarDatos();
              if (!isValid) {
                setState(() {
                  loginAttempts++; // Incrementar el contador de intentos
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        textAlign: TextAlign.center,
                        "Alerta",
                        style:
                            TextStyle(color: Color.fromARGB(255, 253, 40, 40)),
                      ),
                      content: Text(
                          textAlign: TextAlign.start,
                          'Credenciales incorrectos o no esta registrado'),
                    );
                  },
                );
              } else {
                bool foundUser = await buscarNombreDeUsuario(emailAPP.text);
                //query para extraer el nombre de usuario a partir del correo
                if (foundUser) {
                  setState(() {
                    loginAttempts = 0; // Restablecer el contador de intentos
                  });

                  // inicio de sesión exitoso
                  detection.login();
                  print('Inicio de sesión exitoso');
                  detection.login();
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomeScreen(),
                      ),
                    );
                  });
                } else {
                  // Resto del código si el usuario no fue encontrado
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 167, 214, 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadowColor: Colors.black.withOpacity(0.5),
            elevation: 5,
          ),
          child: Text(
            text,
            style: GoogleFonts.quicksand(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

// widget que pone las palabras de abajo si no tiene cuenta y redirige
  Widget _buildSignUpText(BuildContext context) {
    return GestureDetector(
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
        children: [
          Text(
            'Aún no tienes una cuenta?',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          Text(
            ' Aquí',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
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
            Image.asset(
              "assets/images/logo-completo2.png",
              alignment: Alignment.center,
              height: 0.3 * MediaQuery.of(context).size.height,
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.05,
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(251, 255, 255, 255),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'Ingresar',
                    style: GoogleFonts.quicksand(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(162, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  _buildButton(context, 'Entrar'),
                  const SizedBox(height: 15),
                  _buildSignUpText(context),
                  const SizedBox(height: 45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // ... Elementos para la orientación vertical ...

  //orientacion horizontal
  Widget _buildLandscapeLayout() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: 500), // Ajusta el ancho máximo
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(251, 255, 255, 255),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Text(
                  'Ingresar',
                  style: GoogleFonts.quicksand(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(162, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  hintText: "Usuario",
                  icon: Icons.person,
                  controller: emailAPP,
                ),
                const SizedBox(height: 4),
                _buildInputField(
                  hintText: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                  controller: contrasena,
                ),
                const SizedBox(height: 15),
                _buildButton(context, 'Entrar'),
                const SizedBox(height: 15),
                _buildSignUpText(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
