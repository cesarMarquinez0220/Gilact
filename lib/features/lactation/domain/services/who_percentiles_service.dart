import 'package:flutter/foundation.dart';

/// Servicio para calcular percentiles de peso según estándares de la OMS (WHO)
/// Basado en las curvas de crecimiento de la OMS para bebés de 0-6 meses
class WHOPercentilesService {
  static final WHOPercentilesService _instance =
      WHOPercentilesService._internal();
  factory WHOPercentilesService() => _instance;
  WHOPercentilesService._internal();

  /// Obtiene el peso esperado para un percentil específico según la edad del bebé
  /// [ageInDays] - Edad del bebé en días desde el nacimiento
  /// [percentile] - Percentil deseado (3, 15, 50, 85, 97)
  /// Retorna el peso en kilogramos
  double? getPercentileWeight(int ageInDays, double percentile) {
    if (ageInDays < 0 || ageInDays > 180) {
      // Solo soportamos 0-6 meses (180 días)
      return null;
    }

    // Datos de referencia de la OMS para percentiles de peso (0-6 meses)
    // Estos son valores aproximados basados en las curvas de crecimiento de la OMS
    // Para una implementación completa, se deberían usar tablas completas de la OMS
    
    // Convertir días a semanas para usar las tablas de referencia
    final ageInWeeks = ageInDays / 7.0;

    // Interpolación lineal entre puntos de referencia conocidos
    // Valores de referencia aproximados (en kg) para diferentes edades en semanas
    final referenceData = _getReferenceData(ageInWeeks);
    
    if (referenceData == null) return null;

    // Interpolación según el percentil
    switch (percentile.toInt()) {
      case 3:
        return referenceData['p3'];
      case 15:
        return referenceData['p15'];
      case 50:
        return referenceData['p50'];
      case 85:
        return referenceData['p85'];
      case 97:
        return referenceData['p97'];
      default:
        // Interpolación lineal para percentiles intermedios
        return _interpolatePercentile(referenceData, percentile);
    }
  }

  /// Obtiene datos de referencia para una edad específica en semanas
  Map<String, double>? _getReferenceData(double ageInWeeks) {
    // Datos de referencia aproximados basados en curvas OMS
    // Estos valores son aproximaciones; para producción se deberían usar tablas completas
    
    if (ageInWeeks < 0 || ageInWeeks > 26) return null;

    // Puntos de referencia clave (semanas: {p3, p15, p50, p85, p97})
    final referencePoints = [
      // Nacimiento (0 semanas)
      {'week': 0.0, 'p3': 2.4, 'p15': 2.7, 'p50': 3.2, 'p85': 3.7, 'p97': 4.2},
      // 1 mes (4.3 semanas)
      {'week': 4.3, 'p3': 3.2, 'p15': 3.6, 'p50': 4.2, 'p85': 4.8, 'p97': 5.4},
      // 2 meses (8.6 semanas)
      {'week': 8.6, 'p3': 4.0, 'p15': 4.5, 'p50': 5.2, 'p85': 6.0, 'p97': 6.8},
      // 3 meses (13 semanas)
      {'week': 13.0, 'p3': 4.8, 'p15': 5.4, 'p50': 6.2, 'p85': 7.1, 'p97': 8.0},
      // 4 meses (17.3 semanas)
      {'week': 17.3, 'p3': 5.4, 'p15': 6.1, 'p50': 7.0, 'p85': 8.0, 'p97': 9.0},
      // 5 meses (21.6 semanas)
      {'week': 21.6, 'p3': 5.9, 'p15': 6.7, 'p50': 7.7, 'p85': 8.8, 'p97': 9.9},
      // 6 meses (26 semanas)
      {'week': 26.0, 'p3': 6.4, 'p15': 7.2, 'p50': 8.3, 'p85': 9.5, 'p97': 10.7},
    ];

    // Encontrar los dos puntos más cercanos para interpolación
    if (ageInWeeks <= 0) {
      return {
        'p3': referencePoints[0]['p3'] as double,
        'p15': referencePoints[0]['p15'] as double,
        'p50': referencePoints[0]['p50'] as double,
        'p85': referencePoints[0]['p85'] as double,
        'p97': referencePoints[0]['p97'] as double,
      };
    }

    if (ageInWeeks >= 26) {
      final last = referencePoints.last;
      return {
        'p3': last['p3'] as double,
        'p15': last['p15'] as double,
        'p50': last['p50'] as double,
        'p85': last['p85'] as double,
        'p97': last['p97'] as double,
      };
    }

    // Interpolar entre dos puntos
    for (int i = 0; i < referencePoints.length - 1; i++) {
      final currentWeek = referencePoints[i]['week'] as double;
      final nextWeek = referencePoints[i + 1]['week'] as double;

      if (ageInWeeks >= currentWeek && ageInWeeks <= nextWeek) {
        final t = (ageInWeeks - currentWeek) / (nextWeek - currentWeek);
        
        return {
          'p3': _lerp(
            referencePoints[i]['p3'] as double,
            referencePoints[i + 1]['p3'] as double,
            t,
          ),
          'p15': _lerp(
            referencePoints[i]['p15'] as double,
            referencePoints[i + 1]['p15'] as double,
            t,
          ),
          'p50': _lerp(
            referencePoints[i]['p50'] as double,
            referencePoints[i + 1]['p50'] as double,
            t,
          ),
          'p85': _lerp(
            referencePoints[i]['p85'] as double,
            referencePoints[i + 1]['p85'] as double,
            t,
          ),
          'p97': _lerp(
            referencePoints[i]['p97'] as double,
            referencePoints[i + 1]['p97'] as double,
            t,
          ),
        };
      }
    }

    return null;
  }

