import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/baby_weight_record.dart';

/// Data source local para almacenar registros de peso del bebé offline
class BabyWeightOfflineLocalDataSource {
  static final BabyWeightOfflineLocalDataSource _instance =
      BabyWeightOfflineLocalDataSource._internal();
  factory BabyWeightOfflineLocalDataSource() => _instance;
  BabyWeightOfflineLocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'baby_weight_records.db');

    return await openDatabase(
      path,
      version: 2, // Incrementado para agregar la columna unit
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE baby_weight_records(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            weight REAL NOT NULL,
            unit TEXT DEFAULT 'kg',
            recorded_at INTEGER NOT NULL,
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
        await db.execute(
          'CREATE INDEX idx_sync_status ON baby_weight_records(sync_status)',
        );
        await db.execute(
          'CREATE INDEX idx_firestore_id ON baby_weight_records(firestore_id)',
        );
        await db.execute(
          'CREATE INDEX idx_user_id ON baby_weight_records(user_id)',
        );
        await db.execute(
          'CREATE INDEX idx_recorded_at ON baby_weight_records(recorded_at)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregar columna unit si no existe
          try {
            await db.execute(
              "ALTER TABLE baby_weight_records ADD COLUMN unit TEXT DEFAULT 'kg'",
            );
            if (kDebugMode) {
              print(
                '✅ BabyWeightOfflineLocalDataSource: Columna unit agregada a la tabla',
              );
            }
          } catch (e) {
            // Si la columna ya existe, ignorar el error
            if (kDebugMode) {
              print(
                '⚠️ BabyWeightOfflineLocalDataSource: Error agregando columna unit (puede que ya exista): $e',
              );
            }
          }
        }
      },
    );
  }

  /// Guarda un registro de peso localmente
  Future<void> saveRecord(BabyWeightRecord record) async {
    try {
      final db = await database;
      final map = _recordToMap(record);
      map['created_at_local'] = DateTime.now().millisecondsSinceEpoch;
      map['sync_status'] = 'PENDING';
      map['firestore_id'] = null;
      map['last_sync_at'] = null;

      await db.insert(
        'baby_weight_records',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        print(
          '✅ BabyWeightOfflineLocalDataSource: Registro guardado localmente: ${record.id}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error guardando registro: $e',
        );
      }
      rethrow;
    }
  }

  /// Obtiene todos los registros de peso
  Future<List<BabyWeightRecord>> getAllRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'baby_weight_records',
        orderBy: 'recorded_at DESC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error obteniendo registros: $e',
        );
      }
      return [];
    }
  }

  /// Obtiene registros para una fecha específica
  Future<List<BabyWeightRecord>> getRecordsForDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startTimestamp = startOfDay.millisecondsSinceEpoch;
      final endTimestamp = endOfDay.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        'baby_weight_records',
        where: 'recorded_at >= ? AND recorded_at < ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'recorded_at ASC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error obteniendo registros para fecha: $e',
        );
      }
      return [];
    }
  }

  /// Obtiene registros pendientes de sincronización
  Future<List<BabyWeightRecord>> getPendingSyncRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'baby_weight_records',
        where: 'sync_status = ?',
        whereArgs: ['PENDING'],
        orderBy: 'created_at_local ASC',
      );

      return maps.map((map) => _mapToRecord(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error obteniendo registros pendientes: $e',
        );
      }
      return [];
    }
  }

  /// Marca un registro como sincronizado
  Future<void> markAsSynced(String localId, String firestoreId) async {
    try {
      final db = await database;
      await db.update(
        'baby_weight_records',
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
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error marcando como sincronizado: $e',
        );
      }
    }
  }

  /// Actualiza el estado de sincronización
  Future<void> updateSyncStatus(
    String localId,
    String status, {
    String? firestoreId,
  }) async {
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
        'baby_weight_records',
        updateData,
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error actualizando estado: $e',
        );
      }
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String id) async {
    try {
      final db = await database;
      await db.delete('baby_weight_records', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error eliminando registro: $e',
        );
      }
      rethrow;
    }
  }

  /// Actualiza un registro
  Future<void> updateRecord(BabyWeightRecord record) async {
    try {
      final db = await database;
      final map = _recordToMap(record);
      map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      // Si no tiene firestore_id, marcar como pendiente
      if (map['firestore_id'] == null) {
        map['sync_status'] = 'PENDING';
      }

      await db.update(
        'baby_weight_records',
        map,
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ BabyWeightOfflineLocalDataSource: Error actualizando registro: $e',
        );
      }
      rethrow;
    }
  }

  /// Convierte BabyWeightRecord a Map
  Map<String, dynamic> _recordToMap(BabyWeightRecord record) {
    return {
      'id': record.id,
      'user_id': record.userId,
      'weight': record.weight,
      'unit': 'kg', // Unidad de peso
      'recorded_at': record.recordedAt.millisecondsSinceEpoch,
      'notes': record.notes,
      'created_at': record.createdAt.millisecondsSinceEpoch,
      'updated_at': record.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convierte Map a BabyWeightRecord
  BabyWeightRecord _mapToRecord(Map<String, dynamic> map) {
    return BabyWeightRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      weight: (map['weight'] as num).toDouble(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        map['recorded_at'] as int,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
