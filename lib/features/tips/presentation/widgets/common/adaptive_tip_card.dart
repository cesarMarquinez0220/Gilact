import 'package:flutter/material.dart';

/// Widget adaptativo para tarjetas de tips que se ajusta automáticamente al contenido
/// sin necesidad de scroll y sin sombreado gris
class AdaptiveTipCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final List<Widget> body;
  final double? maxImageHeight;
  final double? minImageHeight;

  const AdaptiveTipCard({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    this.maxImageHeight,
    this.minImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;

    // Calcular altura disponible considerando header, progreso y navegación
    final double availableHeight =
        size.height -
        padding.top -
        padding.bottom -
        180; // Reducido de 200 a 180 para más espacio

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: availableHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: size.height * .015,
                  ), // Reducido de .02 a .015
                  // Imagen con altura adaptativa más pequeña para dar más espacio al contenido
                  _buildAdaptiveImage(size, availableHeight),

                  // Contenido que se ajusta automáticamente
                  _buildAdaptiveContent(size, availableHeight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdaptiveImage(Size size, double availableHeight) {
    // Altura de imagen aún más pequeña para maximizar espacio del contenido
    final double imageHeight =
        (maxImageHeight != null && minImageHeight != null)
        ? (availableHeight * 0.15).clamp(minImageHeight!, maxImageHeight!)
        : availableHeight * 0.15; // Reducido de 0.18 a 0.15

    return SizedBox(
      height: imageHeight,
      width: size.width * 0.45, // Reducido de 0.47 a 0.45
      child: image,
    );
  }

  Widget _buildAdaptiveContent(Size size, double availableHeight) {
    return Container(
      width: size.width * .9,
      margin: const EdgeInsets.only(top: 6), // Reducido de 8 a 6
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        // Eliminado el sombreado gris
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Reducido de 12.0 a 10.0
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título con altura adaptativa más pequeña
            _buildAdaptiveTitle(availableHeight),
            const SizedBox(height: 4), // Reducido de 6 a 4
            // Contenido que se ajusta automáticamente sin scroll
            _buildAdaptiveBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveTitle(double availableHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 20, // Reducido de 25 a 20
        maxHeight: availableHeight * 0.10, // Reducido de 0.12 a 0.10
      ),
      child: title,
    );
  }

  Widget _buildAdaptiveBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: body.map((widget) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0.3,
          ), // Reducido de 0.5 a 0.3
          child: widget,
        );
      }).toList(),
    );
  }
}

/// Widget especializado para contenido de texto que se ajusta automáticamente
class AdaptiveTextContent extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;

  const AdaptiveTextContent({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.justify,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

/// Widget para listas de elementos que se ajustan automáticamente
class AdaptiveListContent extends StatelessWidget {
  final List<String> items;
  final TextStyle? itemStyle;
  final String bullet;

  const AdaptiveListContent({
    super.key,
    required this.items,
    this.itemStyle,
    this.bullet = '•',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0.3,
          ), // Reducido de 0.5 a 0.3
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$bullet ', style: itemStyle),
              Expanded(
                child: Text(
                  item,
                  style: itemStyle,
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Widget especializado para contenido compacto que optimiza el espacio
class CompactTextContent extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const CompactTextContent({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.justify,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0.2,
      ), // Reducido de 0.3 a 0.2
      child: Text(
        text,
        style: style?.copyWith(
          height: 1.1, // Reducido de 1.15 a 1.1 para ahorrar aún más espacio
        ),
        textAlign: textAlign,
      ),
    );
  }
}
