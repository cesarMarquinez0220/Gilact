// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class SuplementoHierroInfo extends StatelessWidget {
  const SuplementoHierroInfo({Key? key}) : super(key: key);

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
                          duration: const Duration(milliseconds: 1400),
                          delay: const Duration(milliseconds: 500),
                          child: const Text(
                            'Suplementación con Hierro:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 140, 240),
                                fontSize: 30,
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
                            textAlign: TextAlign.left,
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
