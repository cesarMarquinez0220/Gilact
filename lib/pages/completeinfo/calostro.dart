import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class CalostroInfo extends StatelessWidget {
  const CalostroInfo({Key? key}) : super(key: key);

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
                    'Calostro: La Primera Leche',
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
                    'El calostro es la primera leche que produce la madre. Aquí tienes información clave:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Es de color amarillento y contiene alto valor nutritivo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1600),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Satisface al lactante porque tiene los nutrientes que necesita el bebé.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Contiene defensas que protegen al bebé contra enfermedades.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 2000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Es el único alimento que el bebé necesita en los primeros seis meses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
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
