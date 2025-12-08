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

class ContinuacionExtraccionInfo extends StatelessWidget {
  const ContinuacionExtraccionInfo({Key? key}) : super(key: key);

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

  /// Construye la lista de widgets para los items
  Widget _buildItemsList(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getItemsListAsync(
        context,
        'tips.content.extractionContinuation.items',
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
        final widgets = <Widget>[];

        for (final item in items) {
          widgets.add(
            AdaptiveTextContent(
              text: '- $item',
              style: TipTypography.paragraph,
              textAlign: TextAlign.start,
            ),
          );
        }

        return Column(children: widgets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TipCard(
      image: const ResponsiveTipImage(
        imagePath: TipAssets.extraccion2,
        fit: BoxFit.contain,
      ),
      title: Text(
        'tips.content.extractionContinuation.title'.tr(),
        textAlign: TextAlign.center,
        style: TipTypography.headingLarge,
      ),
      body: [const SizedBox(height: 10), _buildItemsList(context)],
    );
  }
}
