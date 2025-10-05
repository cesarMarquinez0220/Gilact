// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ExtraccionAlmacenamientoInfo extends StatelessWidget {
  const ExtraccionAlmacenamientoInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.extraccion),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: const Text(
          'Extracción, Manejo y Almacenamiento de la Leche Materna',
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: const [
        SizedBox(height: 10),
        Text(
          'La extracción puede realizarse manual o mecánicamente. Para facilitar la extracción, haga estimulación aplicando compresas tibias y masajes circulares sobre toda la mama.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 10),
        Text(
          '- No mezclar leche materna recién extraída con leche materna que ya está refrigerada.',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
