import '../entities/weight_trend_data.dart';

/// Servicio para detectar alertas de crecimiento
class GrowthAlertService {
  static final GrowthAlertService _instance = GrowthAlertService._internal();
  factory GrowthAlertService() => _instance;
  GrowthAlertService._internal();

  /// Analiza la tendencia de crecimiento y detecta alertas
  GrowthTrendAnalysis analyzeGrowthTrend(List<WeightTrendData> trendData) {
    if (trendData.isEmpty) {
      return const GrowthTrendAnalysis(trendData: []);
    }

    // Filtrar datos con peso real
    final dataWithWeight = trendData
        .where((data) => data.actualWeight != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (dataWithWeight.length < 2) {
      // Necesitamos al menos 2 puntos para detectar tendencias
      return GrowthTrendAnalysis(
        trendData: trendData,
        hasAlert: false,
      );
    }

    // Calcular percentiles actuales y anteriores
    final currentData = dataWithWeight.last;
    final previousData = dataWithWeight.length >= 2
        ? dataWithWeight[dataWithWeight.length - 2]
        : null;

    final currentPercentile = currentData.getCurrentPercentile();
    final previousPercentile = previousData?.getCurrentPercentile();

    // Calcular score promedio de alimentación
    final feedingScores = trendData
        .where((data) => data.feedingScore != null)
        .map((data) => data.feedingScore!)
        .toList();
    final averageFeedingScore = feedingScores.isNotEmpty
        ? feedingScores.reduce((a, b) => a + b) / feedingScores.length
        : null;

    // Detectar alertas
    String? alertMessage;
    String? alertType;
    bool hasAlert = false;

    // Alerta 1: Peso cruzando percentiles hacia abajo
    if (currentPercentile != null &&
        previousPercentile != null &&
        currentPercentile < previousPercentile - 10) {
      // Si bajó más de 10 puntos de percentil
      hasAlert = true;
      alertType = 'weight_decreasing';
      alertMessage =
          'Hemos notado que el peso ha disminuido su velocidad de crecimiento. '
          'Ha pasado del percentil ${previousPercentile.toStringAsFixed(0)} '
          'al percentil ${currentPercentile.toStringAsFixed(0)}. '
          'Podría ser un buen momento para consultar con tu pediatra.';
    }

    // Alerta 2: Alimentación baja
    if (averageFeedingScore != null && averageFeedingScore < 60) {
      if (!hasAlert) {
        hasAlert = true;
        alertType = 'feeding_low';
        alertMessage =
            'La ingesta de leche registrada está por debajo de lo esperado '
            'para la edad del bebé. Considera consultar con una asesora de lactancia.';
      } else {
        // Si ya hay alerta de peso, combinar mensajes
        alertType = 'correlation';
        alertMessage =
            'Hemos notado que el peso ha disminuido su velocidad de crecimiento, '
            'coincidiendo con una ingesta de leche registrada más baja. '
            'Podría ser un buen momento para consultar con tu pediatra o asesora de lactancia.';
      }
    }

    // Alerta 3: Correlación peso bajo + alimentación baja
    if (currentPercentile != null &&
        currentPercentile < 15 &&
        averageFeedingScore != null &&
        averageFeedingScore < 70) {
      hasAlert = true;
      alertType = 'correlation';
      alertMessage =
          'El peso del bebé está por debajo del percentil 15 y la ingesta de leche '
          'registrada está por debajo de lo esperado. Te recomendamos consultar '
          'con tu pediatra o nutricionista.';
    }

    return GrowthTrendAnalysis(
      trendData: trendData,
      hasAlert: hasAlert,
      alertMessage: alertMessage,
      alertType: alertType,
      averageFeedingScore: averageFeedingScore,
      currentPercentile: currentPercentile,
      previousPercentile: previousPercentile,
    );
  }

  /// Verifica si hay crecimiento vacilante (faltering growth)
  /// Ocurre cuando el peso cruza 2 o más líneas de percentiles hacia abajo
  bool hasFalteringGrowth(List<WeightTrendData> trendData) {
    final dataWithWeight = trendData
        .where((data) => data.actualWeight != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (dataWithWeight.length < 2) return false;

    // Comparar percentiles a lo largo del tiempo
    final percentiles = dataWithWeight
        .map((data) => data.getCurrentPercentile())
        .where((p) => p != null)
        .map((p) => p!)
        .toList();

    if (percentiles.length < 2) return false;

    // Verificar si hay una tendencia descendente significativa
    int percentileDrops = 0;
    for (int i = 1; i < percentiles.length; i++) {
      final drop = percentiles[i - 1] - percentiles[i];
      if (drop > 10) {
        // Si baja más de 10 puntos de percentil
        percentileDrops++;
      }
    }

    // Si hay 2 o más caídas significativas, es crecimiento vacilante
    return percentileDrops >= 2;
  }
}

