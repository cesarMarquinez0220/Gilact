import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';

class BeneficiosBebeInfo extends StatelessWidget {
  const BeneficiosBebeInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.lactancia),
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
      body: const [
        SizedBox(height: 8),
        Text(
          'Durante los primeros 6 meses de vida:',
          textAlign: TextAlign.center,
          style: TipTypography.paragraph,
        ),
        SizedBox(height: 10),
        _P('- Mayor coeficiente intelectual y mejor rendimiento escolar.'),
        SizedBox(height: 10),
        _P(
          '- Afianza el amor, la comunicación y el lazo afectivo entre madre e hijo.',
        ),
        SizedBox(height: 10),
        _P('- Niños(as) más cariñosos(as).'),
        SizedBox(height: 10),
        _P(
          '- Menos caries dentales y mejor desarrollo de musculatura facial y cuello.',
        ),
      ],
    );
  }
}

class _P extends StatelessWidget {
  final String t;
  const _P(this.t);
  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 1200),
      delay: const Duration(milliseconds: 500),
      child: Text(
        t,
        textAlign: TextAlign.start,
        style: TipTypography.paragraph,
      ),
    );
  }
}
