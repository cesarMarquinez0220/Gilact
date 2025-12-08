// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_typography.dart';
import 'common/truly_adaptive_card.dart';

class AlimentacionComplementariaInfo extends StatelessWidget {
  const AlimentacionComplementariaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: Llama al nuevo widget que creamos
    return TrulyAdaptiveCard(
      image: LayoutBuilder(
        builder: (context, constraints) {
          final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
          // Calcular cache basado en el tamaño disponible (máximo 800px de ancho para optimización)
          final maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 800;
          final maxHeight = constraints.maxHeight > 0 ? constraints.maxHeight : 600;
          final cacheWidth = (maxWidth * devicePixelRatio).round().clamp(100, 1600);
          final cacheHeight = (maxHeight * devicePixelRatio).round().clamp(100, 1200);
          return Image.asset(
            TipAssets.alimentacion,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            fit: BoxFit.contain,
          );
        },
      ),
      title: Text(
        'tips.titles.complementaryFeeding'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingXL,
      ),
      body: [
        AdaptiveTextContent(
          text: 'tips.content.complementaryFeeding'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
