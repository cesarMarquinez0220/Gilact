import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosBebeInfo extends StatelessWidget {
  const BeneficiosBebeInfo({super.key});
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
        child: const Text(
          'Beneficios de Lactancia Materna Exclusiva',
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
              const AdaptiveTextContent(
                text: 'Durante los primeros 6 meses de vida:',
                style: TipTypography.paragraph,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
              AdaptiveListContent(
                items: const [
                  'Mayor coeficiente intelectual y mejor rendimiento escolar.',
                  'Afianza el amor, la comunicación y el lazo afectivo entre madre e hijo.',
                  'Niños(as) más cariñosos(as).',
                  'Menos caries dentales y mejor desarrollo de musculatura facial y cuello.',
                ],
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
