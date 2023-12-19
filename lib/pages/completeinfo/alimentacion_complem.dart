import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({Key? key}) : super(key: key);

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
                Container(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 30),
                    child: FadeInRight(
                        duration: Duration(milliseconds: 1000),
                        delay: Duration(milliseconds: 500),
                        child: Image.asset(
                            "assets/images/alimenta_complementaria.png")),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Alimentación Complementaria',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )
                        ]),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'En este período debe mantenerse la lactancia y prolongarla, de ser posible hasta los 2 años, ya que la leche materna exclusiva solamente cubre las necesidades energéticas hasta los 6 meses de edad. Cuando el niño o niña cumple 6 meses debe mantenerse la lactancia. Para complementar la leche materna, inicia la alimentación con alimentos saludables.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Suplementación con Hierro:',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1600),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Si tu bebé tuvo bajo peso al nacer y/o es prematuro, se suplementará con hierro. \n\n*Según indicación del personal de salud.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
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
