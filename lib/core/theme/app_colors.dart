import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación Gilact
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF03A696);
  static const Color primaryLight = Color(0xFF26A69A);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color secondary = Color(0xFF26A69A);
  static const Color accent = Color(0xFF4DB6AC);

  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1B2339);

  // Colores de texto
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Colors.white;
  static const Color textHint = Color(0xFFBDC3C7);

  // Colores de estado
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Colores de bordes
  static const Color border = Color(0xFFE0E0E0);

  // Colores de gradiente
  static const Color gradientStart = Color(0xFF03A696);
  static const Color gradientMiddle = Color(0xFF26A69A);
  static const Color gradientEnd = Color(0xFF4DB6AC);

  // Colores de navegación
  static const Color navigationBackground = Colors.white;
  static const Color navigationSelected = Color(0xFF03A696);
  static const Color navigationUnselected = Color(0xFFBDC3C7);

  // Colores de tarjetas
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Colores de botones
  static const Color buttonPrimary = Color(0xFF03A696);
  static const Color buttonSecondary = Color(0xFF95A5A6);
  static const Color buttonDisabled = Color(0xFFECF0F1);
}

/// Extensiones de color para funcionalidades adicionales
extension ColorExtension on Color {
  /// Oscurece el color según el porcentaje especificado
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      (a * 255.0).round() & 0xff,
      (((r * 255.0).round() & 0xff) * value).round(),
      (((g * 255.0).round() & 0xff) * value).round(),
      (((b * 255.0).round() & 0xff) * value).round(),
    );
  }

  /// Aclara el color según el porcentaje especificado
  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = percent / 100;
    return Color.fromARGB(
      (a * 255.0).round() & 0xff,
      (((r * 255.0).round() & 0xff) +
              ((255 - ((r * 255.0).round() & 0xff)) * value))
          .round(),
      (((g * 255.0).round() & 0xff) +
              ((255 - ((g * 255.0).round() & 0xff)) * value))
          .round(),
      (((b * 255.0).round() & 0xff) +
              ((255 - ((b * 255.0).round() & 0xff)) * value))
          .round(),
    );
  }

  /// Calcula el promedio entre dos colores
  Color avg(Color other) {
    final red =
        ((r * 255.0).round() & 0xff + (other.r * 255.0).round() & 0xff) ~/ 2;
    final green =
        ((g * 255.0).round() & 0xff + (other.g * 255.0).round() & 0xff) ~/ 2;
    final blue =
        ((b * 255.0).round() & 0xff + (other.b * 255.0).round() & 0xff) ~/ 2;
    final alpha =
        ((a * 255.0).round() & 0xff + (other.a * 255.0).round() & 0xff) ~/ 2;
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// Convierte el color a un gradiente lineal
  LinearGradient toGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [this, this.lighten(20)],
    );
  }

  /// Convierte el color a un gradiente con colores relacionados
  LinearGradient toPrimaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.gradientStart,
        AppColors.gradientMiddle,
        AppColors.gradientEnd,
      ],
    );
  }
}

/// Constantes de diseño de la aplicación
class AppConstants {
  // Espaciado
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Bordes redondeados
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Elevación
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // Tamaños de iconos
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Tamaños de texto
  static const double textXS = 10.0;
  static const double textS = 12.0;
  static const double textM = 14.0;
  static const double textL = 16.0;
  static const double textXL = 18.0;
  static const double textXXL = 24.0;
  static const double textTitle = 28.0;

  // Duración de animaciones
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Breakpoints para responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

/// Utilidades de diseño responsivo
class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return AppConstants.paddingM;
    if (isTablet(context)) return AppConstants.paddingL;
    return AppConstants.paddingXL;
  }

  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
}
