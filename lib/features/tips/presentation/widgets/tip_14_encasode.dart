// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_unnecessary_containers

import 'common/truly_adaptive_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/responsive_tip_image.dart';

class ProblemasLactanciaInfo extends StatelessWidget {
  const ProblemasLactanciaInfo({Key? key}) : super(key: key);

  Future<List<String>> _getItemsListAsync(
    BuildContext context,
    String key,
  ) async {
    try {
      final locale = Localizations.localeOf(context);
      final localeKey = locale.toString();

      final jsonString = await rootBundle.loadString(
        'assets/translations/$localeKey.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      final keyParts = key.split('.');
      dynamic value = jsonData;

      for (final part in keyParts) {
        if (value is Map && value.containsKey(part)) {
          value = value[part];
        } else {
          debugPrint('No se encontró la clave: $part en $key');
          return [];
        }
      }

      if (value is List) {
        return List<String>.from(value.map((item) => item.toString()));
      } else {
        debugPrint(
          'El valor para $key no es una lista, es: ${value.runtimeType}',
        );
      }

      return [];
    } catch (e) {
      debugPrint('Error obteniendo items para $key: $e');
      return [];
    }
  }

  /// Construye widgets para una sección de problemas
  Widget _buildProblemSection(
    BuildContext context,
    String titleKey,
    String itemsKey,
  ) {
    return FutureBuilder<List<String>>(
      future: _getItemsListAsync(context, itemsKey),
      builder: (context, snapshot) {
        final widgets = <Widget>[];

        widgets.add(
          CompactTextContent(
            text: titleKey.tr(),
            style: TipTypography.paragraph,
            textAlign: TextAlign.center,
          ),
        );
        widgets.add(const SizedBox(height: 6));

        if (snapshot.connectionState == ConnectionState.waiting) {
          widgets.add(
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint('Error en FutureBuilder: ${snapshot.error}');
        } else {
          final items = snapshot.data ?? [];
          for (final item in items) {
            widgets.add(
              CompactTextContent(
                text: '- $item',
                style: TipTypography.paragraph,
                textAlign: TextAlign.start,
              ),
            );
            widgets.add(const SizedBox(height: 6));
          }
        }

        return Column(children: widgets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: const ResponsiveTipImage(
        imagePath: TipAssets.problemas,
        fit: BoxFit.contain,
      ),
      title: Text(
        'tips.content.commonProblems.title'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingLarge,
      ),
      body: [
        const SizedBox(height: 6),
        _buildProblemSection(
          context,
          'tips.content.commonProblems.congestion.title',
          'tips.content.commonProblems.congestion.items',
        ),
        _buildProblemSection(
          context,
          'tips.content.commonProblems.fissures.title',
          'tips.content.commonProblems.fissures.items',
        ),
        _buildProblemSection(
          context,
          'tips.content.commonProblems.lowProduction.title',
          'tips.content.commonProblems.lowProduction.items',
        ),
      ],
    );
  }
}
