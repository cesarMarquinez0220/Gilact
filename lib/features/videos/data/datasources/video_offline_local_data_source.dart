import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Modelo de datos para video offline
class OfflineVideoModel {
  final String videoId;
  final String title;
  final String description;
  final String imageUrl;
  final String imageName;
  final int lessonId;
  final int videoIdNumber;
  final Duration duration;
  final String encryptedFilePath;
  final int fileSizeBytes;
  final DateTime downloadedAt;
  final DateTime lastAccessedAt;
  final int order;

  OfflineVideoModel({
    required this.videoId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageName,
    required this.lessonId,
    required this.videoIdNumber,
    required this.duration,
    required this.encryptedFilePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
    required this.lastAccessedAt,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'image_name': imageName,
      'lesson_id': lessonId,
      'video_id_number': videoIdNumber,
      'duration_seconds': duration.inSeconds,
      'encrypted_file_path': encryptedFilePath,
      'file_size_bytes': fileSizeBytes,
      'downloaded_at': downloadedAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'order': order,
    };
  }

  factory OfflineVideoModel.fromMap(Map<String, dynamic> map) {
    return OfflineVideoModel(
      videoId: map['video_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      imageName: map['image_name'] as String,
      lessonId: map['lesson_id'] as int,
      videoIdNumber: map['video_id_number'] as int,
      duration: Duration(seconds: map['duration_seconds'] as int),
      encryptedFilePath: map['encrypted_file_path'] as String,
      fileSizeBytes: map['file_size_bytes'] as int,
      downloadedAt: DateTime.parse(map['downloaded_at'] as String),
      lastAccessedAt: DateTime.parse(map['last_accessed_at'] as String),
      order: map['order'] as int,
    );
  }
}

/// Data source local para videos offline usando SQLite
class VideoOfflineLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Fuerza la reinicialización de la base de datos (útil después de migraciones)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_videos.db');

    final db = await openDatabase(
      path,
      version: 2, // Incrementado para agregar columna image_name
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    // Verificar que la columna image_name existe, si no, agregarla
    await _ensureImageNameColumn(db);
    
    return db;
  }
  
