import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../domain/entities/weight_trend_data.dart';

/// Widget para mostrar gráfica de tendencia de peso con percentiles OMS
class BabyWeightTrendChart extends StatelessWidget {
  final List<WeightTrendData> trendData;
  final double? minWeight;
  final double? maxWeight;

  const BabyWeightTrendChart({
    super.key,
    required this.trendData,
    this.minWeight,
    this.maxWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: _buildEmptyState(),
      );
    }

    // Filtrar datos con peso real
    final dataWithWeight =
        trendData.where((data) => data.actualWeight != null).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (dataWithWeight.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: _buildEmptyState(),
      );
    }

    // Calcular rangos
    final allWeights = <double>[];
    for (final data in trendData) {
      if (data.percentile3 != null) allWeights.add(data.percentile3!);
      if (data.percentile97 != null) allWeights.add(data.percentile97!);
      if (data.actualWeight != null) allWeights.add(data.actualWeight!);
    }

    if (allWeights.isEmpty) {
      return _buildEmptyState();
    }

    final minW =
        minWeight ?? (allWeights.reduce((a, b) => a < b ? a : b) - 0.5);
    final maxW =
        maxWeight ?? (allWeights.reduce((a, b) => a > b ? a : b) + 0.5);

    // Calcular estadísticas rápidas
    final latestData = dataWithWeight.isNotEmpty ? dataWithWeight.last : null;
    final currentPercentile = latestData?.getCurrentPercentile();
    final trendDirection = _calculateTrendDirection(dataWithWeight);

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icono decorativo en la esquina superior derecha
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF03A696).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF03A696).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF03A696),
                  size: 22,
                ),
              ),
            ),
            // Icono de información/descargo de responsabilidad
            Positioned(
              top: 15,
              right: 70,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDisclaimer(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            // Contenido
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Tendencia de Peso',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Comparación con estándares OMS',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 12),
                // Mini estadísticas
                if (latestData != null)
                  _buildQuickStats(
                    latestData,
                    currentPercentile,
                    trendDirection,
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(_buildChartData(dataWithWeight, minW, maxW)),
                ),
                const SizedBox(height: 16),
                _buildLegend(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Calcula la dirección de la tendencia (subiendo, bajando, estable)
  String _calculateTrendDirection(List<WeightTrendData> data) {
    if (data.length < 2) return 'estable';

    final recent = data.sublist(data.length - 3 > 0 ? data.length - 3 : 0);
    if (recent.length < 2) return 'estable';

    final first = recent.first.actualWeight ?? 0;
    final last = recent.last.actualWeight ?? 0;
    final diff = last - first;

    if (diff > 0.1) return 'subiendo';
    if (diff < -0.1) return 'bajando';
    return 'estable';
  }

  /// Construye mini estadísticas rápidas
  Widget _buildQuickStats(
    WeightTrendData latestData,
    double? currentPercentile,
    String trendDirection,
  ) {
    Color trendColor;
    IconData trendIcon;
    String trendText;

    switch (trendDirection) {
      case 'subiendo':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        trendText = 'En aumento';
        break;
      case 'bajando':
        trendColor = Colors.orange;
        trendIcon = Icons.trending_down;
        trendText = 'En descenso';
        break;
      default:
        trendColor = Colors.blue;
        trendIcon = Icons.trending_flat;
        trendText = 'Estable';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Peso actual
          Expanded(
            child: _buildStatItem(
              'Peso actual',
              '${latestData.actualWeight!.toStringAsFixed(2)} kg',
              Icons.monitor_weight,
              const Color(0xFF03A696),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          // Percentil
          Expanded(
            child: _buildStatItem(
              'Percentil',
              currentPercentile != null
                  ? 'P${currentPercentile.toStringAsFixed(0)}'
                  : 'N/A',
              Icons.analytics_outlined,
              Colors.blue,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          // Tendencia
          Expanded(
            child: _buildStatItem(
              'Tendencia',
              trendText,
              trendIcon,
              trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 9, color: Colors.grey[600]),
        ),
      ],
    );
  }

  LineChartData _buildChartData(
    List<WeightTrendData> data,
    double minWeight,
    double maxWeight,
  ) {
    // Preparar puntos para percentiles
    final p3Spots = <FlSpot>[];
    final p15Spots = <FlSpot>[];
    final p50Spots = <FlSpot>[];
    final p85Spots = <FlSpot>[];
    final p97Spots = <FlSpot>[];
    final actualSpots = <FlSpot>[];
    final normalRangeSpots = <FlSpot>[]; // Para el área sombreada P15-P85

    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final x = i.toDouble();

      if (dataPoint.percentile3 != null) {
        p3Spots.add(FlSpot(x, dataPoint.percentile3!));
      }
      if (dataPoint.percentile15 != null) {
        p15Spots.add(FlSpot(x, dataPoint.percentile15!));
      }
      if (dataPoint.percentile50 != null) {
        p50Spots.add(FlSpot(x, dataPoint.percentile50!));
      }
      if (dataPoint.percentile85 != null) {
        p85Spots.add(FlSpot(x, dataPoint.percentile85!));
      }
      if (dataPoint.percentile97 != null) {
        p97Spots.add(FlSpot(x, dataPoint.percentile97!));
      }
      if (dataPoint.actualWeight != null) {
        actualSpots.add(FlSpot(x, dataPoint.actualWeight!));
      }

      // Crear spots para el área sombreada (rango normal P15-P85)
      if (dataPoint.percentile15 != null && dataPoint.percentile85 != null) {
        normalRangeSpots.add(FlSpot(x, dataPoint.percentile85!));
      }
    }

    // Crear spots invertidos para cerrar el polígono (de P15 en reversa)
    final normalRangeSpotsReversed = <FlSpot>[];
    for (int i = data.length - 1; i >= 0; i--) {
      final dataPoint = data[i];
      if (dataPoint.percentile15 != null) {
        normalRangeSpotsReversed.add(
          FlSpot(i.toDouble(), dataPoint.percentile15!),
        );
      }
    }
    
    // Asegurar que el polígono esté cerrado correctamente
    final normalRangePolygon = <FlSpot>[];
    if (normalRangeSpots.isNotEmpty && normalRangeSpotsReversed.isNotEmpty) {
      // Ir de P85[0] a P85[n]
      normalRangePolygon.addAll(normalRangeSpots);
      // Si el último punto de P85 no coincide con el último de P15, agregar un punto de cierre
      if (normalRangeSpots.last.x != normalRangeSpotsReversed.first.x ||
          normalRangeSpots.last.y != normalRangeSpotsReversed.first.y) {
        // Ya está bien conectado, solo agregamos los reversos
      }
      // Volver de P15[n] a P15[0] para cerrar el polígono
      normalRangePolygon.addAll(normalRangeSpotsReversed);
      // Cerrar el polígono conectando el último punto con el primero
      if (normalRangePolygon.isNotEmpty) {
        normalRangePolygon.add(normalRangePolygon.first);
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 0.5,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: data.length > 7 ? (data.length / 7).ceil().toDouble() : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 0.5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toStringAsFixed(1)}',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: minWeight,
      maxY: maxWeight,
      lineBarsData: [
        // Percentil 3 (gris muy claro)
        if (p3Spots.isNotEmpty)
          LineChartBarData(
            spots: p3Spots,
            isCurved: p3Spots.length > 2, // Solo curvar si hay más de 2 puntos
            color: Colors.grey.withOpacity(0.3),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Percentil 15 (gris claro) - límite inferior del rango normal
        if (p15Spots.isNotEmpty)
          LineChartBarData(
            spots: p15Spots,
            isCurved: p15Spots.length > 2, // Solo curvar si hay más de 2 puntos
            color: Colors.grey.withOpacity(0.4),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Área sombreada para rango normal (P15-P85) - franja gris
        // Usamos un polígono cerrado para crear el área entre P15 y P85
        if (normalRangePolygon.isNotEmpty && normalRangePolygon.length >= 4)
          LineChartBarData(
            spots: normalRangePolygon,
            isCurved: false, // Polígono cerrado, no necesita curvar
            color: Colors.transparent,
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.grey[200]!.withOpacity(0.3),
            ),
          ),
        // Percentil 50 (mediana) - línea más visible
        if (p50Spots.isNotEmpty)
          LineChartBarData(
            spots: p50Spots,
            isCurved: p50Spots.length > 2, // Solo curvar si hay más de 2 puntos
            color: Colors.grey[400]!,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Línea superior del rango normal (P85) - límite superior del rango normal
        if (p85Spots.isNotEmpty)
          LineChartBarData(
            spots: p85Spots,
            isCurved: p85Spots.length > 2, // Solo curvar si hay más de 2 puntos
            color: Colors.grey[300]!,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Percentil 97 (gris muy claro)
        if (p97Spots.isNotEmpty)
          LineChartBarData(
            spots: p97Spots,
            isCurved: p97Spots.length > 2, // Solo curvar si hay más de 2 puntos
            color: Colors.grey.withOpacity(0.3),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        // Peso real del bebé (verde destacado)
        if (actualSpots.isNotEmpty)
          LineChartBarData(
            spots: actualSpots,
            // Solo curvar si hay más de 2 puntos, de lo contrario será una línea recta
            isCurved: actualSpots.length > 2,
            curveSmoothness: 0.35, // Suavidad de la curva
            color: const Color(0xFF03A696), // Color del tema
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF03A696),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: actualSpots.length > 1, // Solo mostrar área si hay más de un punto
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF03A696).withOpacity(0.1),
                  const Color(0xFF03A696).withOpacity(0.0),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(const Color(0xFF03A696), 'Peso del bebé'),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.grey[400]!, 'Mediana (P50)'),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.grey[200]!, 'Rango normal'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'No hay suficientes datos para mostrar la tendencia',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registra el peso de tu bebé para ver la gráfica',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Importante',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: Text(
            'Esta información es solo orientativa y no reemplaza el consejo médico profesional. '
            'Cualquier preocupación sobre el peso o la alimentación de tu bebé debe ser consultada '
            'con un pediatra o nutricionista.',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF03A696),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

