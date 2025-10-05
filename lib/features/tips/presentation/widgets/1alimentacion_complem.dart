// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.alimentacion),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text( 
          'Alimentación Complementaria',
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Es recomendable dar solo leche maternal al bebe hasta los 6 meses y a partir de este momento, agregar poco a poco alimentos de acuerdo con la sugerencia del pediatra o nutricionista.  Se recomienda mantener la lactancia materna combinada con la alimentación hasta que la madre y el niño deseen.',
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
