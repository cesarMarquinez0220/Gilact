import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../user/domain/entities/user_profile_entities.dart';
import '../../../growth_tracking/domain/services/weight_trend_service.dart';
import '../../../growth_tracking/domain/entities/weight_trend_data.dart';
import '../../../growth_tracking/presentation/widgets/baby_weight_trend_chart.dart';
import '../../../growth_tracking/presentation/widgets/feeding_volume_chart.dart';
import '../../../growth_tracking/presentation/widgets/growth_alert_widget.dart';

/// Widget simplificado para mostrar solo datos del bebé para usuarios postparto
class PostpartoProfileWidget extends StatefulWidget {
  final UserProfile userProfile;

  const PostpartoProfileWidget({super.key, required this.userProfile});

  @override
  State<PostpartoProfileWidget> createState() => _PostpartoProfileWidgetState();
}

class _PostpartoProfileWidgetState extends State<PostpartoProfileWidget> {
  final WeightTrendService _trendService = WeightTrendService();
  GrowthTrendAnalysis? _trendAnalysis;
  bool _isLoadingTrend = true;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    if (widget.userProfile.babyInfo == null) {
      setState(() {
        _isLoadingTrend = false;
      });
      return;
    }

    try {
      // Obtener fecha de nacimiento
      final birthDateStr = widget.userProfile.babyInfo!.birthDate;
      final birthDate = DateTime.parse(birthDateStr);

      // Obtener userId
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingTrend = false;
        });
        return;
      }

      // Obtener userDocId
      String? userId;
      if (user.email != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userId = userQuery.docs.first.id;
        }
      }
      userId ??= user.uid;

      // Cargar datos de tendencia
      final analysis = await _trendService.getWeightTrend(
        birthDate,
        userId,
        daysBack: 30,
      );

      if (mounted) {
        setState(() {
          _trendAnalysis = analysis;
          _isLoadingTrend = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTrend = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBabyInfo(),
          const SizedBox(height: 20),
          // Sección de tendencias
          if (widget.userProfile.babyInfo != null) ...[
            _buildTrendSection(),
            const SizedBox(height: 20),
          ],
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
                  if (widget.userProfile.babyInfo != null) ...[
                    _buildInfoRow(
                      'Nombre del bebé',
                      widget.userProfile.babyInfo!.name,
                    ),
                    _buildInfoRow(
                      'Edad Gestacional',
                      '${widget.userProfile.babyInfo!.gestationalAge} semanas',
                    ),
                    _buildInfoRow(
                      'Fecha de Nacimiento',
                      widget.userProfile.babyInfo!.birthDate,
                    ),
                    _buildInfoRow(
                      'Lugar de Nacimiento',
                      widget.userProfile.babyInfo!.birthPlace,
                    ),
                    _buildInfoRow(
                      'Peso',
                      '${widget.userProfile.babyInfo!.weight} kg',
                    ),
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

  Widget _buildTrendSection() {
    if (_isLoadingTrend) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_trendAnalysis == null || _trendAnalysis!.trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alertas si las hay
        if (_trendAnalysis!.hasAlert)
          GrowthAlertWidget(
            analysis: _trendAnalysis!,
            babyName: widget.userProfile.babyInfo?.name,
          ),
        // Título de sección de tendencias
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Tendencia de Crecimiento',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Gráfica de peso con percentiles (PRINCIPAL - ¿Está creciendo bien?)
        BabyWeightTrendChart(trendData: _trendAnalysis!.trendData),
        const SizedBox(height: 16),
        // Gráfica de ingesta de leche (SECUNDARIA - Contexto: ¿Por qué crece así?)
        FeedingVolumeChart(trendData: _trendAnalysis!.trendData),
      ],
    );
  }
}
