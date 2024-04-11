

import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class PosturaAgarreInfo extends StatelessWidget {
  const PosturaAgarreInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   double screenWidth = MediaQuery.of(context).size.width;
   double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      child: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.35,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Image.asset(
                      "assets/tips/4_POSTURA.png"
                    ),
                  ),
                ),
                FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: screenWidth * .9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 6,
                            offset: const Offset(2, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Consejos para una Buena Postura y Agarre',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 73, 140, 240),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1400),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Coloca al bebé barriga con barriga y en línea recta, con la cara frente al pezón.',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 86, 86, 86)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1400),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- La madre debe buscar una posición cómoda, ayudándose con almohadas y manteniendo la espalda apoyada.',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 86, 86, 86)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1600),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'El Agarre Apropiado es Importante:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 73, 140, 240),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1800),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- La boca del bebé debe estar bien abierta y abarcar toda la areola (zona oscura que rodea el pezón).',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 86, 86, 86)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                          //   FadeInDown(
                          //     duration: const Duration(milliseconds: 2000),
                          //     delay: const Duration(milliseconds: 500),
                          //     child: const Text(
                          //       '¡Cuantas más veces coloques a tu bebé al pecho, más leche producirás!',
                          //       style: TextStyle(
                          //           fontSize: 14,
                          //           color: Color.fromARGB(255, 86, 86, 86)),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
