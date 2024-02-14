import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class ProblemasLactanciaInfo extends StatelessWidget {
  const ProblemasLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

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
                  height: height * .02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Image.asset(
                      "assets/tips/11_PROBLEMAS.png",
                      height: 150,
                      width: 150,
                    ),
                  ),
                ),
                FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: width * .9,
                      height: height * .52,
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Amamanta con frecuencia para evitar los abcesos mamarios.\n- Consulta con un profesional.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Acude al médico para diagnóstico y tratamiento.\n- Coloca leche materna sobre el pezón y deja secar al aire.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
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
                                textAlign: TextAlign.center,
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
