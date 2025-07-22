import 'package:flutter/material.dart';
import 'PerfilContinuacion/perfilnuevo.dart';
import 'completeinfo/alimentacion_complem.dart';
import 'completeinfo/beneficios_bebe.dart';
import 'completeinfo/beneficios_mama.dart';
import 'completeinfo/calostro.dart';
import 'completeinfo/consejos.dart';
import 'completeinfo/continuacion_extraccion.dart';
import 'completeinfo/continuacion_higiene.dart';
import 'completeinfo/encasode.dart';  
import 'completeinfo/extraccion.dart';
import 'completeinfo/higiene.dart';
import 'completeinfo/lactancia_exitosa.dart';
import 'completeinfo/padre_lactancia.dart';
import 'completeinfo/postura_agarre.dart';
import 'completeinfo/shape_decoration/shape.dart';
import 'completeinfo/suplementacion_hierro.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tips extends StatefulWidget {
  const Tips({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TipsState createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  final _controller = PageController();

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
            children: [
              Positioned(
                top: -height * .13,
                right: width * .05,
                child: const BezierContainer(),
              ),
              PageView(
                controller: _controller,
                onPageChanged: (index) {
                  // Detener el temporizador si estamos en la última página
                  if (index == 14) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const Perfilnuevo()),
                    );
                  }
                },
                children: const [
                  AlimentacionComplementariaInfo(),
                  SuplementoHierroInfo(),
                  BeneficiosBB(),
                  beneficios_mama(),
                  PosturaAgarreInfo(),
                  CalostroInfo(),
                  ConsejosLactanciaInfo(),
                  ExtraccionAlmacenamientoInfo(),
                  ContinuacionExtraccionInfo(),
                  HigieneLactanciaInfo(),
                  ContinuacionHigieneLactanciaInfo(),
                  LactanciaExitosa(),
                  RolPadreLactanciaInfo(),
                  ProblemasLactanciaInfo(),
                ],
              ),
              Positioned(
                bottom: -height * .15,
                // bottom: MediaQuery.of(context).size.height * 0.1 - 260,
                right: width * 0.1 + 190,
                child: const Ovalstatic1(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: 14,
                    effect: const JumpingDotEffect(
                      activeDotColor: Color.fromARGB(255, 73, 140, 240),
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
