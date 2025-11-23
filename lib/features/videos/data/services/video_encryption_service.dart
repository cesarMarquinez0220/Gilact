import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart' hide Key;
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para encriptar y desencriptar videos usando AES-256
class VideoEncryptionService {
  static const String _keyFileName = 'video_encryption_key.dat';
  Key? _encryptionKey;
  IV? _initializationVector;
  Encrypter? _encrypter;
  bool _isInitialized = false;

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
      final keyFile = await _getKeyFile();

      if (await keyFile.exists()) {
        // Cargar clave existente
        final keyBytes = await keyFile.readAsBytes();
        _encryptionKey = Key(keyBytes);
      } else {
        // Generar nueva clave única
        final random = Random.secure();
        final keyBytes = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          keyBytes[i] = random.nextInt(256);
        }
        _encryptionKey = Key(keyBytes);
        // Guardar clave para uso futuro
        await keyFile.writeAsBytes(_encryptionKey!.bytes);
      }

      // IV fijo basado en un hash de la clave (mejor práctica: usar IV único por archivo)
      final ivBytes = sha256
          .convert(_encryptionKey!.bytes)
          .bytes
          .take(16)
          .toList();
      _initializationVector = IV(Uint8List.fromList(ivBytes));

      _encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));
    } catch (e) {
      throw Exception('Error inicializando encriptación: $e');
    }
  }

  /// Obtiene el archivo de clave
  Future<File> _getKeyFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final keyPath = '${directory.path}/$_keyFileName';
    return File(keyPath);
  }

  /// Encripta un archivo de video
  /// Retorna la ruta del archivo encriptado
  /// Usa un enfoque simple: encripta el archivo completo como un stream continuo
  Future<String> encryptVideoFile(String videoFilePath) async {
    await _ensureInitialized();
    try {
      final videoFile = File(videoFilePath);
      if (!await videoFile.exists()) {
        throw Exception('El archivo de video no existe: $videoFilePath');
      }

      // Leer todo el archivo en memoria (para videos pequeños) o usar streaming
      // Para videos grandes, usamos un buffer grande para reducir llamadas
      final encryptedFilePath = '$videoFilePath.encrypted';
      final encryptedFile = File(encryptedFilePath);
      final outputStream = encryptedFile.openWrite();

      // Leer el archivo completo y encriptarlo de una vez
      // Esto asegura que el padding se maneje correctamente
      final videoBytes = await videoFile.readAsBytes();

      // Encriptar todo el archivo de una vez con el IV inicial
      // El padding se manejará automáticamente
      final encrypted = _encrypter!.encryptBytes(
        videoBytes,
        iv: _initializationVector!,
      );

      outputStream.add(encrypted.bytes);
      await outputStream.close();

      // Eliminar archivo original
      await videoFile.delete();

      return encryptedFilePath;
    } catch (e) {
      throw Exception('Error encriptando video: $e');
    }
  }

  /// Desencripta un archivo de video en chunks
  /// Retorna un stream de bytes desencriptados
  /// Soporta tanto el método antiguo (chunks arbitrarios) como el nuevo (archivo completo)
  Stream<Uint8List> decryptVideoFileStream(String encryptedFilePath) async* {
    await _ensureInitialized();
    try {
      final encryptedFile = File(encryptedFilePath);
      if (!await encryptedFile.exists()) {
        throw Exception('El archivo encriptado no existe: $encryptedFilePath');
      }

      // Intentar desencriptar como archivo completo primero (método nuevo)
      try {
        final encryptedBytes = await encryptedFile.readAsBytes();
        final decrypted = _encrypter!.decryptBytes(
          Encrypted(encryptedBytes),
          iv: _initializationVector!,
        );

        final decryptedBytes = decrypted is Uint8List
            ? decrypted
            : Uint8List.fromList(decrypted);

        // Dividir en chunks para el stream (para no cargar todo en memoria de una vez)
        const chunkSize = 64 * 1024; // 64KB chunks
        for (int i = 0; i < decryptedBytes.length; i += chunkSize) {
          final end = (i + chunkSize < decryptedBytes.length)
              ? i + chunkSize
              : decryptedBytes.length;
          yield decryptedBytes.sublist(i, end);
        }

        if (kDebugMode) {
          print('✅ Video desencriptado exitosamente (método completo)');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Método completo falló, intentando método por chunks: $e');
        }
        // Si falla, intentar el método antiguo (por chunks con IVs encadenados)
      }

      // Método antiguo: procesar por chunks con IVs encadenados
      // Necesitamos procesar en bloques de 16 bytes para que funcione correctamente
      final buffer = <int>[];
      bool isFirstBlock = true;
      Uint8List? lastEncryptedBlock;
      const blockSize = 16;

      await for (final chunk in encryptedFile.openRead()) {
        // Agregar chunk al buffer
        buffer.addAll(chunk);

        // Procesar bloques completos de 16 bytes
        while (buffer.length >= blockSize) {
          // Extraer un bloque completo
          final blockBytes = Uint8List.fromList(buffer.sublist(0, blockSize));
          buffer.removeRange(0, blockSize);

          Uint8List decryptedBlock;

          if (isFirstBlock) {
            // Primer bloque: usar IV inicial
            final decrypted = _encrypter!.decryptBytes(
              Encrypted(blockBytes),
              iv: _initializationVector!,
            );
            decryptedBlock = decrypted is Uint8List
                ? decrypted
                : Uint8List.fromList(decrypted);
            isFirstBlock = false;
            // Guardar este bloque encriptado para usar como IV del siguiente
            lastEncryptedBlock = Uint8List.fromList(blockBytes);
          } else {
            // Bloques siguientes: usar el bloque encriptado anterior como IV
            if (lastEncryptedBlock != null) {
              final decrypted = _encrypter!.decryptBytes(
                Encrypted(blockBytes),
                iv: IV(lastEncryptedBlock),
              );
              decryptedBlock = decrypted is Uint8List
                  ? decrypted
                  : Uint8List.fromList(decrypted);
              // Actualizar el último bloque encriptado para el siguiente
              lastEncryptedBlock = Uint8List.fromList(blockBytes);
            } else {
              // Fallback: usar el IV original (no debería ocurrir)
              final decrypted = _encrypter!.decryptBytes(
                Encrypted(blockBytes),
                iv: _initializationVector!,
              );
              decryptedBlock = decrypted is Uint8List
                  ? decrypted
                  : Uint8List.fromList(decrypted);
              lastEncryptedBlock = Uint8List.fromList(blockBytes);
            }
          }

          yield decryptedBlock;
        }
      }

      // Procesar el último bloque si queda algo en el buffer
      if (buffer.isNotEmpty) {
        if (buffer.length != blockSize) {
          if (kDebugMode) {
            print(
              '⚠️ Último bloque incompleto: ${buffer.length} bytes (esperado $blockSize)',
            );
          }
          // Intentar procesarlo de todas formas (puede ser padding)
          if (buffer.length >= blockSize) {
            final lastBlockBytes = Uint8List.fromList(
              buffer.sublist(0, blockSize),
            );
            Uint8List decryptedBlock;

            if (lastEncryptedBlock != null) {
              final decrypted = _encrypter!.decryptBytes(
                Encrypted(lastBlockBytes),
                iv: IV(lastEncryptedBlock),
              );
              decryptedBlock = decrypted is Uint8List
                  ? decrypted
                  : Uint8List.fromList(decrypted);
            } else {
              final decrypted = _encrypter!.decryptBytes(
                Encrypted(lastBlockBytes),
                iv: _initializationVector!,
              );
              decryptedBlock = decrypted is Uint8List
                  ? decrypted
                  : Uint8List.fromList(decrypted);
            }

            yield decryptedBlock;
          }
        } else {
          // Procesar el último bloque completo
          final lastBlockBytes = Uint8List.fromList(buffer);
          Uint8List decryptedBlock;

          if (lastEncryptedBlock != null) {
            final decrypted = _encrypter!.decryptBytes(
              Encrypted(lastBlockBytes),
              iv: IV(lastEncryptedBlock!),
            );
            decryptedBlock = decrypted is Uint8List
                ? decrypted
                : Uint8List.fromList(decrypted);
          } else {
            final decrypted = _encrypter!.decryptBytes(
              Encrypted(lastBlockBytes),
              iv: _initializationVector!,
            );
            decryptedBlock = decrypted is Uint8List
                ? decrypted
                : Uint8List.fromList(decrypted);
          }

          yield decryptedBlock;
        }
      }

      if (kDebugMode) {
        print('✅ Video desencriptado exitosamente (método por chunks)');
      }
    } catch (e) {
      throw Exception('Error desencriptando video: $e');
    }
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
