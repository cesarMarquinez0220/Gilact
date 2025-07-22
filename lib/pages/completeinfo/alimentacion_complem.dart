// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth * 0.35,
                child: FadeInRight(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: Image.asset(
                    "assets/tips/1_ALIMENTACION.png",
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
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 500),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color.fromARGB(255, 73, 140, 240),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Alimentación Complementaria',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1200),
                          delay: const Duration(milliseconds: 500),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Es recomendable dar solo leche maternal al bebe hasta los 6 meses y a partir de este momento, agregar poco a poco alimentos de acuerdo con la sugerencia del pediatra o nutricionista.  Se recomienda mantener la lactancia materna combinada con la alimentación hasta que la madre y el niño deseen.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 86, 86, 86),
                              ),
                              textAlign: TextAlign.justify,
                            ),
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
    );
  }
}
