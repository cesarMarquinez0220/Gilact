// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class RolPadreLactanciaInfo extends StatelessWidget {
  const RolPadreLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.padre),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'El Papel del Padre en la Lactancia',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            'La figura del padre desempeña un papel principal en asegurar y apoyar la lactancia materna exclusiva, para el bienestar y pleno desarrollo de la madre y el bebé.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            'Corresponsabilizarse de las tareas de cuidado y labores domésticas durante este periodo tan importante facilita que la madre pueda dedicarle al bebé el tiempo que necesita, así como tener tiempo para sí misma.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
