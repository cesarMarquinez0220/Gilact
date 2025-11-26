// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        child: Text(
          'tips.content.commonProblems.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: [
        const SizedBox(height: 6),
        CompactTextContent(
            text: 'tips.content.commonProblems.congestion.title'.tr(),
            style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.congestion.items.0'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.congestion.items.1'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: 'tips.content.commonProblems.fissures.title'.tr(),
            style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.fissures.items.0'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.fissures.items.1'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: 'tips.content.commonProblems.lowProduction.title'.tr(),
            style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.lowProduction.items.0'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CompactTextContent(
            text: '- ${'tips.content.commonProblems.lowProduction.items.1'.tr()}',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
