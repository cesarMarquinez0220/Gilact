import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosBebeInfo extends StatelessWidget {
  const BeneficiosBebeInfo({super.key});

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
        child: Image.asset(TipAssets.like),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.benefitsBaby.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1200),
          delay: const Duration(milliseconds: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveTextContent(
                text: 'tips.content.benefitsBaby.subtitle'.tr(),
                style: TipTypography.paragraph,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
              AdaptiveListContent(
                items: _getItemsList('tips.content.benefitsBaby.items'),
                itemStyle: TipTypography.paragraph,
                bullet: '-',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
