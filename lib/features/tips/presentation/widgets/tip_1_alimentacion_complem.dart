// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: Llama al nuevo widget que creamos
    return TrulyAdaptiveCard(
      image: Image.asset(TipAssets.alimentacion),
      title: Text(
        'tips.titles.complementaryFeeding'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingXL,
      ),
      body: [
        AdaptiveTextContent(
          text: 'tips.content.complementaryFeeding'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
