import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class LeccionesProvider extends ChangeNotifier {
  final Set<int> _leccionesCompletadas = {};
  final Map<int, double> _progresoVideos = {};

  // Claves para SharedPreferences
  static const String _keyLeccionesCompletadas = 'lecciones_completadas';
  static const String _keyProgresoVideos = 'progreso_videos';

  LeccionesProvider() {
    // No cargar progreso automáticamente - se cargará desde MainNavigationPage
    print('📚 LeccionesProvider inicializado (sin carga automática)');
  }

  bool isLeccionCompletada(int videoId) {
    return _leccionesCompletadas.contains(videoId);
  }

  double getProgresoVideo(int videoId) {
    return _progresoVideos[videoId] ?? 0.0;
  }

  void marcarLeccionCompletada(int videoId) {
    _leccionesCompletadas.add(videoId);
    _progresoVideos[videoId] = 100.0;
    _guardarProgreso();

    // Precargar el siguiente video cuando se completa una lección
    _preloadNextVideo(videoId);

    notifyListeners();
  }

  /// Precarga el siguiente video cuando se completa una lección
  void _preloadNextVideo(int currentVideoId) {
    // Notificar al MainNavigationPage para precargar el siguiente video
    // Esto se puede hacer a través de un callback o evento
    print(
      '🎯 Lección $currentVideoId completada, precargando siguiente video...',
    );
  }

  void actualizarProgresoVideo(int videoId, double progreso) {
    _progresoVideos[videoId] = progreso;

    // Si el progreso es 100%, marcar como completada
    if (progreso >= 100.0) {
      _leccionesCompletadas.add(videoId);
    }

    _guardarProgreso();
    notifyListeners();
  }

  int get ultimaLeccionCompletada {
    if (_leccionesCompletadas.isEmpty) return 0;
    return _leccionesCompletadas.reduce((a, b) => a > b ? a : b);
  }

  /// Limpia todo el progreso guardado (para cuentas nuevas)
  Future<void> clearProgress() async {
    _leccionesCompletadas.clear();
    _progresoVideos.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLeccionesCompletadas);
    await prefs.remove(_keyProgresoVideos);

    print('🧹 Progreso limpiado para cuenta nueva');
    notifyListeners();
  }

  /// Carga el progreso desde Firestore para usuarios existentes
  Future<void> loadProgressFromFirestore(String userId) async {
    try {
      print('📊 Cargando progreso desde Firestore para usuario: $userId');

      // Limpiar datos locales primero
      _leccionesCompletadas.clear();
      _progresoVideos.clear();

      // Cargar desde Firestore
      final videosCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('videos');

      final querySnapshot = await videosCollection.get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final videoId = data['videoId'] as int?;
        final isCompleted = data['estaCompletado'] as bool? ?? false;
        final completado = data['estaCompletado'] as bool? ?? false;
        final avance = data['avance'] as double? ?? 0.0;

        if (videoId != null) {
          // Usar el progreso de Firestore
          _progresoVideos[videoId] = avance * 100;

          // Marcar como completado solo si ambos campos son true
          if (isCompleted && completado) {
            _leccionesCompletadas.add(videoId);
            print('✅ Video $videoId marcado como completado desde Firestore');
          } else {
            print(
              '⏸️ Video $videoId NO completado (isCompleted: $isCompleted, completado: $completado)',
            );
          }
        }
      }

      print(
        '📊 Progreso cargado desde Firestore: ${_leccionesCompletadas.length} videos completados',
      );
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando progreso desde Firestore: $e');
      // Fallback a SharedPreferences
      await _cargarProgresoGuardado();
    }
  }

  /// Carga el progreso guardado desde SharedPreferences
  Future<void> _cargarProgresoGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar lecciones completadas
      final leccionesJson = prefs.getString(_keyLeccionesCompletadas);
      if (leccionesJson != null) {
        final List<dynamic> leccionesList = jsonDecode(leccionesJson);
        _leccionesCompletadas.addAll(leccionesList.cast<int>());
      }

      // Cargar progreso de videos
      final progresoJson = prefs.getString(_keyProgresoVideos);
      if (progresoJson != null) {
        final Map<String, dynamic> progresoMap = jsonDecode(progresoJson);
        _progresoVideos.addAll(
          progresoMap.map(
            (key, value) => MapEntry(int.parse(key), value.toDouble()),
          ),
        );
      }

      if (kDebugMode) {
        print(
          '📚 Progreso cargado: ${_leccionesCompletadas.length} lecciones completadas',
        );
        print('📊 Videos con progreso: ${_progresoVideos.length}');
        print('🎯 Lecciones completadas: $_leccionesCompletadas');
        print('📈 Progreso videos: $_progresoVideos');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cargando progreso: $e');
      }
    }
  }

  /// Guarda el progreso actual en SharedPreferences
  Future<void> _guardarProgreso() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Guardar lecciones completadas
      final leccionesList = _leccionesCompletadas.toList();
      await prefs.setString(
        _keyLeccionesCompletadas,
        jsonEncode(leccionesList),
      );

      // Guardar progreso de videos
      final progresoMap = _progresoVideos.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await prefs.setString(_keyProgresoVideos, jsonEncode(progresoMap));

      if (kDebugMode) {
        print('💾 Progreso guardado exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando progreso: $e');
      }
    }
  }

  /// Limpia todo el progreso (útil para testing)
  Future<void> limpiarProgreso() async {
    _leccionesCompletadas.clear();
    _progresoVideos.clear();
    await _guardarProgreso();
    notifyListeners();
  }

  /// Obtiene estadísticas del progreso
  Map<String, dynamic> get estadisticasProgreso {
    return {
      'leccionesCompletadas': _leccionesCompletadas.length,
      'videosConProgreso': _progresoVideos.length,
      'ultimaLeccionCompletada': ultimaLeccionCompletada,
      'progresoTotal': _progresoVideos.length > 0
          ? _progresoVideos.values.fold(0.0, (a, b) => a + b) /
                (_progresoVideos.length * 100)
          : 0.0,
    };
  }

  /// Método legacy para compatibilidad
  void imprimirAvancesMap() {
    if (kDebugMode) {
      print('Lecciones completadas: $_leccionesCompletadas');
      print('Progreso videos: $_progresoVideos');
    }
  }
}
