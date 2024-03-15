import 'dart:async';
import 'package:flutter/material.dart';
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
import 'package:flutter_login/pages/completeinfo/shape_decoration/shape.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tips extends StatefulWidget {
  const Tips({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            // Envolver PageView y Stack dentro de otro Stack
            children: [
              Positioned(
                top: -height * .12,
                right: width * .05,
                child: const BezierContainer(),
              ),
              PageView(
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
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1 - 270,
                right: MediaQuery.of(context).size.width * 0.1 + 120,
                child: const OvalContainer(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: 11,
                    effect: const JumpingDotEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.grey,
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 16,
                      jumpScale: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
