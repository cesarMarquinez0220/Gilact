// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';

class CalostroInfo extends StatelessWidget {
  const CalostroInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Transform.scale(
          scale: 1.8,
          child: Image.asset(TipAssets.calostro),
        ),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Calostro: La Primera Leche',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: const [
        SizedBox(height: 10),
        Text(
          'El calostro es la primera leche que produce la madre. Aquí tienes información clave:',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        Text(
          '- Es de color amarillento y contiene alto valor nutritivo.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        Text(
          '- Satisface al lactante porque tiene los nutrientes que necesita el bebé.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        Text(
          '- Contiene defensas que protegen al bebé contra enfermedades.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        Text(
          'Es el único alimento que el bebé necesita en los primeros seis meses.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
