import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/export.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import '../di/injection.dart';
import 'secure_storage_service.dart';

/// Servicio para cifrar datos sensibles en SharedPreferences
/// Usa AES-GCM para cifrar valores antes de guardarlos
@singleton
class EncryptedPreferencesService {
  final AppLogger _logger = getIt<AppLogger>();
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  static const String _encryptionKeyKey = 'encrypted_prefs_key';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12; // 96 bits para GCM

  Uint8List? _encryptionKey;

  /// Inicializa la clave de cifrado (se guarda en SecureStorage)
  Future<void> _ensureInitialized() async {
    if (_encryptionKey != null) return;

    try {
      // Intentar cargar la clave desde SecureStorage
      final keyString = await _secureStorage.read(_encryptionKeyKey);

      if (keyString != null) {
        // Decodificar la clave desde base64
        _encryptionKey = base64Decode(keyString);
        if (_encryptionKey!.length != _keyLength) {
          throw Exception('Clave de cifrado inválida');
        }
      } else {
        // Generar nueva clave
        final random = Random.secure();
        _encryptionKey = Uint8List(_keyLength);
        for (int i = 0; i < _keyLength; i++) {
          _encryptionKey![i] = random.nextInt(256);
        }

        // Guardar en SecureStorage
        await _secureStorage.write(
          _encryptionKeyKey,
          base64Encode(_encryptionKey!),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error inicializando EncryptedPreferencesService',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Cifra un valor
  Future<String> _encrypt(String plaintext) async {
    await _ensureInitialized();

    try {
      // Generar IV único
      final random = Random.secure();
      final iv = Uint8List(_ivLength);
      for (int i = 0; i < _ivLength; i++) {
        iv[i] = random.nextInt(256);
      }

      // Configurar AES-GCM
      final key = KeyParameter(_encryptionKey!);
      final params = AEADParameters(
        key,
        128, // Tag length en bits
        iv,
        Uint8List(0), // Sin AAD
      );
      final cipher = GCMBlockCipher(AESEngine())..init(true, params);

      // Cifrar
      final plaintextBytes = utf8.encode(plaintext);
      final ciphertext = cipher.process(plaintextBytes);
      final tag = cipher.mac;

      // Formato: base64(IV + Tag + Ciphertext)
      final combined = Uint8List(_ivLength + 16 + ciphertext.length);
      combined.setRange(0, _ivLength, iv);
      combined.setRange(_ivLength, _ivLength + 16, tag);
      combined.setRange(_ivLength + 16, combined.length, ciphertext);

      return base64Encode(combined);
    } catch (e, stackTrace) {
      _logger.e('Error cifrando valor', e, stackTrace);
      rethrow;
    }
  }

  /// Descifra un valor
  Future<String?> _decrypt(String encryptedValue) async {
    await _ensureInitialized();

    try {
      // Decodificar desde base64
      final combined = base64Decode(encryptedValue);

      if (combined.length < _ivLength + 16) {
        throw Exception('Valor cifrado inválido: demasiado corto');
      }

      // Extraer IV, Tag y Ciphertext
      final iv = combined.sublist(0, _ivLength);
      final tag = combined.sublist(_ivLength, _ivLength + 16);
      final ciphertext = combined.sublist(_ivLength + 16);

      // Configurar AES-GCM para descifrar
      final key = KeyParameter(_encryptionKey!);
      final params = AEADParameters(
        key,
        128, // Tag length en bits
        iv,
        Uint8List(0), // Sin AAD
      );
      final cipher = GCMBlockCipher(AESEngine())..init(false, params);

      // Descifrar
      final plaintext = cipher.process(ciphertext);
      final computedTag = cipher.mac;

      // Verificar tag
      if (!_constantTimeEquals(computedTag, tag)) {
        throw Exception('Error de autenticación: tag no coincide');
      }

      return utf8.decode(plaintext);
    } catch (e, stackTrace) {
      _logger.e('Error descifrando valor', e, stackTrace);
      return null;
    }
  }

  /// Comparación de tiempo constante
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Guarda un string cifrado
  Future<bool> setEncryptedString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = await _encrypt(value);
      return await prefs.setString('_enc_$key', encrypted);
    } catch (e, stackTrace) {
      _logger.e('Error guardando string cifrado', e, stackTrace);
      return false;
    }
  }

  /// Lee un string cifrado
  Future<String?> getEncryptedString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString('_enc_$key');
      if (encrypted == null) return null;
      return await _decrypt(encrypted);
    } catch (e, stackTrace) {
      _logger.e('Error leyendo string cifrado', e, stackTrace);
      return null;
    }
  }

  /// Elimina un valor cifrado
  Future<bool> removeEncryptedString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('_enc_$key');
    } catch (e, stackTrace) {
      _logger.e('Error eliminando string cifrado', e, stackTrace);
      return false;
    }
  }
}
