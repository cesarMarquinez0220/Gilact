import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:google_fonts/google_fonts.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: FadeInRight(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Image.asset("assets/images/mother.png")),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: FadeInUp(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
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
            SizedBox(height: 30), // Separation between RichText and next text
            Text(
              "Es el mejor alimento para el lactante. \n Es un complejo fluido nutricional vivo que contiene anticuerpos, enzimas, ácidos grasos y hormonas.",
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: FadeInUp(
                duration: Duration(milliseconds: 1000),
                delay: Duration(microseconds: 1000),
                child: Text(
                  "¡Amamanta con orgullo!",
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 120,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Pulse(
                    infinite: true,
                    duration: const Duration(milliseconds: 2700),
                    //delay: Duration(milliseconds: 4500),
                    child: Text(
                      "<<<Desliza",
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Color.fromRGBO(200, 212, 210, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
