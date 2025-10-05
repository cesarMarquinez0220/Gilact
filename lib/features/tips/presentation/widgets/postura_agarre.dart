import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';

class PosturaAgarreInfo extends StatelessWidget {
  const PosturaAgarreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.postura),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Consejos para una Buena Postura y Agarre',
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: const[
        SizedBox(height: 10),
        Text(
          '- Coloca al bebé barriga con barriga y en línea recta, con la cara frente al pezón.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        Text(
          '- La madre debe buscar una posición cómoda, ayudándose con almohadas y manteniendo la espalda apoyada.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'El Agarre Apropiado es Importante:',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          '- La boca del bebé debe estar bien abierta y abarcar toda la areola (zona oscura que rodea el pezón).',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
