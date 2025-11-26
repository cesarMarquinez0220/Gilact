import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/lactation_service.dart';
import '../../data/services/lactation_notification_service.dart';
import '../../domain/entities/lactation_record.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Provider para manejar el estado de lactancia de manera reactiva
class LactationProvider extends ChangeNotifier {
  final LactationService _lactationService;
  final AppLogger _logger = getIt<AppLogger>();
  Timer? _timer;

  LactationProvider(this._lactationService) {
    // Iniciar el temporizador automático
    _startAutoRefreshTimer();
  }

  // Estado de lactancia
  List<LactationRecord> _todayRecords = [];
  List<LactationRecord> _weekRecords = [];
  LactationStats? _todayStats;
  bool _isLoading = true;
  String? _errorMessage;

  // Cache para intervalo dinámico basado en edad del bebé
  Duration? _cachedLactationInterval;
  DateTime? _lastIntervalUpdate;

  // Getters
  List<LactationRecord> get todayRecords => _todayRecords;
  List<LactationRecord> get weekRecords => _weekRecords;
  LactationStats? get todayStats => _todayStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los datos del día actual
  Future<void> loadTodayData() async {
    try {
      _logger.d('loadTodayData: Iniciando carga...');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final today = DateTime.now();
      final records = await _lactationService.getRecordsForDate(today);

      _logger.d('loadTodayData: Registros encontrados: ${records.length}');
      for (final record in records) {
        _logger.d('   - ${record.fechaRegistro}');
      }

      _todayRecords = records;
      _todayStats = _calculateTodayStats(records);

      // Actualizar intervalo dinámico basado en edad del bebé
      await _updateLactationInterval();

      _isLoading = false;
      notifyListeners();
      _logger.d('loadTodayData: Datos cargados y notificados');
    } catch (e, stackTrace) {
      _errorMessage = 'Error cargando datos: $e';
      _isLoading = false;
      notifyListeners();
      _logger.e('loadTodayData: Error', e, stackTrace);
    }
  }

  /// Actualiza el intervalo de lactancia basado en la edad del bebé
  Future<void> _updateLactationInterval() async {
    try {
      // Actualizar cada 5 minutos máximo para evitar consultas excesivas
      if (_lastIntervalUpdate != null &&
          DateTime.now().difference(_lastIntervalUpdate!) <
              const Duration(minutes: 5)) {
        return;
      }

      final birthDate = await _lactationService.getBabyBirthDate();
      if (birthDate != null) {
        _cachedLactationInterval =
            LactationNotificationService.calculateLactationInterval(birthDate);
        _lastIntervalUpdate = DateTime.now();
        _logger.d(
          'LactationProvider: Intervalo dinámico actualizado: ${_cachedLactationInterval!.inHours}h ${_cachedLactationInterval!.inMinutes.remainder(60)}m',
        );
      } else {
        // Usar intervalo por defecto si no se puede obtener la fecha
        _cachedLactationInterval = const Duration(hours: 2, minutes: 30);
        _logger.d(
          'LactationProvider: Usando intervalo por defecto (no se pudo obtener fecha de nacimiento)',
        );
      }
    } catch (e, stackTrace) {
      _logger.w(
        'LactationProvider: Error actualizando intervalo',
        e,
        stackTrace,
      );
      // Usar intervalo por defecto en caso de error
      _cachedLactationInterval = const Duration(hours: 2, minutes: 30);
    }
  }

  /// Refresca los datos del día actual
  Future<void> refreshTodayData() async {
    await loadTodayData();
  }

