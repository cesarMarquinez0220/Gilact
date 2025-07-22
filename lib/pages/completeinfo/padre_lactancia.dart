// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../claseGlobal/detector.dart';

class RolPadreLactanciaInfo extends StatelessWidget {
  const RolPadreLactanciaInfo({Key? key}) : super(key: key);

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
              children: <Widget>[
                SizedBox(

                  height: MediaQuery.of(context).size.height * 0.43,
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 500),
                    child: Image.asset("assets/tips/10_PADRE.png"),
                  ),
                ),
                FadeIn(
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
                          child: const Text(
                            'El Papel del Padre en la Lactancia',
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
                            'La figura del padre desempeña un papel principal en asegurar y apoyar la lactancia materna exclusiva, para el bienestar y pleno desarrollo de la madre y el bebé.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 500),
                          child: const Text(
                            'Corresponsabilizarse de las tareas de cuidado y labores domésticas durante este periodo tan importante facilita que la madre pueda dedicarle al bebé el tiempo que necesita, así como tener tiempo para sí misma.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 86, 86, 86),
                            ),
                            textAlign: TextAlign.justify,
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
