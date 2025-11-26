// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class RolPadreLactanciaInfo extends StatelessWidget {
  const RolPadreLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: FadeInRight(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Image.asset(TipAssets.padre),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 1000),
        delay: const Duration(milliseconds: 500),
        child: Text(
          'tips.content.fatherRole.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingXL,
        ),
      ),
      body: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            'tips.content.fatherRole.items.0'.tr(),
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: Text(
            'tips.content.fatherRole.items.1'.tr(),
            style: TipTypography.paragraph,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
