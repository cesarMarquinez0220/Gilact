import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/lactation_record.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

class LactationDatabase {
  static final LactationDatabase _instance = LactationDatabase._internal();
  factory LactationDatabase() => _instance;
  LactationDatabase._internal();

  final AppLogger _logger = getIt<AppLogger>();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'lactation.db');
    return await openDatabase(
      path,
      version: 4, // Incrementado para agregar tipo_registro e incluye_sueno
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lactation_records(
        id TEXT PRIMARY KEY,
        fecha_registro TEXT NOT NULL,
        duracion INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        notas TEXT,
        lado TEXT,
        volumen_extraccion INTEGER DEFAULT 0,
        unidad_volumen TEXT DEFAULT 'No',
        veces_biberon INTEGER DEFAULT 0,
        veces_pecho INTEGER DEFAULT 0,
        pecho_dado TEXT DEFAULT 'Ninguna',
        horas_sueno_bebe INTEGER DEFAULT 0,
        unidad_sueno TEXT DEFAULT 'No',
        timestamp INTEGER NOT NULL,
        tipo_registro TEXT DEFAULT 'completo',
        incluye_sueno INTEGER DEFAULT 0,
        firestore_id TEXT,
        sync_status TEXT DEFAULT 'PENDING',
        last_sync_at INTEGER,
        created_at_local INTEGER NOT NULL
      )
    ''');

    // Índices para mejorar búsquedas
    await db.execute(
      'CREATE INDEX idx_sync_status ON lactation_records(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_firestore_id ON lactation_records(firestore_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.d(
      'LactationDatabase: Iniciando migración de versión $oldVersion a $newVersion',
    );

    if (oldVersion < 3) {
      // Agregar campos de sincronización
      _logger.d('LactationDatabase: Agregando campos de sincronización (v3)');
      try {
        await db.execute(
          'ALTER TABLE lactation_records ADD COLUMN firestore_id TEXT',
        );
        await db.execute(
          'ALTER TABLE lactation_records ADD COLUMN sync_status TEXT DEFAULT \'PENDING\'',
        );
        await db.execute(
          'ALTER TABLE lactation_records ADD COLUMN last_sync_at INTEGER',
        );
        await db.execute(
          'ALTER TABLE lactation_records ADD COLUMN created_at_local INTEGER DEFAULT ${DateTime.now().millisecondsSinceEpoch}',
        );

        // Crear índices
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sync_status ON lactation_records(sync_status)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_firestore_id ON lactation_records(firestore_id)',
        );

        // Actualizar registros existentes: marcar como PENDING si no tienen firestore_id
        await db.execute('''
          UPDATE lactation_records 
          SET sync_status = 'PENDING', created_at_local = ${DateTime.now().millisecondsSinceEpoch}
          WHERE firestore_id IS NULL
        ''');
        _logger.d(
          'LactationDatabase: Campos de sincronización agregados correctamente',
        );
      } catch (e) {
        _logger.e('Error en migración de LactationDatabase (v3)', e);
        // Si falla, recrear la tabla
        await db.execute('DROP TABLE IF EXISTS lactation_records');
        await _onCreate(db, newVersion);
      }
    }

    if (oldVersion < 4) {
      // Agregar campos tipo_registro e incluye_sueno
      _logger.d(
        'LactationDatabase: Agregando tipo_registro e incluye_sueno (v4)',
      );
      try {
        // Verificar si las columnas ya existen antes de agregarlas
        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(lactation_records)',
        );
        final columnNames = tableInfo
            .map((row) => row['name'] as String)
            .toList();

        if (!columnNames.contains('tipo_registro')) {
          await db.execute(
            'ALTER TABLE lactation_records ADD COLUMN tipo_registro TEXT DEFAULT \'completo\'',
          );
          _logger.d('LactationDatabase: Columna tipo_registro agregada');
        } else {
          _logger.d('LactationDatabase: Columna tipo_registro ya existe');
        }

        if (!columnNames.contains('incluye_sueno')) {
          await db.execute(
            'ALTER TABLE lactation_records ADD COLUMN incluye_sueno INTEGER DEFAULT 0',
          );
          _logger.d('LactationDatabase: Columna incluye_sueno agregada');
        } else {
          _logger.d('LactationDatabase: Columna incluye_sueno ya existe');
        }

        // Actualizar registros existentes sin tipo_registro
        await db.execute('''
          UPDATE lactation_records 
          SET tipo_registro = 'completo', incluye_sueno = 0
          WHERE tipo_registro IS NULL OR incluye_sueno IS NULL
        ''');

        _logger.d('LactationDatabase: Migración a v4 completada correctamente');
      } catch (e) {
        _logger.e('Error agregando tipo_registro e incluye_sueno', e);
        // Si falla, intentar recrear la tabla
        try {
          await db.execute('DROP TABLE IF EXISTS lactation_records');
          await _onCreate(db, newVersion);
          _logger.d('LactationDatabase: Tabla recreada con nuevo esquema');
        } catch (recreateError) {
          _logger.e('Error recreando tabla', recreateError);
          rethrow;
        }
      }
    }

    _logger.d(
      'LactationDatabase: Migración completada de v$oldVersion a v$newVersion',
    );
  }

  Future<void> insertRecord(LactationRecord record) async {
    final db = await database;

    // Verificar si el registro ya existe para evitar duplicados
    final existingRecord = await db.query(
      'lactation_records',
      where: 'id = ?',
      whereArgs: [record.id],
      limit: 1,
    );

    if (existingRecord.isNotEmpty) {
      if (kDebugMode) {
        print(
          '⚠️ [LactationDatabase] Registro duplicado detectado, omitiendo inserción: ${record.id}',
        );
      }
      return; // Ya existe, no insertar de nuevo
    }

    final map = record.toMap();

    // Convertir tipos incompatibles con SQLite
    // DateTime -> int (millisecondsSinceEpoch)
    if (map['timestamp'] is DateTime) {
      map['timestamp'] = (map['timestamp'] as DateTime).millisecondsSinceEpoch;
    }

    // bool -> int (0 o 1)
    if (map['incluye_sueno'] is bool) {
      map['incluye_sueno'] = (map['incluye_sueno'] as bool) ? 1 : 0;
    }

    // Agregar campos de sincronización
    map['created_at_local'] = DateTime.now().millisecondsSinceEpoch;
    map['sync_status'] = 'PENDING';
    map['firestore_id'] = null;
    map['last_sync_at'] = null;

    // Agregar el ID del registro
    map['id'] = record.id;

    await db.insert(
      'lactation_records',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (kDebugMode) {
      print('✅ [LactationDatabase] Registro insertado: ${record.id}');
    }
  }

  /// Marca un registro como sincronizado
  Future<void> markAsSynced(String localId, String firestoreId) async {
    final db = await database;
    await db.update(
      'lactation_records',
      {
        'firestore_id': firestoreId,
        'sync_status': 'SYNCED',
        'last_sync_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Obtiene todos los registros pendientes de sincronización
  Future<List<LactationRecord>> getPendingSyncRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'sync_status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at_local ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  /// Actualiza el estado de sincronización de un registro
  Future<void> updateSyncStatus(
    String localId,
    String status, {
    String? firestoreId,
  }) async {
    final db = await database;
    final updateData = {
      'sync_status': status,
      'last_sync_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (firestoreId != null) {
      updateData['firestore_id'] = firestoreId;
    }

    await db.update(
      'lactation_records',
      updateData,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Obtiene todos los registros (para gamificación)
  Future<List<LactationRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      orderBy: 'timestamp DESC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<List<LactationRecord>> getRecordsForDate(DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'timestamp ASC',
    );

    // Convertir a registros y eliminar duplicados por ID
    final records = <String, LactationRecord>{};
    for (final map in maps) {
      final recordId = map['id'] as String;
      if (!records.containsKey(recordId)) {
        records[recordId] = LactationRecord.fromMap(map, recordId);
      }
    }

    if (kDebugMode && maps.length != records.length) {
      print(
        '⚠️ [LactationDatabase] Duplicados detectados: ${maps.length} registros, ${records.length} únicos',
      );
    }

    return records.values.toList();
  }

  Future<List<LactationRecord>> getRecordsForWeek(DateTime startOfWeek) async {
    final db = await database;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startString = startOfWeek.toIso8601String();
    final endString = endOfWeek.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro >= ? AND fecha_registro < ?',
      whereArgs: [startString, endString],
      orderBy: 'timestamp ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<List<LactationRecord>> getRecordsForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);
    final startString = startOfMonth.toIso8601String();
    final endString = endOfMonth.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro >= ? AND fecha_registro < ?',
      whereArgs: [startString, endString],
      orderBy: 'timestamp ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('lactation_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRecord(LactationRecord record) async {
    final db = await database;
    final map = record.toMap();

    // Convertir tipos incompatibles con SQLite
    // DateTime -> int (millisecondsSinceEpoch)
    if (map['timestamp'] is DateTime) {
      map['timestamp'] = (map['timestamp'] as DateTime).millisecondsSinceEpoch;
    }

    // bool -> int (0 o 1)
    if (map['incluye_sueno'] is bool) {
      map['incluye_sueno'] = (map['incluye_sueno'] as bool) ? 1 : 0;
    }

    await db.update(
      'lactation_records',
      map,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<LactationStats> getStats() async {
    final db = await database;

    // Total feeds
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lactation_records',
    );
    final totalFeeds = Sqflite.firstIntValue(totalResult) ?? 0;

    // Total duration
    final durationResult = await db.rawQuery(
      'SELECT SUM(duracion) as total FROM lactation_records',
    );
    final totalDurationMinutes = Sqflite.firstIntValue(durationResult) ?? 0;
    final totalDuration = Duration(minutes: totalDurationMinutes);

    // Average duration
    final averageDuration = totalFeeds > 0
        ? Duration(minutes: totalDurationMinutes ~/ totalFeeds)
        : Duration.zero;

    // Today's feeds
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lactation_records WHERE fecha_registro LIKE ?',
      ['$todayString%'],
    );
    final feedsToday = Sqflite.firstIntValue(todayResult) ?? 0;

    // Today's duration
    final todayDurationResult = await db.rawQuery(
      'SELECT SUM(duracion) as total FROM lactation_records WHERE fecha_registro LIKE ?',
      ['$todayString%'],
    );
    final todayDurationMinutes =
        Sqflite.firstIntValue(todayDurationResult) ?? 0;
    final durationToday = Duration(minutes: todayDurationMinutes);

    return LactationStats(
      totalFeeds: totalFeeds,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      feedsToday: feedsToday,
      durationToday: durationToday,
    );
  }
}
