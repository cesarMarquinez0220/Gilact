import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // El VideoProgressService guarda usando user.uid (UID de Firebase Auth)
      // Necesitamos buscar en ambos lugares: el userId proporcionado y el UID de Firebase Auth
      // y combinar los resultados porque los videos pueden estar guardados en diferentes lugares
      final authUser = FirebaseAuth.instance.currentUser;
      final List<QueryDocumentSnapshot> allDocs = [];
      final Set<String> usedUserIds = {};
      
      // 1. Buscar con el userId proporcionado
      if (userId.isNotEmpty) {
        try {
          final videosCollection = FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('videos');
          final querySnapshot = await videosCollection.get();
          allDocs.addAll(querySnapshot.docs);
          usedUserIds.add(userId);
          print('📊 LeccionesProvider: Encontrados ${querySnapshot.docs.length} documentos con userId: $userId');
        } catch (e) {
          print('⚠️ LeccionesProvider: Error buscando con userId $userId: $e');
        }
      }
      
      // 2. Buscar con el UID de Firebase Auth (si es diferente del userId)
      if (authUser != null && authUser.uid != userId && !usedUserIds.contains(authUser.uid)) {
        try {
          final videosCollection = FirebaseFirestore.instance
              .collection('Users')
              .doc(authUser.uid)
              .collection('videos');
          final querySnapshot = await videosCollection.get();
          allDocs.addAll(querySnapshot.docs);
          usedUserIds.add(authUser.uid);
          print('📊 LeccionesProvider: Encontrados ${querySnapshot.docs.length} documentos con UID de Firebase Auth: ${authUser.uid}');
        } catch (e) {
          print('⚠️ LeccionesProvider: Error buscando con UID de Firebase Auth: $e');
        }
      }
      
      // 3. Si aún no hay documentos, buscar por email
      if (allDocs.isEmpty && authUser != null && authUser.email != null) {
        try {
          final userQuery = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: authUser.email)
              .limit(1)
              .get();
          
          if (userQuery.docs.isNotEmpty) {
            final actualUserId = userQuery.docs.first.id;
            print('🔍 LeccionesProvider: Usuario encontrado por email, ID real: $actualUserId');
            if (!usedUserIds.contains(actualUserId)) {
              final videosCollection = FirebaseFirestore.instance
                  .collection('Users')
                  .doc(actualUserId)
                  .collection('videos');
              final querySnapshot = await videosCollection.get();
              allDocs.addAll(querySnapshot.docs);
              usedUserIds.add(actualUserId);
              print('📊 LeccionesProvider: Encontrados ${querySnapshot.docs.length} documentos con userId por email: $actualUserId');
            }
          }
        } catch (e) {
          print('⚠️ LeccionesProvider: Error buscando usuario por email: $e');
        }
      }
      
      // Eliminar duplicados basándose en el ID del documento (videoId)
      final Map<String, QueryDocumentSnapshot> uniqueDocs = {};
      for (final doc in allDocs) {
        final videoId = doc.id;
        // Si ya existe, mantener el más reciente (basado en fechaActualizacion si está disponible)
        if (!uniqueDocs.containsKey(videoId)) {
          uniqueDocs[videoId] = doc;
        } else {
          final existingData = uniqueDocs[videoId]!.data() as Map<String, dynamic>;
          final newData = doc.data() as Map<String, dynamic>;
          final existingDate = existingData['fechaActualizacion'];
          final newDate = newData['fechaActualizacion'];
          if (newDate != null && (existingDate == null || 
              (newDate is Timestamp && existingDate is Timestamp && 
               newDate.compareTo(existingDate) > 0))) {
            uniqueDocs[videoId] = doc;
          }
        }
      }
      
      final querySnapshot = uniqueDocs.values.toList();
      print('📊 LeccionesProvider: Total documentos únicos encontrados: ${querySnapshot.length} (buscados en: ${usedUserIds.join(", ")})');

      for (final doc in querySnapshot) {
        final data = doc.data() as Map<String, dynamic>;
        print(
          '🔍 LeccionesProvider: Procesando documento ${doc.id} con datos: $data',
        );

        // Usar el ID del documento como videoId, o el campo videoId si existe
        final videoId = data['videoId'] as int? ?? int.tryParse(doc.id);
        final estaCompletado = data['estaCompletado'] as bool? ?? false;

        print(
          '🔍 LeccionesProvider: videoId = $videoId, estaCompletado = $estaCompletado',
        );

        // Manejar avance que puede ser int o double
        dynamic avanceRaw = data['avance'];
        double avance = 0.0;
        if (avanceRaw != null) {
          print(
            '🔍 LeccionesProvider: avanceRaw = $avanceRaw (tipo: ${avanceRaw.runtimeType})',
          );
          if (avanceRaw is int) {
            avance = avanceRaw.toDouble();
            print(
              '🔍 LeccionesProvider: avance convertido de int a double: $avance',
            );
          } else if (avanceRaw is double) {
            avance = avanceRaw;
            print('🔍 LeccionesProvider: avance ya es double: $avance');
          }
        } else {
          // Si no hay avance, calcularlo desde ultimaPosicion y duracion
          final ultimaPosicion = data['ultimaPosicion'] as int? ?? 0;
          final duracion = data['duracion'] as int? ?? 0;
          if (duracion > 0 && ultimaPosicion > 0) {
            avance = ultimaPosicion / duracion;
            print(
              '🔍 LeccionesProvider: avance calculado desde ultimaPosicion ($ultimaPosicion) / duracion ($duracion) = ${avance.toStringAsFixed(3)}',
            );
          } else {
            print('🔍 LeccionesProvider: avanceRaw es null y no se puede calcular, usando 0.0');
          }
        }

        if (videoId != null) {
          // Si el video está completado, el progreso debe ser 100%
          // Si no está completado, usar el avance de Firestore (o calculado)
          if (estaCompletado) {
            _progresoVideos[videoId] = 100.0;
            _leccionesCompletadas.add(videoId);
            print('✅ Video $videoId marcado como completado desde Firestore (progreso: 100%)');
          } else {
            // Usar el progreso de Firestore (avance viene como 0.0-1.0, convertir a porcentaje)
            final progressPercentage = avance * 100;
            _progresoVideos[videoId] = progressPercentage;
            print(
              '⏸️ Video $videoId NO completado (estaCompletado: $estaCompletado, avance: ${progressPercentage.toStringAsFixed(1)}%)',
            );
          }
        } else {
          print('❌ Error: No se pudo obtener videoId del documento ${doc.id}');
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
      'progresoTotal': _progresoVideos.isNotEmpty
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
