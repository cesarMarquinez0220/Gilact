// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';

class ContinuacionHigieneLactanciaInfo extends StatelessWidget {
  const ContinuacionHigieneLactanciaInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: Image.asset(TipAssets.consejos),
      title: Text(
        'tips.content.hygieneContinuation.title'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingLarge,
      ),
      body: [
        Text(
          'tips.content.hygieneContinuation.text'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.paragraph,
        ),
      ],
    );
  }
}
