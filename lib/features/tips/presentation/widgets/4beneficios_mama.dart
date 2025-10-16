// ignore_for_file: camel_case_types, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosMamaInfo extends StatelessWidget {
  const BeneficiosMamaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.beneficios),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Beneficios para la Madre',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1200),
          delay: const Duration(milliseconds: 500),
          child: AdaptiveListContent(
            items: const [
              'Disminuye el sangrado postparto.',
              'Ayuda a que el útero vuelva a su estado normal.',
              'Protege contra el cáncer de ovario, mama y útero.',
              'Recupera rápidamente la figura eliminando reservas de grasa.',
              'Disminuye el riesgo de depresión posparto.',
            ],
            itemStyle: TipTypography.paragraph,
            bullet: '-',
          ),
        ),
      ],
    );
  }
}
