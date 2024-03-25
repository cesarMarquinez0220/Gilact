import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';
class BeneficiosBB extends StatefulWidget {
  const BeneficiosBB({super.key});
  @override
  State<BeneficiosBB> createState() => _BeneficiosBB();
}
class _BeneficiosBB extends State<BeneficiosBB> {
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
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.38,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Image.asset(
                      "assets/tips/2_LACTANCIA.png",
                    ),
                                      ),
                ),
                FadeInDown(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    width: width * .9,
                    height: height * .45,
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
                          const SizedBox(height: 10),

                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.center,
                              'Beneficios  de Alimentación Exclusiva con Lactancia Materna',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 73, 140, 240),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                         const SizedBox(height: 8),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.center,
                              'Durante los primeros 6 meses de vida:',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1200),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.center,
                              '- Mayor coeficiente intelectual y mejor rendimiento escolar.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1400),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.center,
                              '- Afianza el amor, la comunicación y el lazo afectivo entre madre e hijo.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1600),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.left,
                              '- Niños(as) más cariñosos(as).',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1800),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              textAlign: TextAlign.center,
                              '- Menos caries dentales y desarrollo de la musculatura facial y del cuello.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}