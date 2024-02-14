import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class ConsejosLactanciaInfo extends StatelessWidget {
  const ConsejosLactanciaInfo({Key? key}) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: height * .02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Image.asset("assets/tips/6_CONSEJOS.png"),
                  ),
                ),
                FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: width * .9,
                      height: height * .47,
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
                                'Consejos para una Lactancia Materna Exitosa',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
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
                                '- ¡No te rindas! Tú puedes amamantar.',
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
                                '- La madre debe continuar la suplementación con hierro y ácido fólico durante los primeros 3 meses de la lactancia.',
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
                                '- Dale pecho a tu bebé inmediatamente después del parto.\n- Dale de mamar al recién nacido cuando lo pida (sin horario fijo).',
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
                                '- El bebé te hará saber cuando tiene hambre, por lo general suele mamar de 8 a 12 veces al día.',
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
                                '- Cada niño establece su propio horario.\n- Dale de mamar en un ambiente tranquilo.\n- Busca la posición más cómoda para amamantar.',
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
                                '- Toma abundante agua.',
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
