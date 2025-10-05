// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ProblemasLactanciaInfo extends StatelessWidget {
  const ProblemasLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Transform.scale(
          scale: 1.2,
          child: Image.asset(TipAssets.problemas),
        ),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Problemas Comunes en la Lactancia',
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: const [
        SizedBox(height: 10),
        Text(
          'Congestión Mamaria:',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        Text(
          '- No suspendas la lactancia; hazte masajes circulares en toda la mama.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        Text(
          '- Amamanta con frecuencia para evitar los abcesos mamarios.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        Text(
          'Fisuras y Erosiones del Pezón:',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        Text(
          '- Verifica si el niño tiene sapito (Moniliasis oral en el bebé o la madre).',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        Text(
          '- Acude al médico para diagnóstico y tratamiento.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        Text(
          'Baja Producción de Leche:',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        Text(
          '- Toma más agua.\n- Descansa y trata de relajarte.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
