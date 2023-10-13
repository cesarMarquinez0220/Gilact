import 'package:flutter/material.dart';
import 'package:flutter_login/pages/onboard_info.dart';
import 'package:flutter_login/pages/registro_bebe.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Prepost extends StatefulWidget {
  @override
  _PrepostState createState() => _PrepostState();
}

class _PrepostState extends State<Prepost> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
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
        curve: Interval(0.1, 0.5), // Retrasar la aparición del texto
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5), // Retrasar la aparición del texto
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navegación para la sección preparto
  void navigateToPreparto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Onboar_Info()),
    );
  }

  // Navegación para la sección postparto
  void navigateToPostparto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroBebe()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bloquear la rotación de la pantalla
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
              color: Color(0xff03A696),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 49.0),
                    child: Text(
                      'Elige tu situación actual', // Título en la parte superior
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
              color: Color(0xff03588C),
              //child: SingleChildScrollView(
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
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
