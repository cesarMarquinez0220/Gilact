// ignore_for_file: camel_case_types, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class beneficios_mama extends StatelessWidget {
  const beneficios_mama({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      child: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 260.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FadeInDown(
                                duration: const Duration(milliseconds: 1000),
                                delay: const Duration(milliseconds: 500),
                                child: Container(
                                  width: width * .88,
                                  height: height * .45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 6,
                                        offset: const Offset(2, 6),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.only(top:80.0,left: 10.0,right: 10.0,bottom: 10.0),
                                      child: Column(
                                        children: [
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                              'Beneficios para la Madre',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 73, 140, 240),
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 1200),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                                '- Disminuye el sangrado postparto.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 86, 86, 86)),
                                                textAlign: TextAlign.start),
                                          ),
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 1400),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                                '- Ayuda a que el útero vuelva a su estado normal.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 86, 86, 86)),
                                                textAlign: TextAlign.start),
                                          ),
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 1600),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                                '- Protege contra el cáncer de ovario, mama y útero.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 86, 86, 86)),
                                                textAlign: TextAlign.start),
                                          ),
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 1800),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                                '- Recupera rápidamente la figura al eliminar las reservas de grasas acumuladas en glúteos y muslos durante el embarazo.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 86, 86, 86)),
                                                textAlign: TextAlign.start),
                                          ),
                                          FadeInDown(
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            delay: const Duration(
                                                milliseconds: 500),
                                            child: const Text(
                                                '- Disminuye el riesgo de síndrome de la depresión posparto.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 86, 86, 86)),
                                                textAlign: TextAlign.start),
                                          ),
                                        ],
                                      )),
                                ))
                          ],
                        ),
                      ),
                      Positioned(
                        top: 1,
                        left: 50,
                        right: 1,
                        child: SizedBox(
                          height: 300,
                          width: width * 3.5,
                          child: FadeInRight(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 500),
                            child: Image.asset(
                              "assets/tips/3_BENEFICIOS.png",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
