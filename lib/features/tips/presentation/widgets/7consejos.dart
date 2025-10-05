// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ConsejosLactanciaInfo extends StatelessWidget {
  const ConsejosLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.consejos),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Consejos para una Lactancia Materna Exitosa',
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body:const [
         Text(
          '- ¡No te rindas! Tú puedes amamantar.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- La madre debe continuar la suplementación con hierro y ácido fólico durante los primeros 3 meses de la lactancia.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- Dale pecho a tu bebé inmediatamente después del parto.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- El bebé te hará saber cuando tiene hambre suele mamar de 8 a 12 veces al día.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- Dale de mamar en un ambiente tranquilo.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- Busca la posición más cómoda para amamantar.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
         SizedBox(height: 8),
         Text(
          '- Toma abundante agua.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
