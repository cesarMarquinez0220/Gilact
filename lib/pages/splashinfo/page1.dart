import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../claseGlobal/detector.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: FadeInRight(
                  duration:const Duration(milliseconds: 1000),
                  delay:const Duration(milliseconds: 500),
                  child: Image.asset("assets/images/mother.png")),
            ),
           const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: FadeInUp(
                  duration:const Duration(milliseconds: 1200),
                  delay:const Duration(milliseconds: 500),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Nada se compara con la \n'),
                        TextSpan(
                          text: 'Leche Materna!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
           const SizedBox(height: 30), // Separation between RichText and next text
           const  Text(
              "Es el mejor alimento para el lactante. \n Es un complejo fluido nutricional vivo que contiene anticuerpos, enzimas, ácidos grasos y hormonas.",
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          const  SizedBox(height: 20),
            Center(
              child: FadeInUp(
                duration:const Duration(milliseconds: 1000),
                delay:const Duration(microseconds: 1000),
                child:const Text(
                  "¡Amamanta con orgullo!",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(
              height: 120,
            ),
            ],
        ),
      ),
    );
  }
}
