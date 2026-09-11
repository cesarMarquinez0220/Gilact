import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
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
    if (kDebugMode) {
      print(
        '🔵 PostpartoProfileWidget: Iniciando carga de datos de tendencia...',
      );
    }

    if (widget.userProfile.babyInfo == null) {
      if (kDebugMode) {
        print(
          '⚠️ PostpartoProfileWidget: No hay información del bebé disponible',
        );
      }
      setState(() {
        _isLoadingTrend = false;
      });
      return;
    }

    try {
      // Obtener fecha de nacimiento
      final birthDateStr = widget.userProfile.babyInfo!.birthDate;
      final birthDate = DateTime.parse(birthDateStr);

      if (kDebugMode) {
        print('📅 PostpartoProfileWidget: Fecha de nacimiento: $birthDateStr');
        print('📅 PostpartoProfileWidget: Fecha parseada: $birthDate');
      }

      // Obtener userId
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ PostpartoProfileWidget: No hay usuario autenticado');
        }
        setState(() {
          _isLoadingTrend = false;
        });
        return;
      }

      if (kDebugMode) {
        print(
          '👤 PostpartoProfileWidget: Usuario autenticado - UID: ${user.uid}, Email: ${user.email}',
        );
      }

      // Obtener userDocId
      String? userId;
      if (user.email != null) {
        if (kDebugMode) {
          print(
            '🔍 PostpartoProfileWidget: Buscando userDocId por email: ${user.email}',
          );
        }
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userId = userQuery.docs.first.id;
          if (kDebugMode) {
            print('✅ PostpartoProfileWidget: userDocId encontrado: $userId');
          }
        } else {
          if (kDebugMode) {
            print(
              '⚠️ PostpartoProfileWidget: No se encontró userDocId por email, usando UID',
            );
          }
        }
      }
      userId ??= user.uid;

      // Cargar datos de tendencia
      if (kDebugMode) {
        print('🆔 PostpartoProfileWidget: userId final a usar: $userId');
        print(
          '📊 PostpartoProfileWidget: Llamando a getWeightTrend (últimos 30 días)...',
        );
        print('   - Fecha de nacimiento: $birthDate');
      }

      final analysis = await _trendService.getWeightTrend(
        birthDate,
        userId,
        daysBack: 30,
      );

      if (kDebugMode) {
        print('📊 PostpartoProfileWidget: Datos recibidos del servicio:');
        print('   - Total de días en trendData: ${analysis.trendData.length}');
        final dataWithWeight = analysis.trendData
            .where((data) => data.actualWeight != null)
            .toList();
        print('   - Días con peso real: ${dataWithWeight.length}');
        final dataWithVolume = analysis.trendData
            .where(
              (data) => data.feedingVolume != null && data.feedingVolume! > 0,
            )
            .toList();
        print('   - Días con volumen de leche: ${dataWithVolume.length}');
      }

      // SOLO usar datos reales - NO generar datos simulados
      // Esto evita confusión y ansiedad en las madres al mostrar datos que no registraron
      final finalAnalysis = analysis;

      if (kDebugMode) {
        final hasRealWeightData = analysis.trendData.any(
          (data) => data.actualWeight != null,
        );
        if (hasRealWeightData) {
          print('✅ PostpartoProfileWidget: Usando datos reales');
        } else {
          print(
            'ℹ️ PostpartoProfileWidget: No hay datos reales - se mostrará estado vacío',
          );
        }
      }

      if (mounted) {
        setState(() {
          _trendAnalysis = finalAnalysis;
          _isLoadingTrend = false;
        });
        if (kDebugMode) {
          print(
            '✅ PostpartoProfileWidget: Estado actualizado, carga completada',
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          '❌ PostpartoProfileWidget: Error cargando datos de tendencia: $e',
        );
        print('❌ Stack trace: $stackTrace');
      }
      if (mounted) {
        setState(() {
          // Inicializar con análisis vacío en caso de error para que se muestren las gráficas
          _trendAnalysis = const GrowthTrendAnalysis(trendData: []);
          _isLoadingTrend = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildBabyInfo() {
    return Container(
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
                    'baby.data.title'.tr(),
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
                    'baby.data.name'.tr(),
                    widget.userProfile.babyInfo!.name,
                  ),
                  _buildInfoRow(
                    'baby.data.gestationalAge'.tr(),
                    '${widget.userProfile.babyInfo!.gestationalAge} ${'baby.data.weeks'.tr()}',
                  ),
                  _buildInfoRow(
                    'baby.data.birthDate'.tr(),
                    _formatBirthDate(
                      context,
                      widget.userProfile.babyInfo!.birthDate,
                    ),
                  ),
                  _buildInfoRow(
                    'baby.data.birthPlace'.tr(),
                    widget.userProfile.babyInfo!.birthPlace,
                  ),
                  _buildInfoRow(
                    'baby.data.weight'.tr(),
                    '${widget.userProfile.babyInfo!.weight} kg',
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      'baby.data.noInfoAvailable'.tr(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formatea la fecha de nacimiento a un formato legible
  String _formatBirthDate(BuildContext context, String birthDateStr) {
    try {
      // Intentar parsear la fecha
      final birthDate = DateTime.parse(birthDateStr);

      // Formatear según el locale
      final locale = context.locale.toString();
      final dateFormat = DateFormat.yMMMMd(locale);

      return dateFormat.format(birthDate);
    } catch (e) {
      // Si falla el parseo, devolver la fecha original
      if (kDebugMode) {
        print('Error formateando fecha de nacimiento: $e');
      }
      return birthDateStr;
    }
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
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Si no hay análisis, crear uno vacío para que se muestren las gráficas con estado vacío
    final analysis = _trendAnalysis ?? const GrowthTrendAnalysis(trendData: []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alertas si las hay
        if (analysis.hasAlert)
          GrowthAlertWidget(
            analysis: analysis,
            babyName: widget.userProfile.babyInfo?.name,
          ),
        // Título de sección de tendencias
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'growth.trendTitle'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Gráfica de peso con percentiles (PRINCIPAL - ¿Está creciendo bien?)
        BabyWeightTrendChart(trendData: analysis.trendData),
        const SizedBox(height: 16),
        // Gráfica de ingesta de leche (SECUNDARIA - Contexto: ¿Por qué crece así?)
        FeedingVolumeChart(trendData: analysis.trendData),
      ],
    );
  }
}
