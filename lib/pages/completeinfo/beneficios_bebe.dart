import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosBB extends StatefulWidget {
  const BeneficiosBB({Key? key}) : super(key: key);

  @override
  State<BeneficiosBB> createState() => _BeneficiosBBState();
}

class _BeneficiosBBState extends State<BeneficiosBB> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return true; // Aquí debes poner la lógica adecuada para tu aplicación
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width * 0.35,
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
                          child: Text(
                            'Beneficios  de Alimentación Exclusiva con Lactancia Materna',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 73, 140, 240),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            'Durante los primeros 6 meses de vida:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1200),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            '- Mayor coeficiente intelectual y mejor rendimiento escolar.',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1400),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            '- Afianza el amor, la comunicación y el lazo afectivo entre madre e hijo.',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1600),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            '- Niños(as) más cariñosos(as).',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1800),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            '- Menos caries dentales y desarrollo de la musculatura facial y del cuello.',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
