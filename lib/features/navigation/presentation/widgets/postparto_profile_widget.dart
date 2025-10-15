import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../../user/domain/entities/user_profile_entities.dart';

/// Widget simplificado para mostrar solo datos del bebé para usuarios postparto
class PostpartoProfileWidget extends StatelessWidget {
  final UserProfile userProfile;

  const PostpartoProfileWidget({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBabyInfo(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBabyInfo() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Datos del Bebé",
                      style: GoogleFonts.quicksand(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (userProfile.babyInfo != null) ...[
                    _buildInfoRow(
                      'Nombre del bebé',
                      userProfile.babyInfo!.name,
                    ),
                    _buildInfoRow(
                      'Edad Gestacional',
                      '${userProfile.babyInfo!.gestationalAge} semanas',
                    ),
                    _buildInfoRow(
                      'Fecha de Nacimiento',
                      userProfile.babyInfo!.birthDate,
                    ),
                    _buildInfoRow(
                      'Lugar de Nacimiento',
                      userProfile.babyInfo!.birthPlace,
                    ),
                    _buildInfoRow('Peso', '${userProfile.babyInfo!.weight} kg'),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No hay información del bebé disponible',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
