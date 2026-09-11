import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../../../gamification/domain/services/gamification_service.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../data/services/video_service.dart';

class LeccionesProvider extends ChangeNotifier {
  final Set<int> _leccionesCompletadas = {};
  final Map<int, double> _progresoVideos = {};
  final AppLogger _logger = getIt<AppLogger>();
  GamificationService? _gamificationService;

  // Claves para SharedPreferences
  static const String _keyLeccionesCompletadas = 'lecciones_completadas';
  static const String _keyProgresoVideos = 'progreso_videos';

  LeccionesProvider() {
    // No cargar progreso automáticamente - se cargará desde MainNavigationPage
    _logger.d('LeccionesProvider inicializado (sin carga automática)');
    // Obtener GamificationService de forma lazy para evitar dependencias circulares
    try {
      _gamificationService = getIt<GamificationService>();
    } catch (e) {
      _logger.w(
        'GamificationService no disponible aún, se intentará más tarde',
      );
    }
  }

  /// Obtiene el número de lecciones completadas (lecciones únicas, no videos)
  /// Calcula las lecciones únicas basándose en los videos completados
  int get completedLessonsCount {
    // Si no hay videos completados, retornar 0
    if (_leccionesCompletadas.isEmpty) return 0;

    // Obtener todos los videos para mapear videoId -> leccionId
    // Usar un método asíncrono no es posible en un getter, así que usamos un cache
    // Por ahora, retornamos el conteo de videos como aproximación
    // TODO: Implementar cache de mapeo videoId -> leccionId
    return _leccionesCompletadas.length;
  }

  /// Calcula el número de lecciones únicas completadas
  /// Este método consulta VideoService para obtener el leccionId de cada video
  Future<int> getCompletedLessonsCountUnique() async {
    if (_leccionesCompletadas.isEmpty) return 0;

    try {
      // Obtener todos los videos
      final allVideos = await VideoService.getVideos();

      // Crear un mapa de videoId -> leccionId
      final videoToLessonMap = <int, int>{};
      for (final video in allVideos) {
        videoToLessonMap[video.videoId] = video.leccionId;
      }

      // Obtener lecciones únicas de los videos completados
      final uniqueLessons = <int>{};
      for (final videoId in _leccionesCompletadas) {
        final leccionId = videoToLessonMap[videoId];
        if (leccionId != null && leccionId > 0) {
          uniqueLessons.add(leccionId);
        }
      }

      _logger.d(
        'Lecciones únicas completadas: ${uniqueLessons.length} (de ${_leccionesCompletadas.length} videos)',
      );

      return uniqueLessons.length;
    } catch (e, stackTrace) {
      _logger.e('Error calculando lecciones únicas', e, stackTrace);
      // Fallback: retornar conteo de videos como aproximación
      return _leccionesCompletadas.length;
    }
  }

  /// Notifica a GamificationService sobre cambios en lecciones completadas
  /// Retorna el perfil actualizado si la etapa cambió, null en caso contrario
  Future<UserGamificationProfile?> _notifyLessonsCompletedChanged() async {
    if (_gamificationService == null) {
      try {
        _gamificationService = getIt<GamificationService>();
      } catch (e) {
        _logger.w(
          'GamificationService no disponible para actualizar etapa del bebé',
        );
        return null;
      }
    }

    // Calcular lecciones únicas completadas (no videos)
    final completedCount = await getCompletedLessonsCountUnique();
    if (completedCount == 0) return null;

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) return null;

      final result = await _gamificationService!.updateBabyStage(
        userId: authUser.uid,
        completedLessons: completedCount,
      );

