// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class LactanciaExitosa extends StatelessWidget {
  const LactanciaExitosa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.consejolactancia),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Consejos para una Lactancia Exitosa',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Infórmate y prepárate todo lo que puedas acerca de la lactancia antes del momento del parto.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Da el pecho inmediatamente después del parto, esto facilita el inicio de la lactancia.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Toma mucha agua.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Confía en ti y en tu capacidad de alimentar a tu bebé: ¡sí tienes leche!',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Coloca al bebé con frecuencia en el pecho: deja que lacte a libre demanda.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
