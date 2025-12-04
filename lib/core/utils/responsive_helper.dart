import 'package:flutter/material.dart';

/// Helper completo para diseño responsive
/// Proporciona utilidades para adaptar la UI a diferentes tamaños de pantalla
class ResponsiveHelper {
  /// Obtiene el ancho de la pantalla
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene la altura de la pantalla
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Obtiene el padding del SafeArea
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Obtiene el factor de escala de texto del sistema
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Verifica si es una pantalla muy pequeña (< 360px)
  static bool isExtraSmall(BuildContext context) {
    return screenWidth(context) < 360;
  }

  /// Verifica si es una pantalla pequeña (360-400px)
  static bool isSmall(BuildContext context) {
    final width = screenWidth(context);
    return width >= 360 && width < 400;
  }

  /// Verifica si es una pantalla mediana (400-600px)
  static bool isMedium(BuildContext context) {
    final width = screenWidth(context);
    return width >= 400 && width < 600;
  }

  /// Verifica si es una pantalla grande (600-900px)
  static bool isLarge(BuildContext context) {
    final width = screenWidth(context);
    return width >= 600 && width < 900;
  }

  /// Verifica si es una tablet (>= 600px)
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600;
  }

  /// Verifica si es una pantalla muy grande/tablet grande (>= 900px)
  static bool isExtraLarge(BuildContext context) {
    return screenWidth(context) >= 900;
  }

  /// Verifica si la pantalla es corta en altura (< 700px)
  static bool isShortScreen(BuildContext context) {
    return screenHeight(context) < 700;
  }

  /// Verifica si la pantalla es muy corta (< 600px)
  static bool isVeryShortScreen(BuildContext context) {
    return screenHeight(context) < 600;
  }

  /// Verifica si la pantalla es alta (>= 800px)
  static bool isTallScreen(BuildContext context) {
    return screenHeight(context) >= 800;
  }

  /// Obtiene padding responsive según el tamaño de pantalla
  static double getResponsivePadding(BuildContext context) {
    if (isExtraSmall(context)) return 12.0;
    if (isSmall(context)) return 16.0;
    if (isMedium(context)) return 20.0;
    if (isLarge(context)) return 24.0;
    return 32.0;
  }

  /// Obtiene tamaño de fuente responsive
  static double getResponsiveFontSize(
    BuildContext context,
    double baseSize,
  ) {
    if (isExtraSmall(context)) return baseSize * 0.9;
    if (isSmall(context)) return baseSize;
    if (isMedium(context)) return baseSize * 1.05;
    if (isLarge(context)) return baseSize * 1.1;
    return baseSize * 1.15;
  }

  /// Obtiene tamaño de icono responsive
  static double getResponsiveIconSize(
    BuildContext context,
    double baseSize,
  ) {
    if (isExtraSmall(context)) return baseSize * 0.85;
    if (isSmall(context)) return baseSize;
    if (isMedium(context)) return baseSize * 1.1;
    if (isLarge(context)) return baseSize * 1.2;
    return baseSize * 1.3;
  }

  /// Obtiene número de columnas responsive para grids
  static int getResponsiveColumns(BuildContext context, {
    int small = 2,
    int medium = 3,
    int large = 4,
  }) {
    if (isExtraSmall(context) || isSmall(context)) return small;
    if (isMedium(context)) return medium;
    return large;
  }

  /// Obtiene spacing responsive para grids
  static double getResponsiveSpacing(BuildContext context) {
    if (isExtraSmall(context)) return 8.0;
    if (isSmall(context)) return 10.0;
    if (isMedium(context)) return 12.0;
    return 16.0;
  }

  /// Obtiene altura de botón responsive (mínimo 44px para accesibilidad)
  static double getResponsiveButtonHeight(BuildContext context) {
    final baseHeight = 44.0;
    if (isExtraSmall(context)) return baseHeight;
    if (isSmall(context)) return baseHeight;
    if (isMedium(context)) return baseHeight * 1.1;
    return baseHeight * 1.2;
  }

  /// Obtiene ancho máximo para contenido centrado (útil para tablets)
  static double getMaxContentWidth(BuildContext context) {
    if (isTablet(context)) return 600.0;
    return double.infinity;
  }

  /// Calcula padding horizontal responsive
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Calcula padding vertical responsive
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Calcula padding simétrico responsive
  static EdgeInsets getResponsivePaddingAll(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.all(padding);
  }

  /// Obtiene tamaño de avatar responsive
  static double getResponsiveAvatarSize(BuildContext context) {
    if (isExtraSmall(context)) return 50.0;
    if (isSmall(context)) return 60.0;
    if (isMedium(context)) return 70.0;
    if (isLarge(context)) return 80.0;
    return 90.0;
  }

  /// Verifica si hay notch (iPhone X+)
  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 20;
  }

  /// Verifica si hay barra de navegación inferior (Android)
  static bool hasBottomNavigationBar(BuildContext context) {
    return MediaQuery.of(context).padding.bottom > 0;
  }

  /// Obtiene altura total del SafeArea (top + bottom)
  static double getTotalSafeAreaHeight(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top + padding.bottom;
  }

  /// Calcula altura disponible (pantalla - SafeArea - otros elementos)
  static double getAvailableHeight(
    BuildContext context, {
    double subtractHeight = 0,
  }) {
    final screenHeight = ResponsiveHelper.screenHeight(context);
    final safeArea = getTotalSafeAreaHeight(context);
    return screenHeight - safeArea - subtractHeight;
  }

  /// Obtiene breakpoint actual como string (útil para debugging)
  static String getBreakpointName(BuildContext context) {
    if (isExtraSmall(context)) return 'Extra Small';
    if (isSmall(context)) return 'Small';
    if (isMedium(context)) return 'Medium';
    if (isLarge(context)) return 'Large';
    if (isExtraLarge(context)) return 'Extra Large';
    return 'Unknown';
  }

  /// Widget helper para mostrar información de responsive (solo para debug)
  static Widget debugInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Width: ${screenWidth(context).toStringAsFixed(0)}px',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Height: ${screenHeight(context).toStringAsFixed(0)}px',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Breakpoint: ${getBreakpointName(context)}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'SafeArea Top: ${safeAreaPadding(context).top.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'SafeArea Bottom: ${safeAreaPadding(context).bottom.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}


