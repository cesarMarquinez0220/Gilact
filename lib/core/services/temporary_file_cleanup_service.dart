import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'app_logger.dart';
import '../di/injection.dart';

/// Servicio para limpiar archivos temporales sensibles que puedan haber quedado
/// de sesiones anteriores (por ejemplo, videos desencriptados)
@singleton
class TemporaryFileCleanupService {
  final AppLogger _logger = getIt<AppLogger>();

  /// Limpia archivos temporales desencriptados al iniciar la app
  /// Esto asegura que no queden datos sensibles en el almacenamiento
  /// si la app se cerró inesperadamente
  Future<void> cleanupTemporaryDecryptedFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      int deletedCount = 0;
      for (final entity in files) {
        if (entity is File && entity.path.contains('_decrypted.mp4')) {
          try {
            await _secureDeleteFile(entity);
            deletedCount++;
          } catch (e) {
            _logger.w('Error eliminando archivo temporal: ${entity.path}', e);
          }
        }
      }

      if (deletedCount > 0) {
        _logger.success(
          'Limpieza de archivos temporales: $deletedCount archivo(s) eliminado(s)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error en limpieza de archivos temporales', e, stackTrace);
    }
  }

  /// Sobrescribe de forma segura un archivo antes de eliminarlo
  /// Esto previene la recuperación de datos sensibles desde el almacenamiento
  Future<void> _secureDeleteFile(File file) async {
    try {
      if (!await file.exists()) return;

      final fileSize = await file.length();
      if (fileSize == 0) {
        await file.delete();
        return;
      }

      // Sobrescribir el archivo con datos aleatorios (3 pasadas para mayor seguridad)
      final random = Random.secure();
      final randomBytes = Uint8List(fileSize);

      for (int pass = 0; pass < 3; pass++) {
        // Generar datos aleatorios para esta pasada
        for (int i = 0; i < fileSize; i++) {
          randomBytes[i] = random.nextInt(256);
        }

        // Escribir datos aleatorios
        final raf = await file.open(mode: FileMode.write);
        await raf.writeFrom(randomBytes);
        await raf.flush();
        await raf.close();
      }

      // Finalmente, eliminar el archivo
      await file.delete();
    } catch (e) {
      // Si falla la eliminación segura, intentar eliminación normal
      try {
        await file.delete();
      } catch (deleteError) {
        rethrow;
      }
    }
  }
}
