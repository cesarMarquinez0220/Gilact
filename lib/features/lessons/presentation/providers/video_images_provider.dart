import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provider para manejar las imágenes de videos disponibles
class VideoImagesProvider extends ChangeNotifier {
  static final VideoImagesProvider _instance = VideoImagesProvider._internal();
  factory VideoImagesProvider() => _instance;
  VideoImagesProvider._internal();

  // Lista de imágenes disponibles
  List<String> _availableImages = [];
  List<String> get availableImages => _availableImages;

  // Mapeo de videoId a nombre de imagen
  Map<int, String> _videoImageMapping = {};
  Map<int, String> get videoImageMapping => _videoImageMapping;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Inicializa el provider cargando las imágenes disponibles
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Lista de imágenes conocidas en assets/mini_videos/
      final knownImages = [
        '1.png',
        '2.1.png',
        '2.2.png',
        '3.1.png',
        '3.2.png',
        '3.3.png',
        '3.4.png',
        '4.1.png',
        '4.2.png',
        '5.png',
        '6.png',
        '7.png',
        '8.1.png',
        '8.2.png',
        '9.png',
        '10.png',
        '11.1.png',
        '11.2.png',
        '11.3.png',
        '11.4.png',
        '11.5.png',
        '12.png',
        '13.1.png',
        '13.2.png',
        '13.3.png',
        '14.1.png',
        '14.2.png',
        '15.png',
        '16.png',
      ];

      // Verificar qué imágenes realmente existen
      final existingImages = <String>[];

      for (final imageName in knownImages) {
        try {
          // Intentar cargar la imagen para verificar que existe
          await rootBundle.load('assets/mini_videos/$imageName');
          existingImages.add(imageName);
        } catch (e) {
          // La imagen no existe, continuar con la siguiente
          debugPrint('Imagen no encontrada: assets/mini_videos/$imageName');
        }
      }

      _availableImages = existingImages;

      // Crear mapeo automático basado en el orden de las imágenes
      _videoImageMapping.clear();
      for (int i = 0; i < _availableImages.length; i++) {
        _videoImageMapping[i + 1] = _availableImages[i]; // videoId empieza en 1
      }

      _isInitialized = true;
      notifyListeners();

      debugPrint(
        '✅ VideoImagesProvider inicializado con ${_availableImages.length} imágenes',
      );
      debugPrint('📋 Imágenes disponibles: $_availableImages');
    } catch (e) {
      debugPrint('❌ Error inicializando VideoImagesProvider: $e');
      // Fallback: usar imágenes por defecto
      _availableImages = ['1.png'];
      _videoImageMapping = {1: '1.png'};
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Obtiene el nombre de imagen para un videoId específico
  String getImageNameForVideo(int videoId) {
    if (!_isInitialized) {
      debugPrint(
        '⚠️ VideoImagesProvider no inicializado, usando imagen por defecto',
      );
      return '1.png';
    }

    final imageName = _videoImageMapping[videoId];
    if (imageName != null) {
      return imageName;
    }

    // Fallback: usar la primera imagen disponible
    debugPrint(
      '⚠️ No se encontró imagen para videoId $videoId, usando primera disponible',
    );
    return _availableImages.isNotEmpty ? _availableImages.first : '1.png';
  }

  /// Obtiene la ruta completa de la imagen para un videoId
  String getImagePathForVideo(int videoId) {
    final imageName = getImageNameForVideo(videoId);
    return 'assets/mini_videos/$imageName';
  }

  /// Verifica si existe una imagen para un videoId específico
  bool hasImageForVideo(int videoId) {
    return _videoImageMapping.containsKey(videoId);
  }

  /// Obtiene el número total de imágenes disponibles
  int get totalImages => _availableImages.length;

  /// Reinicia el provider (útil para testing)
  void reset() {
    _availableImages.clear();
    _videoImageMapping.clear();
    _isInitialized = false;
    notifyListeners();
  }
}
