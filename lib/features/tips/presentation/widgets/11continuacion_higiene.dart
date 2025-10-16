// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ContinuacionHigieneLactanciaInfo extends StatelessWidget {
  const ContinuacionHigieneLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.consejos),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Tu Dieta y la Lactancia',
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: const Text(
            'Puedes comer todo tipo de alimentos. Solo asegúrate de comer saludable y tomar mucha agua.',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
      ],
    );
  }
}
