// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/onboard_info.dart';
import 'package:flutter_login/pages/registro_bebe.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/pages/registro_pre.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Prepost extends StatefulWidget {
  const Prepost({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrepostState createState() => _PrepostState();
}

class _PrepostState extends State<Prepost> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  late String email;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveUserSituation(String situation) async {
    String email = UserDataStorage.getUserEmail();
    try {
      // Construir la referencia al documento del usuario
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario ya existe en la base de datos
        DocumentSnapshot userDocument = usersSnapshot.docs.first;

        // Obtener la referencia al documento del usuario
        DocumentReference userRef = userDocument.reference;

        // Crear una referencia al documento dentro de la subcolección con el nombre de la situación
        DocumentReference situationRef =
            userRef.collection('situacion').doc(situation);

        // Añadir un nuevo documento a la subcolección con la información de la situación
        await situationRef.set(<String, dynamic>{});
        print('Situación registrada con éxito para el usuario: $email');
      } else {
        // El usuario no existe en la base de datos
        print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      print('Error por parte de: $e');
    }
  }

  void navigateToPreparto(BuildContext context) {
    _saveUserSituation('Pre-Parto');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroPre()),
    );
  }

  void navigateToPostparto(BuildContext context) {
    _saveUserSituation('Post-Parto');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroBebe()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () => navigateToPreparto(context),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: const Color(0xff03A696),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 49.0),
                    child: Text(
                      'Elige tu situación actual',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textOpacityAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Pre-Parto',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ScaleTransition(
                          scale: _imageScaleAnimation,
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/mamapre.png',
                              width: MediaQuery.of(context).size.width * 0.45,
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
          GestureDetector(
            onTap: () => navigateToPostparto(context),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: const Color(0xff03588C),
              child: Row(
                children: [
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Post-Parto',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ScaleTransition(
                      scale: _imageScaleAnimation,
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/mamapost.png',
                          width: MediaQuery.of(context).size.width * 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
