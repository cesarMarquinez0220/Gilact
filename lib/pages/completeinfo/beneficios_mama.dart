import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class beneficios_mama extends StatelessWidget {
  const beneficios_mama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return detection.isLoggedIn;
      },
      child: SafeArea(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FadeInRight(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Image.asset(
                    "assets/images/prueba.png", // Ruta de la imagen
                    width: 150, // Ajusta el tamaño según sea necesario
                    height: 150,
                  ),
                ),
                SizedBox(height: 20),
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Beneficios para la Madre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text('- Disminuye el sangrado postparto.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                      '- Ayuda a que el útero vuelva a su estado normal.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1600),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                      '- Protege contra el cáncer de ovario, mama y útero.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                      '- Recupera rápidamente la figura al eliminar las reservas de grasas acumuladas en glúteos y muslos durante el embarazo.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 2000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                      '- Disminuye el riesgo de síndrome de la depresión posparto.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