  /// Carga los registros de la semana actual
  Future<void> loadWeekData() async {
    try {
      final now = DateTime.now();
      final todayWeekday = now.weekday; // Lunes=1, Domingo=7

      // Calcular el inicio de la semana (Domingo)
      // Si hoy es domingo (7), no restar nada
      // Si hoy es lunes (1), restar 1 día
      // Si hoy es martes (2), restar 2 días
      // etc.
      final daysToSubtract =
          todayWeekday % 7; // 0 para domingo, 1-6 para otros días
      final startOfWeek = now.subtract(Duration(days: daysToSubtract));

      // Normalizar a medianoche del domingo
      final startOfWeekMidnight = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      _logger.d(
        'Cargando datos de la semana desde: $startOfWeekMidnight (weekday: ${startOfWeekMidnight.weekday})',
      );

      final records = await _lactationService.getRecordsForWeek(
        startOfWeekMidnight,
      );
      _weekRecords = records;

      _logger.d('Registros cargados: ${records.length}');
      for (final record in records) {
        _logger.d('  - ${record.fechaRegistro}');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error cargando datos de la semana', e, stackTrace);
    }
  }

  /// Verifica si un día específico tiene registros
  bool hasRecordsForDate(DateTime date) {
    // Normalizar la fecha a medianoche para comparación precisa
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Buscar registros para esta fecha
    final matchingRecords = _weekRecords.where((record) {
      // Normalizar también la fecha del registro
      final recordDate = DateTime(
        record.fechaRegistro.year,
        record.fechaRegistro.month,
        record.fechaRegistro.day,
      );

      return recordDate.isAtSameMomentAs(normalizedDate);
    }).toList();

    // Debug: mostrar info para domingo (día 0 del índice del calendario)
    if (date.weekday == 7) {
      // Domingo
      _logger.d(
        'Domingo ${date.day}/${date.month}: ${matchingRecords.length} registros',
      );
      for (final record in matchingRecords) {
        _logger.d('   - Registro: ${record.fechaRegistro}');
      }
    }

    return matchingRecords.isNotEmpty;
  }

  /// Agrega un nuevo registro y actualiza el estado
  Future<void> addRecord(LactationRecord record) async {
    try {
      _logger.d(
        'addRecord: Guardando registro... Fecha: ${record.fechaRegistro}',
      );
      await _lactationService.saveRecord(record);
      _logger.success('addRecord: Registro guardado exitosamente');
      // Recargar datos después de agregar
      await loadTodayData();
      _logger.d('addRecord: Datos recargados');
    } catch (e, stackTrace) {
      _errorMessage = 'Error guardando registro: $e';
      notifyListeners();
      _logger.e('addRecord: Error guardando', e, stackTrace);
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
  /// Calcula el intervalo dinámico basado en la edad del bebé
  String getNextFeedTime() {
    _logger.d(
      'getNextFeedTime: _todayRecords.length = ${_todayRecords.length}',
    );

    if (_todayRecords.isEmpty) {
      _logger.d('getNextFeedTime: No hay registros hoy - retornando "Ahora"');
      return 'Ahora';
    }

    // Los registros vienen ordenados por fecha descendente (más reciente primero)
    // Por lo tanto, el PRIMER elemento es el más reciente
    final lastFeed = _todayRecords.first;
    final now = DateTime.now();

    // Usar intervalo dinámico cacheado, o por defecto si no está disponible
    final suggestedInterval =
        _cachedLactationInterval ?? const Duration(hours: 2, minutes: 30);
    final nextFeedTime = lastFeed.fechaRegistro.add(suggestedInterval);

    _logger.d(
      'Toma más reciente: ${lastFeed.fechaRegistro}, Intervalo: ${suggestedInterval.inHours}h ${suggestedInterval.inMinutes.remainder(60)}m, Hora actual: $now, Próxima toma: $nextFeedTime, ¿Ya pasó?: ${now.isAfter(nextFeedTime)}',
    );

    if (now.isAfter(nextFeedTime)) {
      _logger.d('Ya pasó el tiempo - retornando "Ahora"');
      return 'Ahora';
    }

    final timeUntilNext = nextFeedTime.difference(now);
    final hours = timeUntilNext.inHours;
    final minutes = timeUntilNext.inMinutes.remainder(60);

    _logger.d('Tiempo restante: ${hours}h ${minutes}m');

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
    _weekRecords.clear();
    _todayStats = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Inicia el timer automático que actualiza el temporizador cada minuto
  void _startAutoRefreshTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _logger.d('Timer: Actualizando temporizador...');
      // Notificar a los listeners para que el widget se reconstruya
      // y el temporizador se actualice automáticamente
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Cancelar el timer antes de eliminar el provider
    _timer?.cancel();
    // Limpiar el estado antes de eliminar el provider
    clearState();
    super.dispose();
  }
}
