// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/responsive_tip_image.dart';
import 'common/truly_adaptive_card.dart';

class SuplementoHierroInfo extends StatelessWidget {
  const SuplementoHierroInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: const ResponsiveTipImage(
        imagePath: TipAssets.lactancia,
        fit: BoxFit.contain,
      ),
      title: Text(
        '${'tips.titles.ironSupplementation'.tr()}:',
        textAlign: TextAlign.center,
        style: TipTypography.headingXL,
      ),
      body: [
        AdaptiveTextContent(
          text: 'tips.content.ironSupplementation'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
