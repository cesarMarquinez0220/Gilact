import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';

/// Widget de tarjeta que se adapta verticalmente para llenar el espacio disponible
/// SIN necesidad de scroll, utilizando Flexible y Expanded para distribuir el espacio.
/// Optimizado para performance usando ResponsiveHelper y const constructors.
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
        final screenHeight = ResponsiveHelper.screenHeight(context);
        final screenWidth = ResponsiveHelper.screenWidth(context);
        final isSmallScreen =
            ResponsiveHelper.isSmall(context) ||
            ResponsiveHelper.isShortScreen(context);
        final isVerySmallScreen = ResponsiveHelper.isVeryShortScreen(context);

        // Padding responsive usando ResponsiveHelper
        final horizontalPadding = ResponsiveHelper.getResponsivePadding(
          context,
        );

        // Ajustar tamaño relativo máximo para la imagen
        final maxImageHeight = isVerySmallScreen
            ? screenHeight * 0.25
            : (isSmallScreen ? screenHeight * 0.30 : screenHeight * 0.35);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // MainAxisSize.min es importante aquí para no forzar altura si no es necesario
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: isSmallScreen ? 4 : 8),
                // 1. IMAGEN: Usamos ConstrainedBox para que no crezca infinitamente,
                // pero no usamos Flexible/Expanded forzado para permitir que la UI fluya.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9,
                    maxHeight: maxImageHeight,
                  ),
                  child: image,
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                // 2. CONTENIDO: Aquí está la magia.
                // Usamos Flexible con FlexFit.loose.
                // Esto dice: "Ocupa lo que necesites, pero NO MÁS del espacio restante".
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildContentCard(
                    context,
                    isSmallScreen,
                    isVerySmallScreen,
                    screenWidth,
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
    double screenWidth,
  ) {
    // Ancho responsive de la card: 90-95% del ancho de pantalla
    final cardWidth = isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.92;
    final cardPadding = ResponsiveHelper.getResponsivePadding(context) * 0.6;

    return Container(
      width: cardWidth,
      // Quitamos altura fija, dejamos que el contenido dicte
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // LA TARJETA SE ENCOGE AL CONTENIDO
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título responsive con FittedBox y ResponsiveHelper
            LayoutBuilder(
              builder: (context, constraints) {
                // Reducir tamaño máximo del título en pantallas pequeñas
                final maxTitleWidth = isSmallScreen
                    ? constraints.maxWidth * 0.95
                    : constraints.maxWidth;
                final maxTitleScale = isVerySmallScreen
                    ? 0.75
                    : (isSmallScreen ? 0.85 : 1.0);
                // Tamaño de fuente responsive
                final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isSmallScreen ? 18.0 : 20.0,
                );

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
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: titleFontSize,
                          color: Colors.black87, // Asegura contraste
                        ),
                        textAlign: TextAlign.center,
                        child: title,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            // CUERPO DEL TEXTO
            // Cambiamos Expanded por Flexible.
            // Si hay poco texto -> Se encoge.
            // Si hay mucho texto -> Topa con el límite del padre y hace scroll.
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isSmallScreen ? 14.0 : 16.0,
                    ),
                    height: 1.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: body,
                  ),
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
/// Optimizado con ResponsiveHelper para fuentes responsive
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
    // Aplicar tamaño de fuente responsive si no está especificado en el style
    final responsiveStyle =
        style?.copyWith(
          fontSize: style?.fontSize != null
              ? ResponsiveHelper.getResponsiveFontSize(
                  context,
                  style!.fontSize!,
                )
              : ResponsiveHelper.getResponsiveFontSize(context, 16.0),
        ) ??
        TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16.0),
        );

    return Text(
      text,
      style: responsiveStyle,
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
