import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Servicio centralizado de logging para la aplicación
/// Reemplaza todos los print() con un sistema robusto de logging
@singleton
class AppLogger {
  late final Logger _logger;

  AppLogger(SharedPreferences prefs) {
    _initializeLogger();
  }

  void _initializeLogger() {
    // En modo release, solo mostrar errores y warnings
    // En modo debug, mostrar todo
    const level = kReleaseMode ? Level.warning : Level.debug;

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: kDebugMode ? 2 : 0, // Mostrar stack trace solo en debug
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: level,
    );
  }

  /// Verifica si el llamador viene de la carpeta core
  bool _isFromCoreFolder() {
    try {
      final stackTrace = StackTrace.current;
      final stackString = stackTrace.toString();
      return stackString.contains('/core/') || 
             stackString.contains('\\core\\') ||
             stackString.contains('package:gilact/core/');
    } catch (_) {
      return false;
    }
  }

  /// Log de debug (solo en modo debug)
  /// Omite logs que vengan de la carpeta core para reducir ruido
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode && !_isFromCoreFolder()) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de información
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de advertencia
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal (errores críticos)
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log de éxito (para acciones exitosas)
  /// Omite logs que vengan de la carpeta core para reducir ruido
  void success(dynamic message) {
    if (kDebugMode && !_isFromCoreFolder()) {
      _logger.t('✅ $message');
    }
  }

  /// Log de error con formato especial para servicios
  void serviceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _logger.e(
      '⚠️ [$serviceName] Error en $operation',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de operación exitosa en servicios
  /// Omite logs que vengan de la carpeta core para reducir ruido
  void serviceSuccess(String serviceName, String operation) {
    if (kDebugMode && !_isFromCoreFolder()) {
      _logger.d('✅ [$serviceName] $operation completado exitosamente');
    }
  }
}
