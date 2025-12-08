import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import '../di/injection.dart';

/// Wrapper para AppLogger que sanitiza información sensible antes de loguear
/// Previene que contraseñas, claves, tokens, etc. se expongan en logs
class SanitizedLogger {
  final AppLogger _logger = getIt<AppLogger>();

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
    if (!kDebugMode) {
      // En release, ser más agresivo con la sanitización
      return _sanitizeAggressive(message);
    }
    return _sanitizeBasic(message);
  }

  /// Sanitización básica (modo debug)
  String _sanitizeBasic(String message) {
    String sanitized = message;
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '${match.group(0)?.split('=')[0]}=***REDACTED***',
      );
    }
    return sanitized;
  }

  /// Sanitización agresiva (modo release)
  String _sanitizeAggressive(String message) {
    String sanitized = message;
    // Remover cualquier valor que parezca sensible
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '${match.group(0)?.split('=')[0]}=***REDACTED***',
      );
    }
    // Remover valores que parezcan hashes largos o tokens
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[0-9a-f]{32,}\b', caseSensitive: false),
      (match) => '***HASH_REDACTED***',
    );
    return sanitized;
  }

  /// Log de debug sanitizado
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    _logger.d(sanitizedMessage, error, stackTrace);
  }

  /// Log de información sanitizado
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    _logger.i(sanitizedMessage, error, stackTrace);
  }

  /// Log de advertencia sanitizado
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    _logger.w(sanitizedMessage, error, stackTrace);
  }

  /// Log de error sanitizado
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    _logger.e(sanitizedMessage, error, stackTrace);
  }

  /// Log de éxito sanitizado
  void success(dynamic message) {
    final sanitizedMessage = message is String ? _sanitize(message) : message;
    _logger.success(sanitizedMessage);
  }

  /// Log de error de servicio sanitizado
  void serviceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    final sanitizedError = error is String ? _sanitize(error) : error;
    _logger.serviceError(serviceName, operation, sanitizedError, stackTrace);
  }

  /// Log de éxito de servicio sanitizado
  void serviceSuccess(String serviceName, String operation) {
    _logger.serviceSuccess(serviceName, operation);
  }
}
