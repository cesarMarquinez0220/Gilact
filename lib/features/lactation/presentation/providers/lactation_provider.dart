import 'package:flutter/material.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/entities/lactation_record.dart';

/// Provider para manejar el estado de lactancia de manera reactiva
class LactationProvider extends ChangeNotifier {
  final LactationService _lactationService;

  LactationProvider(this._lactationService);

  // Estado de lactancia
  List<LactationRecord> _todayRecords = [];
  LactationStats? _todayStats;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<LactationRecord> get todayRecords => _todayRecords;
  LactationStats? get todayStats => _todayStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los datos del día actual
  Future<void> loadTodayData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final today = DateTime.now();
      final records = await _lactationService.getRecordsForDate(today);

      _todayRecords = records;
      _todayStats = _calculateTodayStats(records);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error cargando datos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresca los datos del día actual
  Future<void> refreshTodayData() async {
    await loadTodayData();
  }

  /// Agrega un nuevo registro y actualiza el estado
  Future<void> addRecord(LactationRecord record) async {
    try {
      await _lactationService.saveRecord(record);
      // Recargar datos después de agregar
      await loadTodayData();
    } catch (e) {
      _errorMessage = 'Error guardando registro: $e';
      notifyListeners();
    }
  }

  /// Actualiza un registro existente
  Future<void> updateRecord(String recordId, LactationRecord record) async {
    try {
      await _lactationService.updateRecord(recordId, record);
      // Recargar datos después de actualizar
      await loadTodayData();
    } catch (e) {
      _errorMessage = 'Error actualizando registro: $e';
      notifyListeners();
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String recordId) async {
    try {
      await _lactationService.deleteRecord(recordId);
      // Recargar datos después de eliminar
      await loadTodayData();
    } catch (e) {
      _errorMessage = 'Error eliminando registro: $e';
      notifyListeners();
    }
  }

  /// Calcula las estadísticas del día
  LactationStats _calculateTodayStats(List<LactationRecord> records) {
    final totalDuration = records.fold<Duration>(
      Duration.zero,
      (total, record) => total + record.duracion,
    );

    final averageDuration = records.isNotEmpty
        ? Duration(minutes: totalDuration.inMinutes ~/ records.length)
        : Duration.zero;

    return LactationStats(
      totalFeeds: records.length,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      feedsToday: records.length,
      durationToday: totalDuration,
    );
  }

  /// Obtiene el tiempo hasta la próxima toma
  String getNextFeedTime() {
    if (_todayRecords.isEmpty) {
      return 'Ahora';
    }

    final lastFeed = _todayRecords.last;
    final now = DateTime.now();
    final suggestedInterval = const Duration(hours: 2, minutes: 30);
    final nextFeedTime = lastFeed.fechaRegistro.add(suggestedInterval);

    if (now.isAfter(nextFeedTime)) {
      return 'Ahora';
    }

    final timeUntilNext = nextFeedTime.difference(now);
    final hours = timeUntilNext.inHours;
    final minutes = timeUntilNext.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Obtiene el estado del progreso
  String getFeedStatus() {
    if (_todayStats == null) return 'Inicia tu registro';

    final feeds = _todayStats!.feedsToday;
    if (feeds == 0) {
      return 'Inicia tu registro';
    } else if (feeds < 6) {
      return 'Buen progreso';
    } else {
      return '¡Excelente ritmo!';
    }
  }

  /// Obtiene la información de duración
  String getDurationInfo() {
    if (_todayStats == null) return '0m hoy';

    final duration = _todayStats!.durationToday;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m hoy';
    } else {
      return '${duration.inMinutes}m hoy';
    }
  }

  /// Formatea el tiempo desde la última toma
  String formatLastFeedTime(DateTime lastFeed) {
    final now = DateTime.now();
    final difference = now.difference(lastFeed);

    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  /// Limpia el estado
  void clearState() {
    _todayRecords.clear();
    _todayStats = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }
}
