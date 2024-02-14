import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left:80.0),
            child: FadeInLeft(
                duration: const Duration(milliseconds: 1000),
                child: Image.asset("assets/images/mother2.png")),
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
                      color: Colors.white70,
                      fontSize: 25,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Beneficios para el bebé \n'),
                      TextSpan(
                        text: 'Protección contra \n enfermedades como:',
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
          const SizedBox(height: 25), // Separation between RichText and next text
          const Text(
            "Diarrea \n Alergias \n Resfriados \n Infecciones del oído \n Síndrome de muerte en la cuna \n (muerte súbita) ",
            style: TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
