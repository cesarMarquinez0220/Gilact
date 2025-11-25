import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget responsive para mostrar información de la app
class AppInfoCardWidget extends StatelessWidget {
  final String appVersion;

  const AppInfoCardWidget({
    super.key,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? (constraints.maxWidth - 600) / 2 : 0,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withValues(alpha: 0.8),
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gilact',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'account.version'.tr()} $appVersion',
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

