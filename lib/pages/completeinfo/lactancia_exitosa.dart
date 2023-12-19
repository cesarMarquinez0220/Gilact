import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';

class LactanciaExitosa extends StatelessWidget {
  const LactanciaExitosa({Key? key}) : super(key: key);

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
                    'Consejos para una Lactancia Exitosa',
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
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child:Text(
                  '- Infórmate y prepárate todo lo que puedas acerca de la lactancia antes del momento del parto.\n- Da el pecho inmediatamente después del parto, esto facilita el inicio de la lactancia.\n- Toma mucha agua.\n- Confía en ti y en tu capacidad de alimentar a tu bebé: ¡sí tienes leche!\n- Coloca al bebé con frecuencia en el pecho: deja que lacte a libre demanda.',
                style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
