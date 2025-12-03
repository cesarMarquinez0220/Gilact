import 'package:flutter/material.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/domain/entities/baby_weight_record.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';
import '../../../lactation/domain/entities/sleep_record.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Provider para manejar el estado de registros de salud de manera reactiva
class HealthProvider extends ChangeNotifier {
  final AppLogger _logger = getIt<AppLogger>();

  BabyWeightRecord? _lastWeightRecord;
  SleepRecord? _lastSleepRecord;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  BabyWeightRecord? get lastWeightRecord => _lastWeightRecord;
  SleepRecord? get lastSleepRecord => _lastSleepRecord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los registros recientes de peso y sueño
  Future<void> loadRecentData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Cargar último registro de peso
      final weightDataSource = BabyWeightOfflineLocalDataSource();
      final weightRecords = await weightDataSource.getAllRecords();
      if (weightRecords.isNotEmpty) {
        weightRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        _lastWeightRecord = weightRecords.first;
      } else {
        _lastWeightRecord = null;
      }

      // Cargar último registro de sueño
      final sleepDataSource = SleepOfflineLocalDataSource();
      final sleepRecords = await sleepDataSource.getAllRecords();
      if (sleepRecords.isNotEmpty) {
        sleepRecords.sort(
          (a, b) => b.sleepStartTime.compareTo(a.sleepStartTime),
        );
        _lastSleepRecord = sleepRecords.first;
      } else {
        _lastSleepRecord = null;
      }

      _isLoading = false;
      notifyListeners();
      _logger.d('HealthProvider: Datos cargados exitosamente');
    } catch (e, stackTrace) {
      _errorMessage = 'Error cargando datos: $e';
      _isLoading = false;
      notifyListeners();
      _logger.e('HealthProvider: Error cargando datos', e, stackTrace);
    }
  }

  /// Recarga los datos (útil cuando se guarda un nuevo registro)
  Future<void> refresh() async {
    await loadRecentData();
  }
}

