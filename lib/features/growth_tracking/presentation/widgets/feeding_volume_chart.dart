import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../domain/entities/weight_trend_data.dart';

/// Widget para mostrar gráfica de ingesta de leche diaria
class FeedingVolumeChart extends StatelessWidget {
  final List<WeightTrendData> trendData;
  final double? expectedVolume; // Volumen esperado según edad

  const FeedingVolumeChart({
    super.key,
    required this.trendData,
    this.expectedVolume,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar datos con volumen de alimentación
    final dataWithVolume =
        trendData.where((data) => data.feedingVolume != null).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (dataWithVolume.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: _buildEmptyState(),
      );
    }

    // Calcular rango máximo
    final maxVolume =
        dataWithVolume
            .map((d) => d.feedingVolume ?? 0)
            .reduce((a, b) => a > b ? a : b) *
        1.2; // 20% más para espacio visual

    // Calcular estadísticas
    // Filtrar solo días con volumen > 0 para estadísticas reales
    final dataWithRealVolume = dataWithVolume
        .where((d) => (d.feedingVolume ?? 0) > 0)
        .toList();

    if (dataWithRealVolume.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: _buildEmptyState(),
      );
    }

    final totalVolume = dataWithRealVolume
        .map((d) => d.feedingVolume ?? 0)
        .reduce((a, b) => a + b);
    final averageVolume = totalVolume / dataWithRealVolume.length;
    // Último registro real (último día con volumen > 0)
    final latestVolume = dataWithRealVolume.last.feedingVolume ?? 0;

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
                  Icons.local_drink,
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
                  'Total de Leche Extraída',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Volumen diario de leche extraída y medida',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Solo incluye leche extraída. No incluye lactancia directa al pecho.',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Mini estadísticas
                _buildQuickStats(
                  averageVolume,
                  latestVolume,
                  dataWithRealVolume.last.date,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(_buildChartData(dataWithVolume, maxVolume)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye mini estadísticas rápidas
  Widget _buildQuickStats(
    double averageVolume,
    double latestVolume,
    DateTime latestDate,
  ) {
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
          // Promedio
          Expanded(
            child: _buildStatItem(
              'Promedio diario',
              '${averageVolume.toStringAsFixed(0)} ml',
              Icons.analytics_outlined,
              Colors.blue,
              subtitle: 'Solo extraída',
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          // Último registro
          Expanded(
            child: _buildStatItem(
              'Último registro',
              '${latestVolume.toStringAsFixed(0)} ml',
              Icons.local_drink,
              const Color(0xFF03A696),
              subtitle: '${latestDate.day}/${latestDate.month}',
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
    Color color, {
    String? subtitle,
  }) {
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
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.quicksand(fontSize: 8, color: Colors.grey[500]),
          ),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 9, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  BarChartData _buildChartData(List<WeightTrendData> data, double maxVolume) {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final volume = dataPoint.feedingVolume ?? 0.0;

      // Determinar color según volumen
      Color barColor;
      if (expectedVolume != null) {
        final ratio = volume / expectedVolume!;
        if (ratio >= 0.9) {
          barColor = Colors.green.withOpacity(0.7); // Normal
        } else if (ratio >= 0.7) {
          barColor = Colors.orange.withOpacity(0.7); // Bajo
        } else {
          barColor = Colors.red.withOpacity(0.7); // Muy bajo
        }
      } else {
        barColor = const Color(0xFF03A696).withOpacity(0.7);
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: volume,
              color: barColor,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxVolume / 5,
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
              final index = value.toInt();
              if (index >= 0 && index < data.length) {
                final date = data[index].date;
                // Mostrar solo cada 3-5 días para evitar saturación
                if (data.length <= 7 ||
                    index % ((data.length / 7).ceil()) == 0) {
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
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxVolume / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
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
      minY: 0,
      maxY: maxVolume,
      barGroups: barGroups,
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
            Icon(Icons.local_drink, color: Colors.grey[400], size: 40),
            const SizedBox(height: 12),
            Text(
              'No hay datos de alimentación registrados',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[600],
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

