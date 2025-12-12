import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/di/injection.dart';

/// Servicio para encriptar y desencriptar videos usando AES-256-GCM
/// GCM (Galois/Counter Mode) es el estándar seguro actual, reemplazando CBC/PKCS5
/// Usa SecureStorage (Android Keystore/iOS Keychain) para almacenar la clave
class VideoEncryptionService {
  static const String _keyStorageKey = 'video_encryption_key';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12; // 96 bits para GCM (recomendado)
  static const int _tagLength = 16; // 128 bits para el tag de autenticación

  Uint8List? _encryptionKey;
  bool _isInitialized = false;
  final AppLogger _logger = getIt<AppLogger>();
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();

  VideoEncryptionService() {
    // La inicialización se hará de forma lazy cuando se necesite
  }

  /// Inicializa la encriptación con una clave única por dispositivo
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _initializeEncryption();
    _isInitialized = true;
  }

  Future<void> _initializeEncryption() async {
    try {
      // Intentar cargar clave desde SecureStorage (Android Keystore/iOS Keychain)
      final keyString = await _secureStorage.read(_keyStorageKey);

      if (keyString != null) {
        // Decodificar la clave desde base64
        final keyBytes = base64Decode(keyString);
        if (keyBytes.length != _keyLength) {
          throw Exception(
            'Clave de encriptación inválida: longitud incorrecta',
          );
        }
        _encryptionKey = keyBytes;
      } else {
        // Generar nueva clave única usando Random.secure()
        final random = Random.secure();
        final keyBytes = Uint8List(_keyLength);
        for (int i = 0; i < _keyLength; i++) {
          keyBytes[i] = random.nextInt(256);
        }
        _encryptionKey = keyBytes;

        // Guardar clave en SecureStorage (protegida por hardware)
        await _secureStorage.write(
          _keyStorageKey,
          base64Encode(_encryptionKey!),
        );
      }

      if (kDebugMode) {
        _logger.success(
          'Encriptación AES-GCM inicializada correctamente (clave en SecureStorage)',
        );
      }
    } catch (e) {
      throw Exception('Error inicializando encriptación: $e');
    }
  }

  /// Genera un IV único para cada archivo (mejor práctica de seguridad)
  Uint8List _generateIV() {
    final random = Random.secure();
    final iv = Uint8List(_ivLength);
    for (int i = 0; i < _ivLength; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// Encripta un archivo de video usando AES-256-GCM
  /// Retorna la ruta del archivo encriptado
  /// Formato del archivo encriptado: [IV (12 bytes)][Tag (16 bytes)][Ciphertext]
  Future<String> encryptVideoFile(String videoFilePath) async {
    await _ensureInitialized();
    try {
      final videoFile = File(videoFilePath);
      if (!await videoFile.exists()) {
        throw Exception('El archivo de video no existe: $videoFilePath');
      }

      // Generar IV único para este archivo
      final iv = _generateIV();

      // Configurar AES-GCM
      final key = KeyParameter(_encryptionKey!);
      final params = AEADParameters(
        key,
        _tagLength * 8,
        iv,
        Uint8List(0),
      ); // Sin AAD
      final cipher = GCMBlockCipher(AESEngine())..init(true, params);

      // Leer el archivo completo
      final videoBytes = await videoFile.readAsBytes();

      // Encriptar
      final encryptedBytes = cipher.process(videoBytes);

      // Obtener el tag de autenticación
      final tag = cipher.mac;

      if (tag.length != _tagLength) {
        // Limpiar memoria antes de lanzar excepción
        _clearMemory(videoBytes);
        _clearMemory(encryptedBytes);
        throw Exception('Error generando tag de autenticación GCM');
      }

      // Escribir archivo encriptado: IV + Tag + Ciphertext
      final encryptedFilePath = '$videoFilePath.encrypted';
      final encryptedFile = File(encryptedFilePath);
      final outputStream = encryptedFile.openWrite();

      outputStream.add(iv); // 12 bytes
      outputStream.add(tag); // 16 bytes
      outputStream.add(encryptedBytes);

      await outputStream.close();

      // Limpiar buffers de memoria después de usar
      _clearMemory(videoBytes);
      _clearMemory(encryptedBytes);

      // Eliminar archivo original
      await videoFile.delete();

      if (kDebugMode) {
        _logger.success('Video encriptado exitosamente con AES-GCM');
      }

      return encryptedFilePath;
    } catch (e, stackTrace) {
      _logger.e('Error encriptando video', e, stackTrace);
      throw Exception('Error encriptando video: $e');
    }
  }

  /// Desencripta un archivo de video en chunks usando AES-256-GCM
  /// Retorna un stream de bytes desencriptados
  Stream<Uint8List> decryptVideoFileStream(String encryptedFilePath) async* {
    await _ensureInitialized();
    try {
      final encryptedFile = File(encryptedFilePath);
      if (!await encryptedFile.exists()) {
        throw Exception('El archivo encriptado no existe: $encryptedFilePath');
      }

      // Leer el archivo completo
      final encryptedBytes = await encryptedFile.readAsBytes();

      if (encryptedBytes.length < _ivLength + _tagLength) {
        throw Exception('Archivo encriptado inválido: demasiado corto');
      }

      // Extraer IV, Tag y Ciphertext
      final iv = encryptedBytes.sublist(0, _ivLength);
      final tag = encryptedBytes.sublist(_ivLength, _ivLength + _tagLength);
      final ciphertext = encryptedBytes.sublist(_ivLength + _tagLength);

      // Configurar AES-GCM para desencriptar
      final key = KeyParameter(_encryptionKey!);
      final params = AEADParameters(
        key,
        _tagLength * 8,
        iv,
        Uint8List(0),
      ); // Sin AAD
      final cipher = GCMBlockCipher(AESEngine())..init(false, params);

      // Desencriptar
      final decryptedBytes = cipher.process(ciphertext);

      // Verificar el tag de autenticación
      final computedTag = cipher.mac;
      if (!_constantTimeEquals(computedTag, tag)) {
        // Limpiar memoria antes de lanzar excepción
        _clearMemory(decryptedBytes);
        _clearMemory(ciphertext);
        throw Exception(
          'Error de autenticación: el tag no coincide. Posible corrupción o manipulación.',
        );
      }

      // Dividir en chunks para el stream (para no cargar todo en memoria de una vez)
      const chunkSize = 64 * 1024; // 64KB chunks
      for (int i = 0; i < decryptedBytes.length; i += chunkSize) {
        final end = (i + chunkSize < decryptedBytes.length)
            ? i + chunkSize
            : decryptedBytes.length;
        final chunk = decryptedBytes.sublist(i, end);
        yield chunk;
        // Nota: No limpiamos el chunk aquí porque se está usando en el stream
        // La limpieza se hará cuando el stream termine
      }

      // Limpiar buffers después de procesar
      _clearMemory(decryptedBytes);
      _clearMemory(ciphertext);

      if (kDebugMode) {
        _logger.success('Video desencriptado exitosamente con AES-GCM');
      }
    } catch (e, stackTrace) {
      _logger.e('Error desencriptando video', e, stackTrace);
      throw Exception('Error desencriptando video: $e');
    }
  }

  /// Comparación de tiempo constante para prevenir timing attacks
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Limpia un buffer de memoria sobrescribiéndolo con ceros
  /// Esto previene que datos sensibles queden en memoria
  void _clearMemory(Uint8List buffer) {
    if (buffer.isEmpty) return;
    // Sobrescribir con datos aleatorios (más seguro que ceros)
    final random = Random.secure();
    for (int i = 0; i < buffer.length; i++) {
      buffer[i] = random.nextInt(256);
    }
    // Finalmente, llenar con ceros
    buffer.fillRange(0, buffer.length, 0);
  }

  /// Desencripta un archivo completo (para casos especiales)
  Future<String> decryptVideoFile(String encryptedFilePath) async {
    try {
      final decryptedFilePath = encryptedFilePath.replaceAll('.encrypted', '');
      final decryptedFile = File(decryptedFilePath);
      final outputStream = decryptedFile.openWrite();

      await for (final chunk in decryptVideoFileStream(encryptedFilePath)) {
        outputStream.add(chunk);
      }

      await outputStream.close();
      return decryptedFilePath;
    } catch (e) {
      throw Exception('Error desencriptando archivo completo: $e');
    }
  }

  /// Obtiene el tamaño del archivo encriptado
  Future<int> getEncryptedFileSize(String encryptedFilePath) async {
    final file = File(encryptedFilePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
