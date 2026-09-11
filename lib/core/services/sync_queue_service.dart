import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'app_logger.dart';
import '../di/injection.dart';

/// Tipo de operación de sincronización
enum SyncOperationType { create, update, delete }

/// Estado de una operación de sincronización
enum SyncStatus { pending, syncing, completed, failed }

/// Modelo de una operación en la cola de sincronización
class SyncOperation {
  final String id;
  final SyncOperationType operationType;
  final String collectionPath; // ej: "lactancia", "sueño"
  final String? documentId; // ID del documento en Firestore (si existe)
  final String localId; // ID local del registro
  final Map<String, dynamic> data;
  final SyncStatus status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;

  SyncOperation({
    required this.id,
    required this.operationType,
    required this.collectionPath,
    this.documentId,
    required this.localId,
    required this.data,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation_type': operationType.name,
      'collection_path': collectionPath,
      'document_id': documentId,
      'local_id': localId,
      'data': jsonEncode(data),
      'status': status.name,
      'retry_count': retryCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_attempt_at': lastAttemptAt?.millisecondsSinceEpoch,
      'error_message': errorMessage,
    };
  }

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      operationType: SyncOperationType.values.firstWhere(
        (e) => e.name == map['operation_type'],
        orElse: () => SyncOperationType.create,
      ),
      collectionPath: map['collection_path'] as String,
      documentId: map['document_id'] as String?,
      localId: map['local_id'] as String,
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: map['retry_count'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastAttemptAt: map['last_attempt_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_attempt_at'] as int)
          : null,
      errorMessage: map['error_message'] as String?,
    );
  }

  SyncOperation copyWith({
    String? id,
    SyncOperationType? operationType,
    String? collectionPath,
    String? documentId,
    String? localId,
    Map<String, dynamic>? data,
    SyncStatus? status,
    int? retryCount,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      collectionPath: collectionPath ?? this.collectionPath,
      documentId: documentId ?? this.documentId,
      localId: localId ?? this.localId,
      data: data ?? this.data,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Servicio para gestionar la cola de sincronización
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  final AppLogger _logger = getIt<AppLogger>();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  static Database? _database;
  static const int _maxRetries = 5;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sync_queue.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sync_queue(
            id TEXT PRIMARY KEY,
            operation_type TEXT NOT NULL,
            collection_path TEXT NOT NULL,
            document_id TEXT,
            local_id TEXT NOT NULL,
            data TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            retry_count INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            last_attempt_at INTEGER,
            error_message TEXT
          )
        ''');

        // Índices para mejorar búsquedas
        await db.execute('CREATE INDEX idx_status ON sync_queue(status)');
        await db.execute(
          'CREATE INDEX idx_collection_path ON sync_queue(collection_path)',
        );
        await db.execute('CREATE INDEX idx_local_id ON sync_queue(local_id)');
      },
    );
  }

  /// Agrega una operación a la cola de sincronización
  Future<void> addOperation(SyncOperation operation) async {
    try {
      final db = await database;
      await db.insert(
        'sync_queue',
        operation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.success(
        'SyncQueueService: Operación agregada - ${operation.operationType.name} en ${operation.collectionPath}',
      );
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error agregando operación', e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene todas las operaciones pendientes
  Future<List<SyncOperation>> getPendingOperations() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sync_queue',
        where: 'status = ?',
        whereArgs: [SyncStatus.pending.name],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => SyncOperation.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.e(
        'SyncQueueService: Error obteniendo operaciones pendientes',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Obtiene el conteo de operaciones pendientes
  Future<int> getPendingOperationsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM sync_queue WHERE status = ?',
        [SyncStatus.pending.name],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error obteniendo conteo', e, stackTrace);
      return 0;
    }
  }

  /// Actualiza el estado de una operación
  Future<void> updateOperationStatus(
    String operationId,
    SyncStatus status, {
    String? errorMessage,
    String? documentId,
  }) async {
    try {
      final db = await database;
      final updateData = <String, dynamic>{
        'status': status.name,
        'last_attempt_at': DateTime.now().millisecondsSinceEpoch,
      };

      if (errorMessage != null) {
        updateData['error_message'] = errorMessage;
      }

      if (documentId != null) {
        updateData['document_id'] = documentId;
      }

      if (status == SyncStatus.syncing || status == SyncStatus.failed) {
        // Incrementar contador de reintentos
        final operation = await getOperationById(operationId);
        if (operation != null) {
          updateData['retry_count'] = operation.retryCount + 1;
        }
      }

      await db.update(
        'sync_queue',
        updateData,
        where: 'id = ?',
        whereArgs: [operationId],
      );
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error actualizando estado', e, stackTrace);
    }
  }

  /// Obtiene una operación por ID
  Future<SyncOperation?> getOperationById(String operationId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [operationId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return SyncOperation.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error obteniendo operación', e, stackTrace);
      return null;
    }
  }

  /// Elimina una operación completada
  Future<void> removeCompletedOperation(String operationId) async {
    try {
      final db = await database;
      await db.delete('sync_queue', where: 'id = ?', whereArgs: [operationId]);
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error eliminando operación', e, stackTrace);
    }
  }

  /// Elimina todas las operaciones completadas (limpieza)
  Future<void> removeCompletedOperations() async {
    try {
      final db = await database;
      await db.delete(
        'sync_queue',
        where: 'status = ?',
        whereArgs: [SyncStatus.completed.name],
      );
    } catch (e, stackTrace) {
      _logger.e('SyncQueueService: Error limpiando operaciones', e, stackTrace);
    }
  }

  /// Verifica si una operación puede reintentarse
  bool canRetry(SyncOperation operation) {
    return operation.retryCount < _maxRetries;
  }

  /// Obtiene operaciones fallidas que pueden reintentarse
  Future<List<SyncOperation>> getRetryableFailedOperations() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sync_queue',
        where: 'status = ? AND retry_count < ?',
        whereArgs: [SyncStatus.failed.name, _maxRetries],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => SyncOperation.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.e(
        'SyncQueueService: Error obteniendo operaciones fallidas',
        e,
        stackTrace,
      );
      return [];
    }
  }
}
