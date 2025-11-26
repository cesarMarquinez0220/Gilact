// ignore_for_file: camel_case_types, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosMamaInfo extends StatelessWidget {
  const BeneficiosMamaInfo({super.key});

  static List<String> _getItemsList(String key) {
    try {
      final items = key.tr() as List<dynamic>;
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.beneficios),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.titles.benefitsMom'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1200),
          delay: const Duration(milliseconds: 500),
          child: AdaptiveListContent(
            items: _getItemsList('tips.content.benefitsMom.items'),
            itemStyle: TipTypography.paragraph,
            bullet: '-',
          ),
        ),
      ],
    );
  }
}
