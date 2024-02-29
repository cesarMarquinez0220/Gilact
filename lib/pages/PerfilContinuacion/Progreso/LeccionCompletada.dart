// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

class LeccionCompletada extends StatefulWidget {
  final bool startAnimationAutomatically;

  const LeccionCompletada({Key? key, this.startAnimationAutomatically = true});

  @override
  _LeccionCompletadaState createState() => _LeccionCompletadaState();
}

class _LeccionCompletadaState extends State<LeccionCompletada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Reducir la duración
    );
    if (widget.startAnimationAutomatically) {
      _controller.forward().whenComplete(() {
        _startStarAnimation();
      });
    }
    // // Iniciar la animación de entrada
    // _controller.forward().whenComplete(() {
    //   // Iniciar la animación continua de las estrellas
    //   _startStarAnimation();
    // });
  }

  void _startStarAnimation() async {
    while (true) {
      await _animateStar(0); // Estrella izquierda
      await _animateStar(2); // Estrella derecha
      await _animateStar(1); // Estrella central (la grande)
    }
  }

  Future<void> _animateStar(int index) async {
    await Future.delayed(
        const Duration(milliseconds: 200)); // Reducir la espera

    // Iniciar la animación de subida con efecto de parpadeo
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedStar({required bool isBig}) {
    return ShakeY(
      from: 10,
      duration: const Duration(milliseconds: 1500), // Ajustar la duración
      infinite: true,
      child: Image.asset(
        'assets/images/estrella.png',
        height: isBig ? 50.0 : 30.0,
      ),
    );
  }

  Widget _buildMotivationMessage() {
    return Positioned(
      top: 15.0,
      right: 15.0,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 226, 226),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: const Material(
          color: Colors.transparent,
          child: Text(
            '¡Sigue\n aprendiendo!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.1,
        vertical: screenSize.height * 0.2,
      ),
      child: Center(
        child: ZoomIn(
          animate: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 228, 222, 222),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: screenSize.height * 0.05,
                  color: Colors.green,
                  child: Center(
                    child: Material(
                      color: Colors.green,
                      child: Text(
                        '¡Lección Completada!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.05,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedStar(isBig: false),
                    _buildAnimatedStar(isBig: true),
                    _buildAnimatedStar(isBig: false),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/prueba.png',
                        height: 50.0,
                      ),
                    ),
                    _buildMotivationMessage(),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.019),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(27, 167, 214, 1),
                    padding: EdgeInsets.symmetric(
                      vertical: screenSize.height * 0.02,
                      horizontal: screenSize.width * 0.09,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Regresar',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
