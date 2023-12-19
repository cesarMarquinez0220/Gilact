import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';
import 'package:flutter_login/pages/completeinfo/alimentacion_complem.dart';
import 'package:flutter_login/pages/completeinfo/beneficios_bebe.dart';
import 'package:flutter_login/pages/completeinfo/beneficios_mama.dart';
import 'package:flutter_login/pages/completeinfo/calostro.dart';
import 'package:flutter_login/pages/completeinfo/consejos.dart';
import 'package:flutter_login/pages/completeinfo/encasode.dart';
import 'package:flutter_login/pages/completeinfo/extraccion.dart';
import 'package:flutter_login/pages/completeinfo/higiene.dart';
import 'package:flutter_login/pages/completeinfo/lactancia_exitosa.dart';
import 'package:flutter_login/pages/completeinfo/padre_lactancia.dart';
import 'package:flutter_login/pages/completeinfo/postura_agarre.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tips extends StatefulWidget {
  @override
  _TipsState createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  final _controller = PageController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_controller.page != 8) {
        _controller.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        // Si estamos en la última página, regresar a la pantalla de perfil nuevo
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Perfilnuevo()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: Gradients.myGradient,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    // Detener el temporizador si estamos en la última página
                    if (index == 10) {
                      _timer.cancel();
                    }
                  },
                  children: const [
                    AlimentacionComplementariaInfo(),
                    BeneficiosBB(),
                    beneficios_mama(),
                    PosturaAgarreInfo(),
                    CalostroInfo(),
                    ConsejosLactanciaInfo(),
                    ExtraccionAlmacenamientoInfo(),
                    HigieneLactanciaInfo(),
                    LactanciaExitosa(),
                    RolPadreLactanciaInfo(),
                    ProblemasLactanciaInfo(),
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: 11,
                effect: const JumpingDotEffect(
                  activeDotColor: Color.fromRGBO(19, 180, 153, 1),
                  dotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 16,
                  jumpScale: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
