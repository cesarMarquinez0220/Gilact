import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../PerfilContinuacion/perfilnuevo.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  // El temporizador
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Agrega un temporizador para cambiar automáticamente de página después de 5 segundos
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Perfilnuevo(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Agrega un gesto de deslizamiento para pasar a la siguiente pantalla
      onHorizontalDragUpdate: (details) {
        // Si el usuario desliza hacia la izquierda, cancela el temporizador
        if (details.delta.dx < 0) {
          _timer?.cancel();
        }
      },
      child: Stack(
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 23, left: 90),
                  child: FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: Image.asset("assets/images/mother3.png")),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 500),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
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
                const SizedBox(
                    height: 25), // Separation between RichText and next text
                const Text(
                  "Diabetes\n Hipertensión arterial \n Obesidad \n Cáncer (leucemia, linfoma)",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
