// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';

class CalostroInfo extends StatelessWidget {
  const CalostroInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TrulyAdaptiveCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.calostro),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.colostrum.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        const SizedBox(height: 8),
        CompactTextContent(
          text: 'tips.content.colostrum.intro'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        CompactTextContent(
          text: '- ${'tips.content.colostrum.items.0'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        CompactTextContent(
          text: '- ${'tips.content.colostrum.items.1'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        CompactTextContent(
          text: '- ${'tips.content.colostrum.items.2'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        CompactTextContent(
          text: 'tips.content.colostrum.items.3'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