  /// Interpolación lineal
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Interpola un percentil entre los valores de referencia
  double _interpolatePercentile(Map<String, double> referenceData, double percentile) {
    if (percentile <= 3) {
      return referenceData['p3']!;
    } else if (percentile <= 15) {
      final t = (percentile - 3) / (15 - 3);
      return _lerp(referenceData['p3']!, referenceData['p15']!, t);
    } else if (percentile <= 50) {
      final t = (percentile - 15) / (50 - 15);
      return _lerp(referenceData['p15']!, referenceData['p50']!, t);
    } else if (percentile <= 85) {
      final t = (percentile - 50) / (85 - 50);
      return _lerp(referenceData['p50']!, referenceData['p85']!, t);
    } else if (percentile <= 97) {
      final t = (percentile - 85) / (97 - 85);
      return _lerp(referenceData['p85']!, referenceData['p97']!, t);
    } else {
      return referenceData['p97']!;
    }
  }

  /// Obtiene todos los percentiles para una edad específica
  Map<String, double> getAllPercentiles(int ageInDays) {
    return {
      'p3': getPercentileWeight(ageInDays, 3) ?? 0.0,
      'p15': getPercentileWeight(ageInDays, 15) ?? 0.0,
      'p50': getPercentileWeight(ageInDays, 50) ?? 0.0,
      'p85': getPercentileWeight(ageInDays, 85) ?? 0.0,
      'p97': getPercentileWeight(ageInDays, 97) ?? 0.0,
    };
  }

  /// Determina en qué percentil se encuentra el peso del bebé
  double? getPercentileForWeight(int ageInDays, double weight) {
    final percentiles = getAllPercentiles(ageInDays);
    
    if (weight <= percentiles['p3']!) {
      return 3.0;
    } else if (weight <= percentiles['p15']!) {
      // Interpolar entre P3 y P15
      final t = (weight - percentiles['p3']!) / 
                (percentiles['p15']! - percentiles['p3']!);
      return 3.0 + (15.0 - 3.0) * t;
    } else if (weight <= percentiles['p50']!) {
      // Interpolar entre P15 y P50
      final t = (weight - percentiles['p15']!) / 
                (percentiles['p50']! - percentiles['p15']!);
      return 15.0 + (50.0 - 15.0) * t;
    } else if (weight <= percentiles['p85']!) {
      // Interpolar entre P50 y P85
      final t = (weight - percentiles['p50']!) / 
                (percentiles['p85']! - percentiles['p50']!);
      return 50.0 + (85.0 - 50.0) * t;
    } else if (weight <= percentiles['p97']!) {
      // Interpolar entre P85 y P97
      final t = (weight - percentiles['p85']!) / 
                (percentiles['p97']! - percentiles['p85']!);
      return 85.0 + (97.0 - 85.0) * t;
    } else {
      return 97.0;
    }
  }
}

