// ignore_for_file: avoid_unnecessary_containers, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/completeinfo/shape_decoration/shape.dart';
import 'package:flutter_login/pages/login.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: use_key_in_widget_constructors
class ConfiguracionScreen extends StatelessWidget {
  final TextEditingController _comentariosController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          child: Stack(
            children: [
              Positioned(
                top: -height * .12,
                right: width * .05,
                child: const BezierContainer(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Configuración',
                      style: GoogleFonts.quicksand(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Text(
                    'Cuenta',
                    style: GoogleFonts.quicksand(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Enviar un formulario de sugerencias de la aplicación',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Formulario de comentarios o sugerencias
                  const SizedBox(height: 8),
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.2,
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(2, 5), // changes position of hadow
                      ),
                    ], color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: _comentariosController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                            hintText:
                                'Escribe tus comentarios o sugerencias aquí...',
                            hintStyle: GoogleFonts.quicksand()),
                      ),
                    ),
                  ),
                   SizedBox(height: height*.15),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          _enviarComentarios(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(27, 167, 214, 1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.black.withOpacity(0.5),
                          elevation: 5,
                        ),
                        child: Text(
                          'Enviar',
                          style: GoogleFonts.quicksand(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  // Fin del formulario

                  const SizedBox(height: 15),
                  Text(
                    'Versión de la Aplicación',
                    style: GoogleFonts.quicksand(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Versión 0.0.1',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Muestra la versión actual de la aplicación y permite a los usuarios actualizar si hay una versión más reciente disponible

                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      _cerrarSesion(context);
                      print('Cerrando sesión...');
                    },
                    child: Center(
                      child: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.quicksand(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1 - 270,
                right: MediaQuery.of(context).size.width * 0.1 + 120,
                child: const OvalContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cerrarSesion(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Cierra la sesión del usuario
      print('Sesión cerrada exitosamente.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  void _enviarComentarios(BuildContext context) async {
    final String comentarios = _comentariosController.text;

    try {
      // Accede a la instancia de Firestore y agrega los comentarios a la colección "comentarios"
      await FirebaseFirestore.instance.collection('comentarios').add({
        'comentario': comentarios,
        'fecha': DateTime.now(), // Puedes agregar más campos si es necesario
      });

      // Limpia el campo de comentarios después de enviar
      _comentariosController.clear();

      // Muestra un mensaje al usuario indicando que los comentarios se enviaron correctamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comentarios enviados: $comentarios'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // Maneja cualquier error que pueda ocurrir durante el envío de comentarios
      print('Error al enviar comentarios: $error');
    }
  }
}
