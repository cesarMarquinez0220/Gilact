import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  // ignore: use_super_parameters
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
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
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
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
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
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Alimentación complementaria',
                                  style: TextStyle(
                                    fontSize: 25,
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
                            'Mantener la lactancia y prolongarla, de ser posible \nhasta los 2 años',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 86, 86, 86),),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1400),
                          delay: const Duration(milliseconds: 500),
                          child: const Text(
                            'Suplementación con Hierro:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                                textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1600),
                          delay: const Duration(milliseconds: 500),
                          child: const Padding(
                            padding: EdgeInsets.only(left:20.0),
                            child: Text(
                              'Si tu bebé tuvo bajo peso al nacer y/o es prematuro,\nse suplementará con hierro. *Según indicación\ndel personal de salud.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 86, 86, 86)),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
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
