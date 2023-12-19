import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class ConsejosLactanciaInfo extends StatelessWidget {
  const ConsejosLactanciaInfo({Key? key}) : super(key: key);

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
                    'Consejos para una Lactancia Materna Exitosa',
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
                    '- ¡No te rindas! Tú puedes amamantar.',
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
                    '- La madre debe continuar la suplementación con hierro y ácido fólico durante los primeros 3 meses de la lactancia.',
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
                    '- Dale pecho a tu bebé inmediatamente después del parto.\n- Dale de mamar al recién nacido cuando lo pida (sin horario fijo).',
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
                    '- El bebé te hará saber cuando tiene hambre, por lo general suele mamar de 8 a 12 veces al día.',
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
                    '- Recuerda: mientras más veces mame el bebé, más leche tendrás para darle.',
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
                    '- Cada niño establece su propio horario.\n- Dale de mamar en un ambiente tranquilo.\n- Busca la posición más cómoda para amamantar.',
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
                    '- Toma abundante agua.',
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
