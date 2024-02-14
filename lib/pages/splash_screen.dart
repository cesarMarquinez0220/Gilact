import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/pre_post.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(254, 254, 254, 1),
              Color.fromRGBO(254, 254, 254, 1),
              Color.fromRGBO(106, 240, 189, 1),
              Color.fromRGBO(27, 167, 214, 1),
              Color.fromARGB(255, 98, 142, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeIn(
          delay: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                "https://lottie.host/91b2ad14-b0d8-4764-8eba-8fef283ec67e/9FK7ekJvjk.json",
                controller: _controller,
                onLoaded: (compos) {
                  _controller
                    ..duration = compos.duration
                    ..forward().then((value) {
                      // Agregar la lógica de verificación después de que la animación se cargue
                      _checkUserSituation();
                    });
                },
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 200),
                child: const Center(
                  child: Text(
                    "Bienvenidos",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Future<void> _checkUserSituation() async {
    String email = UserDataStorage.getUserEmail();

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDocument = usersSnapshot.docs.first;
        DocumentReference userRef = userDocument.reference;

        bool situacionExists = await userRef
            .collection('situacion')
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.isNotEmpty);

        if (situacionExists) {
          // El usuario ya tiene la subcolección "situacion"
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Perfilnuevo()),
          );
        } else {
          // El usuario no tiene la subcolección "situacion", ir a prepost
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Prepost()),
          );
        }
      } else {
        // El usuario no existe en la base de datos.
        //print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      //print('Error: $e');
    }
  }
}
