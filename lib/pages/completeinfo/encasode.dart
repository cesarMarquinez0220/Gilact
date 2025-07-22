// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../claseGlobal/detector.dart';

class ProblemasLactanciaInfo extends StatelessWidget {
  const ProblemasLactanciaInfo({Key? key}) : super(key: key);

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
              children: <Widget>[
                SizedBox(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.35,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Image.asset(
                        "assets/tips/11_PROBLEMAS.png",
                        height: 150,
                        width: 150,
                      ),
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
                        padding: const EdgeInsets.all(9.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Problemas Comunes en la Lactancia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 73, 140, 240),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Congestión Mamaria:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- No suspendas la lactancia; hazte masajes circulares en toda la mama.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Amamanta con frecuencia para evitar los abcesos mamarios.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Fisuras y Erosiones del Pezón:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Verifica si el niño tiene sapito (Moniliasis oral en el bebé o la madre).',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Acude al médico para diagnóstico y tratamiento.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Baja Producción de Leche:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Toma más agua.\n- Descansa y trata de relajarte.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
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
