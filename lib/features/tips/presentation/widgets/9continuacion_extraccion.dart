// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ContinuacionExtraccionInfo extends StatelessWidget {
  const ContinuacionExtraccionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.extraccion2),
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
        AdaptiveTextContent(
            text: '- La leche descongelada debe consumirse y el sobrante descartarse.',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        AdaptiveTextContent(
            text: '- Dejarla un rato a temperatura ambiente antes de darla.',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
        AdaptiveTextContent(
            text: '- A todos los recipientes donde se pone la leche se les debe etiquetar con nombre y fecha.',
            style: TipTypography.paragraph,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
