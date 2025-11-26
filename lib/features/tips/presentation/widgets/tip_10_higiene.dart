// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class HigieneLactanciaInfo extends StatelessWidget {
  const HigieneLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.higiene),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.hygiene.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            '- ${'tips.content.hygiene.items.0'.tr()}',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            '- ${'tips.content.hygiene.items.1'.tr()}',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            '- ${'tips.content.hygiene.items.2'.tr()}',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            '- ${'tips.content.hygiene.items.3'.tr()}',
            textAlign: TextAlign.center,
            style: TipTypography.paragraph,
          ),
        ),
      ],
    );
  }
}
