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
  bool _isVisible = true;

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
              Color.fromRGBO(252, 252, 252, 1),
              Color.fromRGBO(27, 167, 214, 1),
              Color.fromARGB(255, 98, 142, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isVisible
                ? FadeIn(
                   curve: Curves.easeIn,
                  child: FadeIn(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo-completo2.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onFinish: (direction) {
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          setState(() {
                            _isVisible = false;
                          });
                          _checkUserSituation();
                        });
                      },
                    ),
                )
                : FadeOutDown(
                   curve: Curves.easeOut,
                  child: FadeOut(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo-completo2.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                ),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 200),
              child: const Center(
                child: Text(
                  "",
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
            MaterialPageRoute(builder: (context) => const Prepost()),
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
