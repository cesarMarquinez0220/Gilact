import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Servicio para comprimir y optimizar imágenes
class ImageCompressionService {
  static final ImageCompressionService _instance =
      ImageCompressionService._internal();
  factory ImageCompressionService() => _instance;
  ImageCompressionService._internal();

  // Configuración de compresión
  static const int _defaultQuality = 85;
  static const int _maxWidth = 800;
  static const int _maxHeight = 600;
  static const int _thumbnailSize = 200;

  /// Comprimir una imagen desde assets
  Future<Uint8List?> compressAssetImage(
    String assetPath, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // Cargar la imagen desde assets
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      return await _compressImageBytes(
        bytes,
        quality: quality,
        maxWidth: maxWidth ?? _maxWidth,
        maxHeight: maxHeight ?? _maxHeight,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error comprimiendo imagen desde assets: $e');
      }
      return null;
    }
  }

  /// Comprimir una imagen desde bytes
  Future<Uint8List?> compressImageBytes(
    Uint8List imageBytes, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    return await _compressImageBytes(
      imageBytes,
      quality: quality,
      maxWidth: maxWidth ?? _maxWidth,
      maxHeight: maxHeight ?? _maxHeight,
    );
  }

  /// Comprimir una imagen desde archivo
  Future<Uint8List?> compressImageFile(
    File imageFile, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await _compressImageBytes(
        bytes,
        quality: quality,
        maxWidth: maxWidth ?? _maxWidth,
        maxHeight: maxHeight ?? _maxHeight,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error comprimiendo archivo de imagen: $e');
      }
      return null;
    }
  }

  /// Crear thumbnail de una imagen
  Future<Uint8List?> createThumbnail(
    Uint8List imageBytes, {
    int size = _thumbnailSize,
    int quality = _defaultQuality,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Calcular dimensiones manteniendo aspect ratio
      int width, height;
      if (image.width > image.height) {
        width = size;
        height = (image.height * size / image.width).round();
      } else {
        height = size;
        width = (image.width * size / image.height).round();
      }

      // Redimensionar
      final resized = img.copyResize(image, width: width, height: height);

      // Codificar como JPEG
      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    } catch (e) {
      if (kDebugMode) {
        print('Error creando thumbnail: $e');
      }
      return null;
    }
  }

  /// Comprimir imagen interna
  Future<Uint8List?> _compressImageBytes(
    Uint8List imageBytes, {
    required int quality,
    required int maxWidth,
    required int maxHeight,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Calcular nuevas dimensiones manteniendo aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (image.width > image.height) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Redimensionar si es necesario
      img.Image processedImage = image;
      if (newWidth != image.width || newHeight != image.height) {
        processedImage = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.cubic,
        );
      }

      // Optimizar la imagen
      processedImage = _optimizeImage(processedImage);

      // Codificar como JPEG con calidad especificada
      return Uint8List.fromList(
        img.encodeJpg(processedImage, quality: quality),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error en compresión interna: $e');
      }
      return null;
    }
  }

  /// Optimizar imagen (reducir colores, mejorar contraste, etc.)
  img.Image _optimizeImage(img.Image image) {
    // Convertir a RGB si es necesario
    if (image.format != img.Format.uint8 || image.numChannels != 3) {
      // Crear una nueva imagen RGB
      final rgbImage = img.Image(
        width: image.width,
        height: image.height,
        format: img.Format.uint8,
        numChannels: 3,
      );

      // Copiar píxeles convertidos
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          rgbImage.setPixel(x, y, pixel);
        }
      }

      image = rgbImage;
    }

    // Aplicar corrección de gamma ligera
    image = img.adjustColor(image, gamma: 1.1);

    // Mejorar contraste ligeramente
    image = img.contrast(image, contrast: 1.05);

    return image;
  }

  /// Obtener información de una imagen
  Future<Map<String, dynamic>?> getImageInfo(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
        'format': image.format.toString(),
        'channels': image.numChannels,
        'size': imageBytes.length,
        'aspectRatio': image.width / image.height,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo información de imagen: $e');
      }
      return null;
    }
  }

  /// Calcular el tamaño de compresión recomendado
  Map<String, int> calculateCompressionSize(
    int originalWidth,
    int originalHeight,
  ) {
    int targetWidth = originalWidth;
    int targetHeight = originalHeight;

    // Si la imagen es muy grande, reducir proporcionalmente
    if (originalWidth > _maxWidth || originalHeight > _maxHeight) {
      final aspectRatio = originalWidth / originalHeight;

      if (originalWidth > originalHeight) {
        targetWidth = _maxWidth;
        targetHeight = (_maxWidth / aspectRatio).round();
      } else {
        targetHeight = _maxHeight;
        targetWidth = (_maxHeight * aspectRatio).round();
      }
    }

    return {'width': targetWidth, 'height': targetHeight};
  }

  /// Batch compression para múltiples imágenes
  Future<List<Uint8List?>> compressMultipleImages(
    List<Uint8List> imageBytesList, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final results = <Uint8List?>[];

    for (final imageBytes in imageBytesList) {
      final compressed = await compressImageBytes(
        imageBytes,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      results.add(compressed);
    }

    return results;
  }

  /// Limpiar metadatos de imagen
  Future<Uint8List?> stripMetadata(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Crear una nueva imagen sin metadatos
      final cleanImage = img.Image(
        width: image.width,
        height: image.height,
        format: image.format,
        numChannels: image.numChannels,
      );

      // Copiar datos de píxeles
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          cleanImage.setPixel(x, y, pixel);
        }
      }

      return Uint8List.fromList(img.encodeJpg(cleanImage));
    } catch (e) {
      if (kDebugMode) {
        print('Error removiendo metadatos: $e');
      }
      return null;
    }
  }

  /// Obtener estadísticas de compresión
  Map<String, dynamic> getCompressionStats(
    int originalSize,
    int compressedSize,
  ) {
    final compressionRatio = (1 - compressedSize / originalSize) * 100;
    final spaceSaved = originalSize - compressedSize;

    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio.round(),
      'spaceSaved': spaceSaved,
      'spaceSavedKB': (spaceSaved / 1024).round(),
      'spaceSavedMB': (spaceSaved / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}
