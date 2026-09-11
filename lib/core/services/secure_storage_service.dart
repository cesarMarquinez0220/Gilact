import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import '../di/injection.dart';

/// Servicio para almacenamiento seguro usando Android Keystore / iOS Keychain
/// Proporciona protección adicional con hardware para datos sensibles
@singleton
class SecureStorageService {
  final AppLogger _logger = getIt<AppLogger>();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Usar Android Keystore para mayor seguridad
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Guarda un valor de forma segura
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      if (kDebugMode) {
        _logger.d('SecureStorage: Valor guardado para clave: $key');
      }
    } catch (e, stackTrace) {
      _logger.e('SecureStorage: Error guardando valor', e, stackTrace);
      rethrow;
    }
  }

  /// Lee un valor de forma segura
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (kDebugMode && value != null) {
        _logger.d('SecureStorage: Valor leído para clave: $key');
      }
      return value;
    } catch (e, stackTrace) {
      _logger.e('SecureStorage: Error leyendo valor', e, stackTrace);
      return null;
    }
  }

  /// Elimina un valor
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      if (kDebugMode) {
        _logger.d('SecureStorage: Valor eliminado para clave: $key');
      }
    } catch (e, stackTrace) {
      _logger.e('SecureStorage: Error eliminando valor', e, stackTrace);
    }
  }

  /// Elimina todos los valores
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        _logger.d('SecureStorage: Todos los valores eliminados');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'SecureStorage: Error eliminando todos los valores',
        e,
        stackTrace,
      );
    }
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }
}
