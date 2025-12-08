import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Servicio centralizado de logging para la aplicación
/// Reemplaza todos los print() con un sistema robusto de logging
/// Sanitiza automáticamente información sensible antes de loguear
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

  /// Patrones de información sensible que deben ser sanitizados
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'password["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'key["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'secret["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'token["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'api[_-]?key["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'credential["\s:=]+([^",\s}]+)', caseSensitive: false),
    RegExp(r'auth[_-]?token["\s:=]+([^",\s}]+)', caseSensitive: false),
  ];

  /// Sanitiza un mensaje removiendo información sensible
  String _sanitize(String message) {
    String sanitized = message;

    // Sanitizar patrones de información sensible
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAllMapped(pattern, (match) {
        final prefix = match.group(0)?.split(RegExp(r'[=:]'))[0] ?? '';
        return '$prefix=***REDACTED***';
      });
    }

    // En release, también sanitizar hashes largos que podrían ser tokens
    if (kReleaseMode) {
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'\b[0-9a-f]{32,}\b', caseSensitive: false),
        (match) => '***HASH_REDACTED***',
      );
    }

    return sanitized;
  }

  /// Verifica si el llamador viene de la carpeta core
  // bool _isFromCoreFolder() {
  //   try {
  //     final stackTrace = StackTrace.current;
  //     final stackString = stackTrace.toString();
  //     return stackString.contains('/core/') ||
  //         stackString.contains('\\core\\') ||
  //         stackString.contains('package:gilact/core/');
  //   } catch (_) {
  //     return false;
  //   }
  // }

  /// Log de debug (solo en modo debug)
  /// Sanitiza automáticamente información sensible
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final sanitizedMessage = message is String ? _sanitize(message) : message;
      final sanitizedError = error is String ? _sanitize(error) : error;
      _logger.d(
        sanitizedMessage,
        error: sanitizedError,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log de información
  /// Sanitiza automáticamente información sensible
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    final sanitizedError = error is String ? _sanitize(error) : error;
    _logger.i(sanitizedMessage, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log de advertencia
  /// Sanitiza automáticamente información sensible
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    final sanitizedError = error is String ? _sanitize(error) : error;
    _logger.w(sanitizedMessage, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log de error
  /// Sanitiza automáticamente información sensible
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    final sanitizedError = error is String ? _sanitize(error) : error;
    _logger.e(sanitizedMessage, error: sanitizedError, stackTrace: stackTrace);
  }

  /// Log fatal (errores críticos)
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log de éxito (para acciones exitosas)
  /// Sanitiza automáticamente información sensible
  void success(dynamic message) {
    if (kDebugMode) {
      final sanitizedMessage = message is String ? _sanitize(message) : message;
      _logger.t('✅ $sanitizedMessage');
    }
  }

  /// Log de error con formato especial para servicios
  /// Sanitiza automáticamente información sensible
  void serviceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    final sanitizedError = error is String
        ? _sanitize(error.toString())
        : error;
    _logger.e(
      '⚠️ [$serviceName] Error en $operation',
      error: sanitizedError,
      stackTrace: stackTrace,
    );
  }

  /// Log de operación exitosa en servicios
  /// Omite logs que vengan de la carpeta core para reducir ruido
  void serviceSuccess(String serviceName, String operation) {
    // if (kDebugMode && !_isFromCoreFolder()) {
    if (kDebugMode) {
      _logger.d('✅ [$serviceName] $operation completado exitosamente');
    }
  }
}
