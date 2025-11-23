import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import '../../domain/entities/weight_trend_data.dart';

/// Widget para mostrar alertas de crecimiento
class GrowthAlertWidget extends StatelessWidget {
  final GrowthTrendAnalysis analysis;
  final String? babyName;

  const GrowthAlertWidget({super.key, required this.analysis, this.babyName});

  @override
  Widget build(BuildContext context) {
    if (!analysis.hasAlert || analysis.alertMessage == null) {
      return const SizedBox.shrink();
    }

    // Determinar color según tipo de alerta
    Color alertColor;
    IconData alertIcon;

    switch (analysis.alertType) {
      case 'weight_decreasing':
        alertColor = Colors.orange;
        alertIcon = Icons.trending_down;
        break;
      case 'feeding_low':
        alertColor = Colors.amber;
        alertIcon = Icons.warning;
        break;
      case 'correlation':
        alertColor = Colors.red;
        alertIcon = Icons.error_outline;
        break;
      default:
        alertColor = Colors.orange;
        alertIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withOpacity(0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(alertIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'growth.alertTitle'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analysis.alertMessage!,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'growth.disclaimer'.tr(),
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
