import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/settings_entities.dart';

class StatisticsWidget extends StatelessWidget {
  final UserStatistics statistics;

  const StatisticsWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título del gráfico
            Text(
              'Videos Vistos por Categoría',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Gráfico de barras
            Expanded(child: _buildBarChart()),

            const SizedBox(height: 20),

            // Leyenda
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final categories = statistics.videosWatchedByCategory.keys.toList();
    final values = statistics.videosWatchedByCategory.values.toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: values.isNotEmpty
            ? values.reduce((a, b) => a > b ? a : b).toDouble() + 5
            : 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${categories[group.x.toInt()]}\n${rod.toY.toInt()} videos',
                GoogleFonts.quicksand(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[value.toInt()],
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          categories.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                color: _getBarColor(index),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final categories = statistics.videosWatchedByCategory.keys.toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final value = statistics.videosWatchedByCategory[category] ?? 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getBarColor(index),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$category: $value',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];

    return colors[index % colors.length];
  }
}
