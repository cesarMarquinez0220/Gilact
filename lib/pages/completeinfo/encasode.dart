import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class ProblemasLactanciaInfo extends StatelessWidget {
  const ProblemasLactanciaInfo({Key? key}) : super(key: key);

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
                    "assets/images/prueba.png",
                    height: 150,
                    width: 150,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Problemas Comunes en la Lactancia\nQué Hacer en Caso de Problemas en la Lactancia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Congestión Mamaria:',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- No suspendas la lactancia; hazte masajes circulares en toda la mama.\n- Aplica paños tibios si tienes dolor.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Amamanta con frecuencia para evitar los abcesos mamarios.\n- Consulta con un profesional.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Fisuras y Erosiones del Pezón:',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Verifica si el niño tiene sapito (Moniliasis oral en el bebé o la madre).',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Acude al médico para diagnóstico y tratamiento.\n- Coloca leche materna sobre el pezón y deja secar al aire.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Baja Producción de Leche:',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Toma más agua.\n- Descansa y trata de relajarte.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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
