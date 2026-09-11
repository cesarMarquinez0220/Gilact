/// Excepción que se lanza cuando no se encuentra un recurso
class NotFoundException implements Exception {
  final String message;
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required this.message,
    this.resourceType,
    this.resourceId,
  });

  @override
  String toString() {
    if (resourceType != null && resourceId != null) {
      return 'NotFoundException: $message (Resource: $resourceType, ID: $resourceId)';
    } else if (resourceType != null) {
      return 'NotFoundException: $message (Resource: $resourceType)';
    }
    return 'NotFoundException: $message';
  }
}

/// Excepción que se lanza cuando hay un error en el servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException: $message (Status: $statusCode)';
    }
    return 'ServerException: $message';
  }
}

/// Excepción que se lanza cuando hay un error de red
class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción que se lanza cuando hay un error de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() {
    if (code != null) {
      return 'AuthException: $message (Code: $code)';
    }
    return 'AuthException: $message';
  }
}

/// Excepción que se lanza cuando hay un error en el caché
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}
