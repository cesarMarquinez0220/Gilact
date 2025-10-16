// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';

class SuplementoHierroInfo extends StatelessWidget {
  const SuplementoHierroInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.lactancia),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1400),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Suplementación con Hierro:',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1600),
          delay: const Duration(milliseconds: 500),
          child: const AdaptiveTextContent(
            text:
                'Si tu bebé tuvo bajo peso al nacer y/o es prematuro, se suplementará con hierro.\n\n*Según indicación del personal de salud.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
