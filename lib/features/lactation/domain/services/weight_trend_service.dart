import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/weight_trend_data.dart';
import 'who_percentiles_service.dart';
import 'feeding_analysis_service.dart';
import 'growth_alert_service.dart';
import '../../data/datasources/baby_weight_offline_local_data_source.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/entities/baby_weight_record.dart';
import '../../../../core/services/connectivity_service.dart';

/// Servicio principal para obtener datos de tendencia de peso
class WeightTrendService {
  static final WeightTrendService _instance = WeightTrendService._internal();
  factory WeightTrendService() => _instance;
  WeightTrendService._internal();

  final WHOPercentilesService _whoService = WHOPercentilesService();
  final FeedingAnalysisService _feedingService = FeedingAnalysisService();
  final GrowthAlertService _alertService = GrowthAlertService();
  final BabyWeightOfflineLocalDataSource _weightDataSource =
      BabyWeightOfflineLocalDataSource();
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Obtiene datos de tendencia de peso para un período
  /// [birthDate] - Fecha de nacimiento del bebé
  /// [userId] - ID del usuario
  /// [daysBack] - Días hacia atrás desde hoy (default: 30)
  Future<GrowthTrendAnalysis> getWeightTrend(
    DateTime birthDate,
    String userId, {
    int daysBack = 30,
  }) async {
    try {
      final today = DateTime.now();
      final startDate = today.subtract(Duration(days: daysBack));
      final endDate = today;

      // 1. Obtener registros de peso
      final weightRecords = await _getWeightRecords(
        startDate,
        endDate,
        userId,
      );

      // 2. Obtener datos de alimentación
      final feedingData = await _feedingService.getDailyFeedingData(
        startDate,
        endDate,
        userId,
      );

      // 3. Crear mapa de alimentación por fecha para acceso rápido
      final feedingMap = <String, DailyFeedingData>{};
      for (final data in feedingData) {
        final key = '${data.date.year}-${data.date.month}-${data.date.day}';
        feedingMap[key] = data;
      }

      // 4. Generar datos de tendencia día por día
      final trendData = <WeightTrendData>[];
      final days = endDate.difference(startDate).inDays + 1;

      for (int i = 0; i < days; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final ageInDays = currentDate.difference(birthDate).inDays;

        if (ageInDays < 0) continue; // No incluir fechas antes del nacimiento

        // Buscar registro de peso para esta fecha
        final weightKey =
            '${currentDate.year}-${currentDate.month}-${currentDate.day}';
        final weightRecord = weightRecords[weightKey];

        // Obtener percentiles OMS para esta edad
        final percentiles = _whoService.getAllPercentiles(ageInDays);

        // Obtener datos de alimentación para esta fecha
        final feeding = feedingMap[weightKey];

        // Calcular score de alimentación si hay datos
        double? feedingScore;
        if (feeding != null) {
          feedingScore = _feedingService.calculateFeedingScore(
            feeding,
            ageInDays,
          );
        }

        trendData.add(WeightTrendData(
          date: currentDate,
          ageInDays: ageInDays,
          actualWeight: weightRecord?.weight,
          percentile3: percentiles['p3'],
          percentile15: percentiles['p15'],
          percentile50: percentiles['p50'],
          percentile85: percentiles['p85'],
          percentile97: percentiles['p97'],
          feedingVolume: feeding?.totalVolume,
          feedingFrequency: feeding?.feedingFrequency,
          feedingScore: feedingScore,
        ));
      }

      // 5. Analizar tendencia y detectar alertas
      final analysis = _alertService.analyzeGrowthTrend(trendData);

      if (kDebugMode) {
        print(
          '✅ WeightTrendService: Datos de tendencia generados para ${trendData.length} días',
        );
      }

      return analysis;
    } catch (e) {
      if (kDebugMode) {
        print('❌ WeightTrendService: Error obteniendo tendencia: $e');
      }
      return const GrowthTrendAnalysis(trendData: []);
    }
  }

  /// Obtiene registros de peso para un rango de fechas
  Future<Map<String, BabyWeightRecord>> _getWeightRecords(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    try {
      final records = <BabyWeightRecord>[];

      // Intentar obtener desde Firestore si hay conexión
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Obtener ID del documento del usuario
            String? userDocId = userId;
            if (user.email != null) {
              final userQuery = await FirebaseFirestore.instance
                  .collection('Users')
                  .where('email', isEqualTo: user.email)
                  .limit(1)
                  .get();
              if (userQuery.docs.isNotEmpty) {
                userDocId = userQuery.docs.first.id;
              }
            }

            if (userDocId != null) {
              final weightCollection = FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userDocId)
                  .collection('situacion')
                  .doc('seleccion')
                  .collection('peso');

              final querySnapshot = await weightCollection
                  .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
                  .where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
                  .orderBy('timestamp', descending: false)
                  .get();

              for (final doc in querySnapshot.docs) {
                final data = doc.data();
                final recordedAt = data['fecha_peso'] != null
                    ? DateTime.parse(data['fecha_peso'] as String)
                    : DateTime.fromMillisecondsSinceEpoch(
                        data['timestamp'] as int,
                      );

                records.add(BabyWeightRecord(
                  id: doc.id,
                  userId: userDocId,
                  weight: (data['peso'] as num).toDouble(),
                  recordedAt: recordedAt,
                  notes: data['notas'] as String?,
                  createdAt: recordedAt,
                  updatedAt: recordedAt,
                ));
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              '⚠️ WeightTrendService: Error obteniendo desde Firestore: $e',
            );
          }
        }
      }

      // También obtener desde datos locales
      try {
        final localRecords = await _weightDataSource.getAllRecords();
        records.addAll(localRecords);
      } catch (e) {
        if (kDebugMode) {
          print(
            '⚠️ WeightTrendService: Error obteniendo datos locales: $e',
          );
        }
      }

      // Crear mapa por fecha para acceso rápido
      final recordsMap = <String, BabyWeightRecord>{};
      for (final record in records) {
        final key =
            '${record.recordedAt.year}-${record.recordedAt.month}-${record.recordedAt.day}';
        // Si hay múltiples registros para el mismo día, usar el más reciente
        if (!recordsMap.containsKey(key) ||
            record.recordedAt.isAfter(recordsMap[key]!.recordedAt)) {
          recordsMap[key] = record;
        }
      }

      return recordsMap;
    } catch (e) {
      if (kDebugMode) {
        print('❌ WeightTrendService: Error obteniendo registros de peso: $e');
      }
      return {};
    }
  }
}

