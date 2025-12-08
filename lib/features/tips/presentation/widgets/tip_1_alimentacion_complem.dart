// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'common/responsive_tip_image.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: Usa TrulyAdaptiveCard con ResponsiveTipImage (optimizado)
    return TrulyAdaptiveCard(
      image: const ResponsiveTipImage(
        imagePath: TipAssets.alimentacion,
        fit: BoxFit.contain,
      ),
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
