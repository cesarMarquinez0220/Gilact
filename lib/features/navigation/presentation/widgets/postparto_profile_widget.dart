import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../user/domain/entities/user_profile_entities.dart';
import '../../../growth_tracking/domain/services/weight_trend_service.dart';
import '../../../growth_tracking/domain/services/who_percentiles_service.dart';
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

      // Verificar si hay datos reales
      final hasRealWeightData = analysis.trendData.any(
        (data) => data.actualWeight != null,
      );
      final hasRealFeedingData = analysis.trendData.any(
        (data) => data.feedingVolume != null && data.feedingVolume! > 0,
      );

      // DATOS DE PRUEBA: Solo generar datos de prueba de peso si no hay datos reales
      // NO generar datos de prueba de lactancia si no hay registros reales
      // Parsear el peso al nacer de String a double
      double? birthWeight;
      if (widget.userProfile.babyInfo?.weight != null) {
        birthWeight = double.tryParse(widget.userProfile.babyInfo!.weight);
      }
      final finalAnalysis = !hasRealWeightData
          ? _generateTestData(
              birthDate,
              birthWeight: birthWeight,
              includeFeedingData: hasRealFeedingData,
            )
          : analysis;

      if (kDebugMode) {
        if (!hasRealWeightData) {
          print('🧪 PostpartoProfileWidget: Generando datos de prueba...');
          print(
            '   - Días de prueba generados: ${finalAnalysis.trendData.length}',
          );
        } else {
          print('✅ PostpartoProfileWidget: Usando datos reales');
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

  /// Genera datos de prueba para visualizar las gráficas
  /// [birthWeight] - Peso al nacer del bebé (en kg). Si es null, usa 3.2 kg como default
  /// [includeFeedingData] - Si es false, NO genera datos de lactancia (para usuarios sin registros reales)
  GrowthTrendAnalysis _generateTestData(
    DateTime birthDate, {
    double? birthWeight,
    bool includeFeedingData = false,
  }) {
    if (kDebugMode) {
      print('🧪 _generateTestData: Generando datos de prueba...');
      print('   - Fecha de nacimiento: $birthDate');
      print('   - Peso al nacer: ${birthWeight ?? 3.2} kg');
      print('   - Incluir datos de lactancia: $includeFeedingData');
    }

    final today = DateTime.now();
    final testData = <WeightTrendData>[];

    // Usar el peso al nacer del bebé si está disponible, sino usar 3.2 kg como default
    final baseWeight = birthWeight ?? 3.2;

    // Generar datos para los últimos 30 días
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ageInDays = date.difference(birthDate).inDays;

      if (ageInDays < 0) continue;

      // Calcular percentiles OMS para esta edad
      final whoService = WHOPercentilesService();
      final percentiles = whoService.getAllPercentiles(ageInDays);

      // Simular peso que crece gradualmente desde el peso al nacer
      // Solo agregar peso real cada 3-4 días para simular registros reales
      double? actualWeight;
      if (i % 3 == 0 || i == 0) {
        // Peso inicial: peso al nacer + crecimiento diario
        // Los bebés recién nacidos pueden perder un poco de peso los primeros días,
        // luego ganan aproximadamente 20-30g por día
        const growthPerDay = 0.025; // 25g por día (promedio)
        // Para los primeros 7 días, considerar pérdida inicial de peso
        double weightAdjustment = 0.0;
        if (ageInDays <= 7) {
          // Pérdida inicial típica del 5-10% del peso al nacer
          weightAdjustment =
              -(baseWeight * 0.05) + (ageInDays * 0.01 * baseWeight);
        }
        actualWeight =
            baseWeight + weightAdjustment + (ageInDays * growthPerDay);
        // Asegurar que esté dentro de un rango razonable
        actualWeight = actualWeight.clamp(2.0, 10.0);
      }

      // SOLO simular volumen de leche si includeFeedingData es true
      // (es decir, solo si hay registros reales de lactancia)
      double? feedingVolume;
      int? feedingFrequency;
      if (includeFeedingData && (i % 2 == 0 || i == 0)) {
        // Volumen aumenta con la edad del bebé
        double baseVolume;
        if (ageInDays <= 7) {
          baseVolume = 240.0 + (i * 5.0); // Primera semana
          feedingFrequency = 8;
        } else if (ageInDays <= 30) {
          baseVolume = 560.0 + (i * 3.0); // Primer mes
          feedingFrequency = 7;
        } else if (ageInDays <= 60) {
          baseVolume = 810.0 + (i * 2.0); // Segundo mes
          feedingFrequency = 6;
        } else {
          baseVolume = 900.0 + (i * 1.5); // Tercer mes+
          feedingFrequency = 5;
        }
        // Agregar variación aleatoria pequeña
        feedingVolume = baseVolume + (i % 5 - 2) * 10.0;
        feedingVolume = feedingVolume.clamp(200.0, 1200.0);
      }

      testData.add(
        WeightTrendData(
          date: date,
          ageInDays: ageInDays,
          actualWeight: actualWeight,
          percentile3: percentiles['p3'],
          percentile15: percentiles['p15'],
          percentile50: percentiles['p50'],
          percentile85: percentiles['p85'],
          percentile97: percentiles['p97'],
          feedingVolume: feedingVolume,
          feedingFrequency: feedingFrequency,
          feedingScore: feedingFrequency != null ? 75.0 + (i % 10) : null,
        ),
      );
    }

    if (kDebugMode) {
      final dataWithWeight = testData
          .where((data) => data.actualWeight != null)
          .toList();
      final dataWithVolume = testData
          .where(
            (data) => data.feedingVolume != null && data.feedingVolume! > 0,
          )
          .toList();
      print('🧪 _generateTestData: Datos generados:');
      print('   - Total días: ${testData.length}');
      print('   - Días con peso: ${dataWithWeight.length}');
      print('   - Días con volumen: ${dataWithVolume.length}');
      if (dataWithWeight.isNotEmpty) {
        print('   - Primer peso: ${dataWithWeight.first.actualWeight} kg');
        print('   - Último peso: ${dataWithWeight.last.actualWeight} kg');
      }
    }

    return GrowthTrendAnalysis(trendData: testData, hasAlert: false);
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
