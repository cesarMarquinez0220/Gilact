// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class LactanciaExitosa extends StatelessWidget {
  const LactanciaExitosa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.consejolactancia),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.successfulBreastfeeding.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: CompactTextContent(
            text: '- ${'tips.content.successfulBreastfeeding.items.0'.tr()}',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: CompactTextContent(
            text: '- ${'tips.content.successfulBreastfeeding.items.1'.tr()}',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: CompactTextContent(
            text: '- ${'tips.content.successfulBreastfeeding.items.2'.tr()}',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: CompactTextContent(
            text: '- ${'tips.content.successfulBreastfeeding.items.3'.tr()}',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: CompactTextContent(
            text: '- ${'tips.content.successfulBreastfeeding.items.4'.tr()}',
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
