import 'package:equatable/equatable.dart';

/// Datos de tendencia de peso para un día específico
class WeightTrendData extends Equatable {
  final DateTime date;
  final int ageInDays; // Días desde el nacimiento
  final double? actualWeight; // Peso real del bebé (kg)
  final double? percentile3; // Percentil 3 de la OMS (kg)
  final double? percentile15; // Percentil 15 de la OMS (kg)
  final double? percentile50; // Percentil 50 (mediana) de la OMS (kg)
  final double? percentile85; // Percentil 85 de la OMS (kg)
  final double? percentile97; // Percentil 97 de la OMS (kg)
  final double? feedingVolume; // Volumen de leche ese día (ml)
  final int? feedingFrequency; // Frecuencia de alimentación ese día
  final double? feedingScore; // Score de alimentación (0-100)

  const WeightTrendData({
    required this.date,
    required this.ageInDays,
    this.actualWeight,
    this.percentile3,
    this.percentile15,
    this.percentile50,
    this.percentile85,
    this.percentile97,
    this.feedingVolume,
    this.feedingFrequency,
    this.feedingScore,
  });

  @override
  List<Object?> get props => [
        date,
        ageInDays,
        actualWeight,
        percentile3,
        percentile15,
        percentile50,
        percentile85,
        percentile97,
        feedingVolume,
        feedingFrequency,
        feedingScore,
      ];

  /// Determina en qué percentil se encuentra el peso actual
  double? getCurrentPercentile() {
    if (actualWeight == null) return null;

    if (percentile3 != null && actualWeight! <= percentile3!) {
      return 3.0;
    } else if (percentile15 != null && actualWeight! <= percentile15!) {
      // Interpolar entre P3 y P15
      final t = (actualWeight! - percentile3!) / (percentile15! - percentile3!);
      return 3.0 + (15.0 - 3.0) * t;
    } else if (percentile50 != null && actualWeight! <= percentile50!) {
      // Interpolar entre P15 y P50
      final t = (actualWeight! - percentile15!) / (percentile50! - percentile15!);
      return 15.0 + (50.0 - 15.0) * t;
    } else if (percentile85 != null && actualWeight! <= percentile85!) {
      // Interpolar entre P50 y P85
      final t = (actualWeight! - percentile50!) / (percentile85! - percentile50!);
      return 50.0 + (85.0 - 50.0) * t;
    } else if (percentile97 != null && actualWeight! <= percentile97!) {
      // Interpolar entre P85 y P97
      final t = (actualWeight! - percentile85!) / (percentile97! - percentile85!);
      return 85.0 + (97.0 - 85.0) * t;
    } else {
      return 97.0;
    }
  }

  /// Verifica si el peso está dentro del rango normal (P15-P85)
  bool get isWeightNormal {
    if (actualWeight == null || percentile15 == null || percentile85 == null) {
      return false;
    }
    return actualWeight! >= percentile15! && actualWeight! <= percentile85!;
  }

  /// Verifica si el peso está por debajo del percentil 15
  bool get isWeightLow {
    if (actualWeight == null || percentile15 == null) {
      return false;
    }
    return actualWeight! < percentile15!;
  }

  /// Verifica si el peso está por encima del percentil 85
  bool get isWeightHigh {
    if (actualWeight == null || percentile85 == null) {
      return false;
    }
    return actualWeight! > percentile85!;
  }
}

/// Resultado del análisis de tendencia de crecimiento
class GrowthTrendAnalysis extends Equatable {
  final List<WeightTrendData> trendData;
  final bool hasAlert;
  final String? alertMessage;
  final String? alertType; // 'weight_decreasing', 'feeding_low', 'correlation'
  final double? averageFeedingScore;
  final double? currentPercentile;
  final double? previousPercentile;

  const GrowthTrendAnalysis({
    required this.trendData,
    this.hasAlert = false,
    this.alertMessage,
    this.alertType,
    this.averageFeedingScore,
    this.currentPercentile,
    this.previousPercentile,
  });

  @override
  List<Object?> get props => [
        trendData,
        hasAlert,
        alertMessage,
        alertType,
        averageFeedingScore,
        currentPercentile,
        previousPercentile,
      ];
}

