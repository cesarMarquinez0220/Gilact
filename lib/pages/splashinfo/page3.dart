import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  void initState() {
    super.initState();
    // Agrega un temporizador para cambiar automáticamente de página después de 5 segundos
    Timer(Duration(seconds: 5), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Perfilnuevo(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.only(top: 23, left: 90),
                child: FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Image.asset("assets/images/mother3.png")),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    delay: Duration(milliseconds: 500),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'Beneficios para el bebé \n'),
                          TextSpan(
                            text:
                                'Disminuye la posibilidad \n de enfermarse de:',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25), // Separation between RichText and next text
              Text(
                "Diabetes\n Hipertensión arterial \n Obesidad \n Cáncer (leucemia, linfoma)",
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
