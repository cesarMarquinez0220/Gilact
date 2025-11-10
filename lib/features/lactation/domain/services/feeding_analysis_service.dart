import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/entities/lactation_record.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/datasources/baby_weight_offline_local_data_source.dart';
import '../../domain/entities/baby_weight_record.dart';
import '../../data/datasources/lactation_database.dart';

/// Datos de alimentación diaria
class DailyFeedingData {
  final DateTime date;
  final double totalVolume; // ml
  final int feedingFrequency; // veces que comió
  final int totalDuration; // minutos totales
  final int breastFeedingCount; // veces pecho
  final int bottleFeedingCount; // veces biberón

  const DailyFeedingData({
    required this.date,
    required this.totalVolume,
    required this.feedingFrequency,
    required this.totalDuration,
    required this.breastFeedingCount,
    required this.bottleFeedingCount,
  });
}

/// Servicio para analizar datos de alimentación y correlacionarlos con el peso
class FeedingAnalysisService {
  static final FeedingAnalysisService _instance =
      FeedingAnalysisService._internal();
  factory FeedingAnalysisService() => _instance;
  FeedingAnalysisService._internal();

  // Instancia compartida de LactationService para evitar crear múltiples instancias
  LactationService? _lactationService;
  final BabyWeightOfflineLocalDataSource _weightDataSource =
      BabyWeightOfflineLocalDataSource();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  /// Obtiene o crea la instancia compartida de LactationService
  LactationService _getLactationService() {
    _lactationService ??= LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
    return _lactationService!;
  }