  /// Verifica y agrega todas las columnas necesarias si no existen
  Future<void> _ensureImageNameColumn(Database db) async {
    try {
      // Verificar si la columna existe usando PRAGMA table_info
      final tableInfo = await db.rawQuery('PRAGMA table_info(offline_videos)');
      final existingColumns = tableInfo.map((col) => col['name'] as String).toSet();
      
      if (kDebugMode) {
        print('🔍 Verificando columnas de offline_videos:');
        for (final column in tableInfo) {
          print('  - ${column['name']} (${column['type']})');
        }
      }
      
      // Lista de todas las columnas requeridas según el modelo OfflineVideoModel
      // Nota: 'order' es una palabra reservada en SQL, necesita comillas
      final requiredColumns = {
        'image_name': 'TEXT',
        'video_id_number': 'INTEGER',
        'encrypted_file_path': 'TEXT',
        'file_size_bytes': 'INTEGER',
        'last_accessed_at': 'TEXT',
        '"order"': 'INTEGER', // Usar comillas porque 'order' es palabra reservada
      };
      
      // Agregar columnas faltantes
      for (final entry in requiredColumns.entries) {
        final columnName = entry.key;
        final columnType = entry.value;
        // Para verificar existencia, usar el nombre sin comillas
        final columnNameWithoutQuotes = columnName.replaceAll('"', '');
        
        if (!existingColumns.contains(columnNameWithoutQuotes)) {
          if (kDebugMode) {
            print('⚠️ Columna $columnNameWithoutQuotes NO existe. Agregándola...');
          }
          try {
            // Usar el nombre con comillas en el ALTER TABLE
            await db.execute('ALTER TABLE offline_videos ADD COLUMN $columnName $columnType');
            if (kDebugMode) {
              print('✅ Columna $columnNameWithoutQuotes agregada exitosamente');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error agregando columna $columnNameWithoutQuotes: $e');
            }
          }
        } else {
          if (kDebugMode) {
            print('ℹ️ Columna $columnNameWithoutQuotes ya existe');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error verificando/agregando columnas: $e');
      }
      // No re-lanzar el error, solo loguear
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_videos (
        video_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        image_name TEXT,
        lesson_id INTEGER NOT NULL,
        video_id_number INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        encrypted_file_path TEXT NOT NULL,
        file_size_bytes INTEGER NOT NULL,
        downloaded_at TEXT NOT NULL,
        last_accessed_at TEXT NOT NULL,
        order INTEGER NOT NULL
      )
    ''');

    // Índices para búsquedas rápidas
    await db.execute('CREATE INDEX idx_lesson_id ON offline_videos(lesson_id)');
    await db.execute('CREATE INDEX idx_last_accessed ON offline_videos(last_accessed_at)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('🔄 Actualizando base de datos de versión $oldVersion a $newVersion');
    }
    
    if (oldVersion < 2) {
      // Agregar columnas faltantes si no existen
      // Nota: 'order' es una palabra reservada en SQL, necesita comillas
      final columnsToAdd = {
        'image_name': 'TEXT',
        'video_id_number': 'INTEGER',
        'encrypted_file_path': 'TEXT',
        'file_size_bytes': 'INTEGER',
        'last_accessed_at': 'TEXT',
        '"order"': 'INTEGER', // Usar comillas porque 'order' es palabra reservada
      };
      
      for (final entry in columnsToAdd.entries) {
        final columnName = entry.key;
        final columnType = entry.value;
        final columnNameWithoutQuotes = columnName.replaceAll('"', '');
        try {
          await db.execute('ALTER TABLE offline_videos ADD COLUMN $columnName $columnType');
          if (kDebugMode) {
            print('✅ Columna $columnNameWithoutQuotes agregada en migración');
          }
        } catch (e) {
          // La columna ya existe, ignorar el error
          if (kDebugMode) {
            print('ℹ️ Columna $columnNameWithoutQuotes ya existe o error al agregarla: $e');
          }
        }
      }
    }
  }

  /// Guarda información de un video descargado
  /// [originalVideoUrl] es opcional y se usa para llenar columnas antiguas como 'original_video_url'
  Future<void> saveOfflineVideo(OfflineVideoModel video, {String? originalVideoUrl}) async {
    final db = await database;
    
    // Verificación adicional antes de insertar (por si la migración no se ejecutó)
    await _ensureImageNameColumn(db);
    
    // Obtener el mapa de datos
    final dataMap = video.toMap();
    
    // Verificar columnas con NOT NULL y agregar valores faltantes
    try {
      final tableInfo = await db.rawQuery('PRAGMA table_info(offline_videos)');
      final existingColumns = tableInfo.map((col) => col['name'] as String).toSet();
      
      // Identificar columnas con NOT NULL que no están en el dataMap
      final notNullColumns = <String, dynamic>{};
      for (final col in tableInfo) {
        final colName = col['name'] as String;
        final notNull = col['notnull'] as int == 1;
        
        if (notNull && !dataMap.containsKey(colName) && existingColumns.contains(colName)) {
          // Columna con NOT NULL que no está en el dataMap
          if (colName == 'file_size') {
            notNullColumns[colName] = video.fileSizeBytes;
          } else if (colName == 'original_video_url') {
            // Usar el videoUrl proporcionado o un valor por defecto
            notNullColumns[colName] = originalVideoUrl ?? '';
            if (kDebugMode) {
              if (originalVideoUrl != null) {
                print('ℹ️ Usando videoUrl proporcionado para original_video_url: $originalVideoUrl');
              } else {
                print('⚠️ Columna original_video_url requiere valor, usando cadena vacía');
              }
            }
          }
        }
      }
      
      // Agregar valores a dataMap
      dataMap.addAll(notNullColumns);
      
      if (kDebugMode && notNullColumns.isNotEmpty) {
        print('ℹ️ Agregando valores para columnas NOT NULL: $notNullColumns');
        print('📋 Columnas en dataMap antes de insertar: ${dataMap.keys.toList()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error verificando columnas antes de insertar: $e');
      }
    }
    
    try {
      if (kDebugMode) {
        print('💾 Intentando insertar video con ${dataMap.length} columnas');
      }
      await db.insert(
        'offline_videos',
        dataMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) {
        print('✅ Video insertado exitosamente');
      }
    } catch (e) {
      // Si falla por restricción NOT NULL en file_size, agregar el valor y reintentar
      if (e.toString().contains('NOT NULL constraint failed') && e.toString().contains('file_size')) {
        if (kDebugMode) {
          print('⚠️ Error detectado: file_size NOT NULL. Agregando valor y reintentando...');
        }
        dataMap['file_size'] = video.fileSizeBytes;
        try {
          await db.insert(
            'offline_videos',
            dataMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (kDebugMode) {
            print('✅ Inserción exitosa después de agregar file_size');
          }
          return; // Salir exitosamente
        } catch (retryError) {
          if (kDebugMode) {
            print('❌ Error al reintentar inserción: $retryError');
          }
          rethrow;
        }
      }
      // Si falla por falta de columna, intentar agregarla y reintentar
      else if (e.toString().contains('no column named')) {
        if (kDebugMode) {
          print('⚠️ Error detectado: columna faltante. Intentando corregir...');
        }
        await _ensureImageNameColumn(db);
        // Reintentar la inserción
        try {
          await db.insert(
            'offline_videos',
            dataMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (kDebugMode) {
            print('✅ Inserción exitosa después de corregir las columnas');
          }
        } catch (retryError) {
          if (kDebugMode) {
            print('❌ Error al reintentar inserción: $retryError');
          }
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Obtiene todos los videos offline
  Future<List<OfflineVideoModel>> getAllOfflineVideos() async {
    final db = await database;
    // 'order' es una palabra reservada en SQL, debe ir entre comillas
    final maps = await db.query('offline_videos', orderBy: '"order" ASC');
    return maps.map((map) => OfflineVideoModel.fromMap(map)).toList();
  }

  /// Obtiene un video offline por ID
  Future<OfflineVideoModel?> getOfflineVideoById(String videoId) async {
    final db = await database;
    final maps = await db.query(
      'offline_videos',
      where: 'video_id = ?',
      whereArgs: [videoId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return OfflineVideoModel.fromMap(maps.first);
  }

  /// Verifica si un video está descargado
  Future<bool> isVideoDownloaded(String videoId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM offline_videos WHERE video_id = ?',
      [videoId],
    );
    return (result.first['count'] as int) > 0;
  }

  /// Actualiza la fecha de último acceso (para LRU)
  Future<void> updateLastAccessed(String videoId) async {
    final db = await database;
    await db.update(
      'offline_videos',
      {'last_accessed_at': DateTime.now().toIso8601String()},
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
  }

  /// Elimina un video offline
  Future<void> deleteOfflineVideo(String videoId) async {
    final db = await database;
    await db.delete(
      'offline_videos',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
  }

  /// Obtiene el tamaño total de todos los videos descargados
  Future<int> getTotalDownloadedSize() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(file_size_bytes) as total FROM offline_videos',
    );
    return result.first['total'] as int? ?? 0;
  }

  /// Obtiene videos ordenados por último acceso (LRU)
  Future<List<OfflineVideoModel>> getVideosByLastAccessed({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'offline_videos',
      orderBy: 'last_accessed_at ASC',
      limit: limit,
    );
    return maps.map((map) => OfflineVideoModel.fromMap(map)).toList();
  }

  /// Elimina los videos menos usados hasta liberar espacio
  Future<int> freeSpace(int targetBytes) async {
    int freedBytes = 0;
    
    // Obtener videos ordenados por último acceso (LRU)
    final videosToDelete = await getVideosByLastAccessed(limit: 100);
    
    for (final video in videosToDelete) {
      if (freedBytes >= targetBytes) break;
      
      await deleteOfflineVideo(video.videoId);
      freedBytes += video.fileSizeBytes;
    }
    
    return freedBytes;
  }
}

