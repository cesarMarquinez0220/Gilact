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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenHeight < 700 || screenWidth < 360;
        final isVerySmallScreen = screenHeight < 600;

        // Ajustar flex de imagen según tamaño de pantalla
        final imageFlex = isVerySmallScreen ? 1 : (isSmallScreen ? 2 : 3);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: isSmallScreen ? 4 : 8),
                // 1. La imagen ocupa una porción flexible del espacio.
                Flexible(flex: imageFlex, child: image),
                SizedBox(height: isSmallScreen ? 4 : 8),
                // 2. La tarjeta de contenido se expande para llenar todo el espacio restante.
                Expanded(
                  child: _buildContentCard(
                    context,
                    isSmallScreen,
                    isVerySmallScreen,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    bool isSmallScreen,
    bool isVerySmallScreen,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título responsive con FittedBox para ajuste automático
            LayoutBuilder(
              builder: (context, constraints) {
                // Reducir tamaño máximo del título en pantallas pequeñas
                final maxTitleWidth = isSmallScreen
                    ? constraints.maxWidth * 0.95
                    : constraints.maxWidth;
                final maxTitleScale = isVerySmallScreen
                    ? 0.75
                    : (isSmallScreen ? 0.85 : 1.0);

                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxTitleWidth,
                      maxHeight: isSmallScreen ? 80 : 100,
                    ),
                    child: Transform.scale(
                      scale: maxTitleScale,
                      alignment: Alignment.center,
                      child: DefaultTextStyle(
                        style: DefaultTextStyle.of(context).style,
                        textAlign: TextAlign.center,
                        child: title,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            // Contenido con scroll - Expanded para ocupar espacio restante
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body,
                ),
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
