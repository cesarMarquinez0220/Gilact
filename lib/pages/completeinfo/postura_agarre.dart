import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class PosturaAgarreInfo extends StatelessWidget {
  const PosturaAgarreInfo({Key? key}) : super(key: key);

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
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Image.asset(
                    "assets/images/prueba.png",
                    width: 150, // Ajusta el tamaño según sea necesario
                    height: 150,
                  ), // Reemplaza "tu_imagen.png" con la ruta correcta de tu imagen
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Cuida tu Postura y el Agarre\nConsejos para una Buena Postura y Agarre',
                    style: TextStyle(color: Colors.white70,fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'Cuidar la postura y el agarre es esencial para una lactancia exitosa:',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- Coloca al bebé barriga con barriga y en línea recta, con la cara frente al pezón.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- La madre debe buscar una posición cómoda, ayudándose con almohadas y manteniendo la espalda apoyada.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1600),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    'El Agarre Apropiado es Importante:',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '- La boca del bebé debe estar bien abierta y abarcar toda la areola (zona oscura que rodea el pezón).',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 2000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    '\n\nCuantas más veces coloques a tu bebé al pecho, más leche producirás.',
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
