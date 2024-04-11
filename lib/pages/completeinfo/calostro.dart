// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class CalostroInfo extends StatelessWidget {
  const CalostroInfo({Key? key}) : super(key: key);

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
                      child: Image.asset("assets/tips/5_CALOSTRO.png"),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                              child: const Text(
                                'Calostro: La Primera Leche',
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
                              duration: const Duration(milliseconds: 1200),
                              delay: const Duration(milliseconds: 500),
                              child:const Text(
                                'El calostro es la primera leche que produce la madre. Aquí tienes información clave:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration:const Duration(milliseconds: 1400),
                              delay:const Duration(milliseconds: 500),
                              child: const Text(
                                '- Es de color amarillento y contiene alto valor nutritivo.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1600),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Satisface al lactante porque tiene los nutrientes que necesita el bebé.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            FadeInDown(
                              duration: const Duration(milliseconds: 1800),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                '- Contiene defensas que protegen al bebé contra enfermedades.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInDown(
                              duration: const Duration(milliseconds: 2000),
                              delay: const Duration(milliseconds: 500),
                              child: const Text(
                                'Es el único alimento que el bebé necesita en los primeros seis meses.',
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
