import 'package:flutter/material.dart';

/// Servicio para manejar la configuración de colores de la aplicación
class AppColorService {
  /// Colores para las tarjetas de funcionalidades
  static const Map<String, Color> featureCardColors = {
    'Lecciones': Color(0xFF667eea),
    'Tips': Color(0xFFf093fb),
    'Calendario': Color(0xFF764ba2),
    'Historial': Color(0xFF03A696),
  };

  /// Obtiene el color para una funcionalidad específica
  static Color getFeatureColor(String featureName) {
    return featureCardColors[featureName] ?? const Color(0xFF03A696);
  }

  /// Gradiente de fondo consistente
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF667eea), // Azul púrpura (consistente con AppBar)
      Color(0xFF764ba2), // Púrpura medio
      Color(0xFFf093fb), // Rosa claro
      Color(0xFFF8F9FA), // Blanco suave
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );
}
