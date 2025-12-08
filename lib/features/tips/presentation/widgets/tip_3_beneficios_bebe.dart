import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import '../constants/tip_assets.dart';
import 'common/tip_card.dart';
import 'common/tip_typography.dart';
import 'common/responsive_tip_image.dart';
import 'common/truly_adaptive_card.dart';

class BeneficiosBebeInfo extends StatelessWidget {
  const BeneficiosBebeInfo({super.key});

  Future<List<String>> _getItemsListAsync(
    BuildContext context,
    String key,
  ) async {
    try {
      // Obtener el locale actual
      final locale = Localizations.localeOf(context);
      final localeKey = locale.toString();

      // Cargar el JSON directamente desde assets
      final jsonString = await rootBundle.loadString(
        'assets/translations/$localeKey.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Dividir la clave en partes: "tips.content.benefitsBaby.items"
      final keyParts = key.split('.');
      dynamic value = jsonData;

      // Navegar por el mapa anidado
      for (final part in keyParts) {
        if (value is Map && value.containsKey(part)) {
          value = value[part];
        } else {
          debugPrint('No se encontró la clave: $part en $key');
          return [];
        }
      }

      // Si el valor es una lista, convertirla a List<String>
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

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: const ResponsiveTipImage(
        imagePath: TipAssets.like,
        fit: BoxFit.contain,
      ),
      title: Text(
        'tips.content.benefitsBaby.title'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingLarge,
      ),
      body: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdaptiveTextContent(
              text: 'tips.content.benefitsBaby.subtitle'.tr(),
              style: TipTypography.paragraph,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<String>>(
              future: _getItemsListAsync(
                context,
                'tips.content.benefitsBaby.items',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Error en FutureBuilder: ${snapshot.error}');
                  return const SizedBox.shrink();
                }

                final items = snapshot.data ?? [];

                return AdaptiveListContent(
                  items: items,
                  itemStyle: TipTypography.paragraph,
                  bullet: '-',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
