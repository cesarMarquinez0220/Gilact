// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'package:animate_do/animate_do.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: Llama al nuevo widget que creamos
    return TrulyAdaptiveCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.alimentacion),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.titles.complementaryFeeding'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1200),
          delay: const Duration(milliseconds: 500),
          child: AdaptiveTextContent(
            text: 'tips.content.complementaryFeeding'.tr(),
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
