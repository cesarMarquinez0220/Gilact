import 'package:flutter/material.dart';

/// Widget de tarjeta que se adapta verticalmente para llenar el espacio disponible
/// SIN necesidad de scroll, utilizando Flexible y Expanded para distribuir el espacio.
class TrulyAdaptiveCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final List<Widget> body;

  const TrulyAdaptiveCard({
    super.key,
    required this.image,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos calcular la altura manualmente.
    // Usamos un Column para que Flutter distribuya el espacio.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Padding lateral general
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 8), // Reducido de 24 a 8
            // 1. La imagen ocupa una porción flexible del espacio.
            // El `flex` determina la proporción. Un valor más bajo le da menos espacio
            // en comparación con el contenido.
            Flexible(
              flex: 2, // Reducido de 3 a 2 para dar menos espacio a la imagen
              child: image,
            ),

            const SizedBox(height: 8), // Reducido de 16 a 8
            // 2. La tarjeta de contenido se expande para llenar todo el espacio restante.
            _buildContentCard(),
            const SizedBox(height: 8), // Reducido de 24 a 8
          ],
        ),
      ),
    );
  }

Widget _buildContentCard() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        // --- CAMBIOS CLAVE AQUÍ ---

        // 1. ELIMINA ESTA LÍNEA. Es la causa del problema.
        // mainAxisSize: MainAxisSize.min,

        // 2. AÑADE ESTA LÍNEA para centrar el contenido verticalmente.
        mainAxisSize: MainAxisSize.min,

        // -------------------------

        children: [
          title,
          const SizedBox(height: 6),
          // Envolver el contenido del cuerpo en Flexible es una buena
          // práctica para evitar errores si el texto es muy largo.
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: body),
            ),
          ),
        ],
      ),
    ),
  );
}
}

/// Un widget de texto que se encoge para caber en el espacio disponible.
class AutoFitText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const AutoFitText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.justify,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit:
          BoxFit.scaleDown, // Encoge el hijo para que quepa, pero no lo agranda
      alignment: Alignment.topLeft,
      child: Text(text, style: style, textAlign: textAlign),
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
          padding: const EdgeInsets.symmetric(vertical: 0.3),
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
      padding: const EdgeInsets.symmetric(vertical: 0.2),
      child: Text(
        text,
        style: style?.copyWith(
          height: 1.1, // Reducido para ahorrar espacio
        ),
        textAlign: textAlign,
      ),
    );
  }
}
