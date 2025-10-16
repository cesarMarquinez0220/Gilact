import 'package:flutter/material.dart';
import 'truly_adaptive_card.dart';

/// Widget adaptativo para tarjetas de tips que se ajusta automáticamente al contenido
/// sin necesidad de scroll y sin sombreado gris
class TipCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final List<Widget> body;
  final double? maxImageHeight;
  final double? minImageHeight;

  const TipCard({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    this.maxImageHeight,
    this.minImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return TrulyAdaptiveCard(image: image, title: title, body: body);
  }
}
