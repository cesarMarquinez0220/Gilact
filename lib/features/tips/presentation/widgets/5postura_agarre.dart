import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'package:animate_do/animate_do.dart';
import 'common/truly_adaptive_card.dart';

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
        child: Text(
          'tips.content.postureLatch.title'.tr(),
          textAlign: TextAlign.center,
          style: TipTypography.headingLarge,
        ),
      ),
      body: [
        const SizedBox(height: 8),
        CompactTextContent(
          text: '- ${'tips.content.postureLatch.items.0'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        CompactTextContent(
          text: '- ${'tips.content.postureLatch.items.1'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CompactTextContent(
          text: 'tips.content.postureLatch.items.2'.tr(),
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CompactTextContent(
          text: '- ${'tips.content.postureLatch.items.3'.tr()}',
          style: TipTypography.paragraph,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