  /// Obtiene datos de alimentación agregados por día
  /// [startDate] - Fecha de inicio
  /// [endDate] - Fecha de fin
  /// [userId] - ID del usuario
  Future<List<DailyFeedingData>> getDailyFeedingData(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    try {
      // OPTIMIZACIÓN: Obtener todos los registros de una vez en lugar de día por día
      final allRecords = await _getAllLactationRecordsForRange(startDate, endDate);
      
      // Crear mapa de registros por fecha para acceso rápido
      final recordsByDate = <String, List<LactationRecord>>{};
      for (final record in allRecords) {
        final dateKey = '${record.fechaRegistro.year}-${record.fechaRegistro.month}-${record.fechaRegistro.day}';
        recordsByDate.putIfAbsent(dateKey, () => []).add(record);
      }
      
      // Generar datos diarios
      final days = endDate.difference(startDate).inDays + 1;
      final dailyData = <DailyFeedingData>[];

      for (int i = 0; i < days; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayStart = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final dateKey = '${dayStart.year}-${dayStart.month}-${dayStart.day}';
        
        // Obtener registros del día desde el mapa
        final dayRecords = recordsByDate[dateKey] ?? [];

        // Agregar datos del día
        final feedingData = _aggregateDayData(dayStart, dayRecords);
        dailyData.add(feedingData);
      }

      if (kDebugMode) {
        print(
          '✅ FeedingAnalysisService: Datos de alimentación obtenidos para ${days} días (${allRecords.length} registros totales)',
        );
      }

      return dailyData;
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ FeedingAnalysisService: Error obteniendo datos de alimentación: $e',
        );
      }
      return [];
    }
  }
  
  /// Obtiene todos los registros de lactancia para un rango de fechas
  /// OPTIMIZACIÓN: Una sola consulta a Firestore en lugar de 31 consultas separadas
  Future<List<LactationRecord>> _getAllLactationRecordsForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final lactationService = _getLactationService();
      final allRecords = <LactationRecord>[];
      
      // Obtener registros locales para el rango completo usando la base de datos local directamente
      try {
        final localDatabase = LactationDatabase();
        final startOfRange = DateTime(startDate.year, startDate.month, startDate.day);
        final endOfRange = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
        
        // Obtener todos los registros locales y filtrar por rango
        // Usar getRecordsForDate en un loop optimizado o getAllRecords si existe
        final allLocalRecords = <LactationRecord>[];
        
        // Obtener registros día por día desde la base de datos local (más eficiente que getAllRecords)
        final days = endDate.difference(startDate).inDays + 1;
        for (int i = 0; i < days; i++) {
          final currentDate = startDate.add(Duration(days: i));
          final dayRecords = await localDatabase.getRecordsForDate(currentDate);
          allLocalRecords.addAll(dayRecords);
        }
        final localRecordsInRange = allLocalRecords.where((r) {
          final recordDate = r.fechaRegistro;
          return recordDate.isAfter(startOfRange.subtract(const Duration(days: 1))) &&
                 recordDate.isBefore(endOfRange);
        }).toList();
        
        allRecords.addAll(localRecordsInRange);
        
        if (kDebugMode) {
          print('📦 FeedingAnalysisService: ${localRecordsInRange.length} registros locales encontrados');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ FeedingAnalysisService: Error obteniendo registros locales: $e');
        }
      }
      
      // Si hay conexión, obtener también de Firestore (UNA SOLA CONSULTA)
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          final startOfRange = DateTime(startDate.year, startDate.month, startDate.day);
          final endOfRange = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
          
          // OPTIMIZACIÓN: Una sola consulta a Firestore para todo el rango
          // Obtener userId primero para construir la colección
          final userDocId = await lactationService.getUserDocumentId();
          if (userDocId == null) {
            if (kDebugMode) {
              print('⚠️ FeedingAnalysisService: No se pudo obtener userId');
            }
            return allRecords..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }
          
          final collection = FirebaseFirestore.instance
              .collection('Users')
              .doc(userDocId)
              .collection('situacion')
              .doc('seleccion')
              .collection('lactancia');
          final querySnapshot = await collection
              .where('fecha_registro', isGreaterThanOrEqualTo: startOfRange.toIso8601String())
              .where('fecha_registro', isLessThan: endOfRange.toIso8601String())
              .orderBy('fecha_registro', descending: true)
              .get();
          
          final firestoreRecords = querySnapshot.docs
              .map((doc) => LactationRecord.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
              .toList();
          
          if (kDebugMode) {
            print('☁️ FeedingAnalysisService: ${firestoreRecords.length} registros de Firestore encontrados');
          }
          
          // Combinar: usar Firestore como fuente de verdad, agregar locales no sincronizados
          final Map<String, LactationRecord> combined = {};
          
          // Primero agregar de Firestore
          for (final record in firestoreRecords) {
            combined[record.id] = record;
          }
          
          // Luego agregar locales que no estén en Firestore
          for (final record in allRecords) {
            if (!combined.containsKey(record.id)) {
              combined[record.id] = record;
            }
          }
          
          return combined.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ FeedingAnalysisService: Error obteniendo desde Firestore: $e');
          }
        }
      }
      
      // Si no hay conexión o falló Firestore, retornar solo locales
      return allRecords..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      if (kDebugMode) {
        print('❌ FeedingAnalysisService: Error obteniendo registros: $e');
      }
      return [];
    }
  }


  /// Agrega datos de un día
  /// IMPORTANTE: Solo cuenta volumen REAL de biberón, NO estima volumen de pecho
  /// El volumen de lactancia al pecho NO puede estimarse de forma confiable basándose en duración
  DailyFeedingData _aggregateDayData(
    DateTime date,
    List<LactationRecord> records,
  ) {
    double totalVolume = 0.0; // Solo volumen REAL de biberón
    int feedingFrequency = 0;
    int totalDuration = 0;
    int breastFeedingCount = 0;
    int bottleFeedingCount = 0;

    for (final record in records) {
      // Frecuencia
      feedingFrequency += record.vecesPecho + record.vecesBiberon;
      breastFeedingCount += record.vecesPecho;
      bottleFeedingCount += record.vecesBiberon;

      // Duración (útil para patrones, pero NO para estimar volumen)
      totalDuration += record.duracion.inMinutes;

      // Volumen: SOLO contar volumen REAL de biberón
      // NO estimar volumen de pecho basado en duración (médicamente incorrecto)
      if (record.volumenExtraccion > 0) {
        // Convertir a ml si es necesario
        if (record.unidadVolumen.toLowerCase() == 'oz') {
          totalVolume += record.volumenExtraccion * 29.5735; // oz a ml
        } else {
          totalVolume += record.volumenExtraccion.toDouble();
        }
      }
      
      // NOTA: No estimamos volumen de pecho porque:
      // 1. El flujo de leche no es constante
      // 2. Los bebés se vuelven más eficientes con el tiempo
      // 3. Cada madre y bebé son diferentes
      // 4. Puede causar ansiedad innecesaria con datos falsos
      // Los indicadores reales de buena alimentación son: peso, pañales, y frecuencia de tomas
    }

    return DailyFeedingData(
      date: date,
      totalVolume: totalVolume, // Solo volumen real de biberón
      feedingFrequency: feedingFrequency,
      totalDuration: totalDuration,
      breastFeedingCount: breastFeedingCount,
      bottleFeedingCount: bottleFeedingCount,
    );
  }

  /// Obtiene el volumen esperado de leche según la edad del bebé (en ml)
  /// Basado en recomendaciones generales de ingesta diaria
  double getExpectedDailyVolume(int ageInDays) {
    if (ageInDays < 0) return 0.0;

    // Recomendaciones aproximadas de ingesta diaria según edad
    if (ageInDays <= 7) {
      // Primera semana: 30-60 ml por toma, 8-12 tomas al día
      return 30.0 * 8.0; // Mínimo estimado
    } else if (ageInDays <= 30) {
      // 1 mes: 60-120 ml por toma, 6-8 tomas al día
      return 80.0 * 7.0; // Promedio
    } else if (ageInDays <= 60) {
      // 2 meses: 120-150 ml por toma, 5-7 tomas al día
      return 135.0 * 6.0;
    } else if (ageInDays <= 90) {
      // 3 meses: 150-180 ml por toma, 5-6 tomas al día
      return 165.0 * 5.5;
    } else if (ageInDays <= 120) {
      // 4 meses: 180-210 ml por toma, 4-6 tomas al día
      return 195.0 * 5.0;
    } else if (ageInDays <= 150) {
      // 5 meses: 210-240 ml por toma, 4-5 tomas al día
      return 225.0 * 4.5;
    } else {
      // 6+ meses: 240+ ml por toma, 4-5 tomas al día
      return 240.0 * 4.5;
    }
  }

  /// Calcula un score de "buena alimentación" (0-100)
  /// IMPORTANTE: NO usa volumen estimado de pecho, solo frecuencia y duración
  /// El score se basa en patrones de alimentación, no en volumen estimado
  double calculateFeedingScore(DailyFeedingData feedingData, int ageInDays) {
    // Score de frecuencia (0-60 puntos)
    // Frecuencia esperada según edad
    final expectedFrequency = ageInDays <= 30 ? 8.0 : 
                             ageInDays <= 60 ? 7.0 :
                             ageInDays <= 90 ? 6.0 :
                             ageInDays <= 120 ? 5.5 : 5.0;
    final frequencyRatio = feedingData.feedingFrequency / expectedFrequency;
    final frequencyScore = (frequencyRatio.clamp(0.0, 1.5)) * 60.0;
    
    // Score de duración (0-40 puntos)
    // Duración esperada: al menos 10 min por toma
    final expectedDuration = expectedFrequency * 10.0;
    final durationRatio = feedingData.totalDuration / expectedDuration;
    final durationScore = (durationRatio.clamp(0.0, 1.5)) * 40.0;
    
    // NOTA: No usamos volumen porque:
    // - El volumen de pecho no puede estimarse de forma confiable
    // - Solo contamos volumen real de biberón
    // - El peso es el indicador real de buena alimentación
    
    final totalScore = frequencyScore + durationScore;
    return totalScore.clamp(0.0, 100.0);
  }
}

