// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class HigieneLactanciaInfo extends StatelessWidget {
  const HigieneLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.higiene),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Higiene y Medidas Generales',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Lávate bien las manos con agua y jabón antes de dar pecho.',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- El baño diario es suficiente para el aseo de los pezones.',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Lávate las manos con agua y jabón después de cada cambio de pañal.',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            '- Da pecho con alegría y aumentará tu producción.',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
      ],
    );
  }
}
