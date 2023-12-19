import 'package:flutter/material.dart';
import 'package:flutter_login/pages/claseGlobal/detector.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosBB extends StatefulWidget {
  const BeneficiosBB({super.key});

  @override
  State<BeneficiosBB> createState() => _BeneficiosBB();
}

class _BeneficiosBB extends State<BeneficiosBB> {
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
                            "assets/images/beneficiosbebe.png")),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Beneficios de la Lactancia Materna',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Alimentación Exclusiva con Lactancia Materna\n',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Los niños y niñas alimentados exclusivamente con leche materna durante los primeros 6 meses de vida tienen beneficios significativos:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                FadeInDown(
                  duration: Duration(milliseconds: 1200),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    '- Mayor coeficiente intelectual y mejor rendimiento escolar.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1400),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    '- Afianza el amor, la comunicación y el lazo afectivo entre madre e hijo.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1600),
                  delay: Duration(milliseconds: 500),
                  child: const Text(
                    textAlign: TextAlign.left,
                    '- Niños(as) más cariñosos(as).',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                FadeInDown(
                  duration: Duration(milliseconds: 1800),
                  delay: Duration(milliseconds: 500),
                  child: Text(
                    textAlign: TextAlign.center,
                    '- Menos caries dentales y desarrollo de la musculatura facial y del cuello.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
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
