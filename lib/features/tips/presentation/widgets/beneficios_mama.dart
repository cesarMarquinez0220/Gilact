// ignore_for_file: camel_case_types, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
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
      body: const [
        _Paragraph('- Disminuye el sangrado postparto.'),
        _Paragraph('- Ayuda a que el útero vuelva a su estado normal.'),
        _Paragraph('- Protege contra el cáncer de ovario, mama y útero.'),
        _Paragraph(
          '- Recupera rápidamente la figura eliminando reservas de grasa.',
        ),
        _Paragraph('- Disminuye el riesgo de depresión posparto.'),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 1200),
      delay: const Duration(milliseconds: 500),
      child: Text(
        text,
        style: TipTypography.paragraph,
        textAlign: TextAlign.start,
      ),
    );
  }
}
