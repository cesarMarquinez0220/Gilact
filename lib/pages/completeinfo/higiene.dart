// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class HigieneLactanciaInfo extends StatelessWidget {
  const HigieneLactanciaInfo({Key? key}) : super(key: key);

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
                  height: screenHeight * 0.30,
                  width: screenWidth * 0.35,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Transform.scale(
                      scale: 1.8, 
                      child: Image.asset("assets/tips/7.1_EXTRACCION.png"),
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
                        padding:const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Higiene y Medidas Generales',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 73, 140, 240),
                                ),
                              ),
                            ),
                           const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Lávate bien las manos con agua y jabón antes de dar pecho.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- El baño diario es suficiente para el aseo de los pezones.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Lávate las manos con agua y jabón después de cada cambio de pañal.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            FadeInDown(
                              duration:const  Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Da pecho con alegría y aumentará tu producción.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Tu Dieta y la Lactancia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 73, 140, 240),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1000),
                              delay:const Duration(milliseconds: 500),
                              child: const Text(
                                'Puedes comer todo tipo de alimentos. Solo asegúrate de comer saludable y tomar mucha agua.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
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
