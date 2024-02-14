import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_login/pages/completeinfo/shape_decoration/shape.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
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
                  height: MediaQuery.of(context).size.height * 0.47,
                  width: MediaQuery.of(context).size.width * 0.47,
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
                    width: width * .9,
                    height: height * .38,
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
                            child: const Text(
                              'Mantener la lactancia y prolongarla, de ser posible hasta los 2 años',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1400),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              'Suplementación con Hierro:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 73, 140, 240),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInDown(
                            duration: const Duration(milliseconds: 1600),
                            delay: const Duration(milliseconds: 500),
                            child: const Text(
                              'Si tu bebé tuvo bajo peso al nacer y/o es prematuro, se suplementará con hierro. \n\n*Según indicación del personal de salud.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                              textAlign: TextAlign.center,
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