      return result.fold(
        (error) {
          _logger.w('Error actualizando etapa del bebé: $error');
          return null;
        },
        (profile) {
          _logger.d(
            'Etapa del bebé actualizada: ${profile.babyStage} ($completedCount lecciones únicas)',
          );
          return profile;
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error notificando cambio de lecciones completadas',
        e,
        stackTrace,
      );
      return null;
    }
  }

  bool isLeccionCompletada(int videoId) {
    return _leccionesCompletadas.contains(videoId);
  }

  double getProgresoVideo(int videoId) {
    return _progresoVideos[videoId] ?? 0.0;
  }

  void marcarLeccionCompletada(int videoId) {
    final wasAlreadyCompleted = _leccionesCompletadas.contains(videoId);
    _leccionesCompletadas.add(videoId);
    _progresoVideos[videoId] = 100.0;
    _guardarProgreso();

    // Precargar el siguiente video cuando se completa una lección
    _preloadNextVideo(videoId);

    // Notificar cambio en lecciones completadas (Observer Pattern)
    // El perfil actualizado se retorna para que el llamador pueda actualizar el bloc
    if (!wasAlreadyCompleted) {
      _notifyLessonsCompletedChanged();
    }

    notifyListeners();
  }

  /// Marca una lección como completada y retorna el perfil actualizado si la etapa cambió
  /// Útil cuando necesitas actualizar el GamificationBloc después de completar una lección
  Future<UserGamificationProfile?> marcarLeccionCompletadaWithProfileUpdate(
    int videoId,
  ) async {
    final wasAlreadyCompleted = _leccionesCompletadas.contains(videoId);
    _leccionesCompletadas.add(videoId);
    _progresoVideos[videoId] = 100.0;
    _guardarProgreso();

    // Precargar el siguiente video cuando se completa una lección
    _preloadNextVideo(videoId);

    // Notificar cambio en lecciones completadas y retornar perfil actualizado
    UserGamificationProfile? updatedProfile;
    if (!wasAlreadyCompleted) {
      updatedProfile = await _notifyLessonsCompletedChanged();
    }

    notifyListeners();
    return updatedProfile;
  }

  /// Precarga el siguiente video cuando se completa una lección
  void _preloadNextVideo(int currentVideoId) {
    // Notificar al MainNavigationPage para precargar el siguiente video
    // Esto se puede hacer a través de un callback o evento
    _logger.d(
      'Lección $currentVideoId completada, precargando siguiente video...',
    );
  }

  void actualizarProgresoVideo(int videoId, double progreso) {
    _progresoVideos[videoId] = progreso;

    // Si el progreso es 100%, marcar como completada
    final wasAlreadyCompleted = _leccionesCompletadas.contains(videoId);
    if (progreso >= 100.0) {
      _leccionesCompletadas.add(videoId);

      // Notificar cambio en lecciones completadas si es nueva
      if (!wasAlreadyCompleted) {
        _notifyLessonsCompletedChanged();
      }
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

    _logger.d('Progreso limpiado para cuenta nueva');
    notifyListeners();
  }

  /// Carga el progreso desde Firestore con optimización de lecturas
  Future<void> loadProgressFromFirestore(String? userIdParam) async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      final targetUserId = (userIdParam != null && userIdParam.isNotEmpty)
          ? userIdParam
          : authUser?.uid;

      if (targetUserId == null) {
        _logger.w(
          'LeccionesProvider: No hay usuario autenticado para cargar progreso',
        );
        return;
      }

      _logger.d('Cargando progreso optimizado para: $targetUserId');

      // Limpiar datos locales
      _leccionesCompletadas.clear();
      _progresoVideos.clear();

      final videosCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(targetUserId)
          .collection('videos');

      List<QueryDocumentSnapshot> docs = [];

      // ESTRATEGIA OPTIMIZADA:
      // 1. Intentar leer de caché local primero (Costo: 0 lecturas)
      // 2. Si hay error o está vacío, leer de servidor (Costo: N lecturas)

      try {
        final cacheSnapshot = await videosCollection.get(
          const GetOptions(source: Source.cache),
        );
        if (cacheSnapshot.docs.isNotEmpty) {
          docs = cacheSnapshot.docs;
          _logger.d('Progreso cargado desde CACHÉ (${docs.length} videos)');
        }
      } catch (e) {
        _logger.d('Cache miss o error, intentando servidor...');
      }

      // Si no tenemos docs, ir al servidor
      if (docs.isEmpty) {
        try {
          final serverSnapshot = await videosCollection.get(
            const GetOptions(source: Source.server),
          );
          docs = serverSnapshot.docs;
          _logger.d('Progreso cargado desde SERVIDOR (${docs.length} videos)');
        } catch (e) {
          _logger.e('Error leyendo del servidor', e);
        }
      }

      // Procesar documentos (solo si encontramos algo)
      if (docs.isNotEmpty) {
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final videoId = data['videoId'] as int? ?? int.tryParse(doc.id);
          final estaCompletado = data['estaCompletado'] as bool? ?? false;

          if (videoId == null) continue;

          // Manejar avance
          dynamic avanceRaw = data['avance'];
          double avance = 0.0;

          if (avanceRaw is int) {
            avance = avanceRaw.toDouble();
          } else if (avanceRaw is double) {
            avance = avanceRaw;
          } else {
            final ultimaPosicion = data['ultimaPosicion'] as int? ?? 0;
            final duracion = data['duracion'] as int? ?? 0;
            if (duracion > 0) {
              avance = ultimaPosicion / duracion;
            }
          }

          if (estaCompletado) {
            _progresoVideos[videoId] = 100.0;
            _leccionesCompletadas.add(videoId);
          } else {
            _progresoVideos[videoId] = avance * 100;
          }
        }

        _logger.success(
          'Progreso procesado: ${_leccionesCompletadas.length} completados',
        );
        _notifyLessonsCompletedChanged();
        notifyListeners();
        return;
      } else {
        _logger.d('No se encontró progreso para $targetUserId');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fatal cargando progreso', e, stackTrace);
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

      _logger.d(
        'Progreso cargado: ${_leccionesCompletadas.length} lecciones completadas, ${_progresoVideos.length} videos con progreso',
      );

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error cargando progreso', e, stackTrace);
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

      _logger.success('Progreso guardado exitosamente');
    } catch (e, stackTrace) {
      _logger.e('Error guardando progreso', e, stackTrace);
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
      'progresoTotal': _progresoVideos.isNotEmpty
          ? _progresoVideos.values.fold(0.0, (a, b) => a + b) /
                (_progresoVideos.length * 100)
          : 0.0,
    };
  }

  /// Método legacy para compatibilidad
  void imprimirAvancesMap() {
    _logger.d(
      'Lecciones completadas: $_leccionesCompletadas, Progreso videos: $_progresoVideos',
    );
  }
}
