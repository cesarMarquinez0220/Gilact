import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sleep_record.dart';

/// Data source local para almacenar registros de sueño offline
class SleepOfflineLocalDataSource {
  static final SleepOfflineLocalDataSource _instance =
      SleepOfflineLocalDataSource._internal();
  factory SleepOfflineLocalDataSource() => _instance;
  SleepOfflineLocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sleep_records.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sleep_records(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            sleep_start_time INTEGER NOT NULL,
            sleep_end_time INTEGER NOT NULL,
            total_sleep_duration INTEGER NOT NULL,
            quality TEXT NOT NULL,
            notes TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            firestore_id TEXT,
            sync_status TEXT DEFAULT 'PENDING',
            last_sync_at INTEGER,
            created_at_local INTEGER NOT NULL
          )
        ''');

        // Índices
        await db.execute('CREATE INDEX idx_sync_status ON sleep_records(sync_status)');
        await db.execute('CREATE INDEX idx_firestore_id ON sleep_records(firestore_id)');
        await db.execute('CREATE INDEX idx_user_id ON sleep_records(user_id)');
        await db.execute('CREATE INDEX idx_sleep_start_time ON sleep_records(sleep_start_time)');
      },
    );
  }

  /// Guarda un registro de sueño localmente
  Future<void> saveRecord(SleepRecord record) async {
    try {
      final db = await database;
      final map = _recordToMap(record);
      map['created_at_local'] = DateTime.now().millisecondsSinceEpoch;
      map['sync_status'] = 'PENDING';
      map['firestore_id'] = null;
      map['last_sync_at'] = null;

      await db.insert(
        'sleep_records',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        print('✅ SleepOfflineLocalDataSource: Registro guardado localmente: ${record.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error guardando registro: $e');
      }
      rethrow;
    }
  }

  /// Obtiene todos los registros de sueño
  Future<List<SleepRecord>> getAllRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sleep_records',
        orderBy: 'sleep_start_time DESC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error obteniendo registros: $e');
      }
      return [];
    }
  }

  /// Obtiene registros para una fecha específica
  Future<List<SleepRecord>> getRecordsForDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startTimestamp = startOfDay.millisecondsSinceEpoch;
      final endTimestamp = endOfDay.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        'sleep_records',
        where: 'sleep_start_time >= ? AND sleep_start_time < ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'sleep_start_time ASC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error obteniendo registros para fecha: $e');
      }
      return [];
    }
  }

  /// Obtiene registros pendientes de sincronización
  Future<List<SleepRecord>> getPendingSyncRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sleep_records',
        where: 'sync_status = ?',
        whereArgs: ['PENDING'],
        orderBy: 'created_at_local ASC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error obteniendo registros pendientes: $e');
      }
      return [];
    }
  }

  /// Marca un registro como sincronizado
  Future<void> markAsSynced(String localId, String firestoreId) async {
    try {
      final db = await database;
      await db.update(
        'sleep_records',
        {
          'firestore_id': firestoreId,
          'sync_status': 'SYNCED',
          'last_sync_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error marcando como sincronizado: $e');
      }
    }
  }

  /// Actualiza el estado de sincronización
  Future<void> updateSyncStatus(String localId, String status, {String? firestoreId}) async {
    try {
      final db = await database;
      final updateData = {
        'sync_status': status,
        'last_sync_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (firestoreId != null) {
        updateData['firestore_id'] = firestoreId;
      }

      await db.update(
        'sleep_records',
        updateData,
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error actualizando estado: $e');
      }
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String id) async {
    try {
      final db = await database;
      await db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error eliminando registro: $e');
      }
      rethrow;
    }
  }

  /// Actualiza un registro
  Future<void> updateRecord(SleepRecord record) async {
    try {
      final db = await database;
      final map = _recordToMap(record);
      map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      // Si no tiene firestore_id, marcar como pendiente
      if (map['firestore_id'] == null) {
        map['sync_status'] = 'PENDING';
      }

      await db.update(
        'sleep_records',
        map,
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ SleepOfflineLocalDataSource: Error actualizando registro: $e');
      }
      rethrow;
    }
  }

  /// Convierte SleepRecord a Map
  Map<String, dynamic> _recordToMap(SleepRecord record) {
    return {
      'id': record.id,
      'user_id': record.userId,
      'sleep_start_time': record.sleepStartTime.millisecondsSinceEpoch,
      'sleep_end_time': record.sleepEndTime.millisecondsSinceEpoch,
      'total_sleep_duration': record.totalSleepDuration.inMinutes,
      'quality': record.quality.name,
      'notes': record.notes,
      'created_at': record.createdAt.millisecondsSinceEpoch,
      'updated_at': record.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convierte Map a SleepRecord
  SleepRecord _mapToRecord(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      sleepStartTime: DateTime.fromMillisecondsSinceEpoch(
        map['sleep_start_time'] as int,
      ),
      sleepEndTime: DateTime.fromMillisecondsSinceEpoch(
        map['sleep_end_time'] as int,
      ),
      totalSleepDuration: Duration(
        minutes: map['total_sleep_duration'] as int,
      ),
      quality: SleepQuality.values.firstWhere(
        (e) => e.name == map['quality'],
        orElse: () => SleepQuality.good,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}

