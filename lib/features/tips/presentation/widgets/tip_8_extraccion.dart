// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ExtraccionAlmacenamientoInfo extends StatelessWidget {
  const ExtraccionAlmacenamientoInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.extraccion),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.extractionStorage.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: [
        const SizedBox(height: 10),
        Text(
          'tips.content.extractionStorage.intro'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 10),
        AdaptiveTextContent(
          text: '- ${'tips.content.extractionStorage.items.0'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
