import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'connectivity_service.dart';
import 'sync_queue_service.dart';
import 'conflict_resolution_service.dart';
import 'app_logger.dart';
import '../../features/lactation/data/datasources/lactation_database.dart';
import '../../features/lactation/data/datasources/sleep_offline_local_data_source.dart';
import '../../features/lactation/data/datasources/baby_weight_offline_local_data_source.dart';

/// Servicio centralizado para sincronización automática de datos offline
class OfflineSyncService {
  final AppLogger _logger;
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncQueueService _syncQueueService = SyncQueueService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LactationDatabase _lactationDatabase = LactationDatabase();
  final SleepOfflineLocalDataSource _sleepOfflineDataSource =
      SleepOfflineLocalDataSource();
  final BabyWeightOfflineLocalDataSource _babyWeightOfflineDataSource =
      BabyWeightOfflineLocalDataSource();
  late final ConflictResolutionService _conflictResolver;

  OfflineSyncService(this._logger) {
    _conflictResolver = GetIt.instance<ConflictResolutionService>();
  }

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;

  // Callbacks para notificaciones
  void Function(int)? _onSyncCompleted;
  void Function(int)? _onSyncFailed;

  /// Inicia el servicio de sincronización automática
  void startAutoSync({
    void Function(int)? onSyncCompleted,
    void Function(int)? onSyncFailed,
  }) {
    _onSyncCompleted = onSyncCompleted;
    _onSyncFailed = onSyncFailed;

    _logger.d('OfflineSyncService: Iniciando sincronización automática');

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && !_isSyncing) {
        _logger.d(
          'OfflineSyncService: Conexión detectada, iniciando sincronización',
        );
        processSyncQueue();
      }
    });

    // Sincronización periódica cada 5 minutos si hay conexión
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final isConnected = await _connectivityService.isConnected();
      if (isConnected && !_isSyncing) {
        _logger.d('OfflineSyncService: Sincronización periódica');
        processSyncQueue();
      }
    });

    // Sincronización inicial si hay conexión
    _connectivityService.isConnected().then((isConnected) {
      if (isConnected && !_isSyncing) {
        _logger.d('OfflineSyncService: Sincronización inicial');
        processSyncQueue();
      }
    });
  }

  /// Detiene el servicio de sincronización
  void stopAutoSync() {
    _logger.d('OfflineSyncService: Deteniendo sincronización automática');
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _connectivitySubscription = null;
    _periodicSyncTimer = null;
  }

  /// Procesa la cola de sincronización
  Future<void> processSyncQueue() async {
    if (_isSyncing) {
      _logger.d('OfflineSyncService: Sincronización ya en progreso');
      return;
    }

    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      _logger.w('OfflineSyncService: Sin conexión, no se puede sincronizar');
      return;
    }

    _isSyncing = true;

    try {
      // Obtener operaciones pendientes
      final pendingOperations = await _syncQueueService.getPendingOperations();

      if (pendingOperations.isEmpty) {
        _logger.d('OfflineSyncService: No hay operaciones pendientes');
        _isSyncing = false;
        return;
      }

      _logger.d(
        'OfflineSyncService: Procesando ${pendingOperations.length} operaciones pendientes',
      );

      int successCount = 0;
      int failedCount = 0;

      // Procesar cada operación
      for (final operation in pendingOperations) {
        try {
          // Marcar como sincronizando
          await _syncQueueService.updateOperationStatus(
            operation.id,
            SyncStatus.syncing,
          );

          // DETECTAR CONFLICTOS antes de sincronizar
          ConflictInfo? conflict;
          if (operation.operationType == SyncOperationType.update &&
              operation.documentId != null) {
            final userDocId = await _getUserDocumentId();
            if (userDocId != null) {
              conflict = await _conflictResolver.detectConflict(
                localId: operation.localId,
                firestoreId: operation.documentId,
                collectionPath: operation.collectionPath,
                localData: operation.data,
                localLastModified: operation.createdAt,
                firestore: _firestore,
                userDocId: userDocId,
              );
            }
          }

          // Si hay conflicto, resolverlo
          Map<String, dynamic> dataToSync = operation.data;
          if (conflict != null) {
            _logger.w(
              'OfflineSyncService: Conflicto detectado, resolviendo...',
            );
            dataToSync = await _conflictResolver.resolveConflict(conflict);
          }

          // Procesar según el tipo de operación y colección
          bool success = false;
          String? documentId;

          if (operation.collectionPath == 'lactancia') {
            final result = await _syncLactationRecord(
              operation,
              resolvedData: dataToSync,
            );
            success = result['success'] as bool;
            documentId = result['documentId'] as String?;
          } else if (operation.collectionPath == 'sueno_diario') {
            final result = await _syncSleepRecord(
              operation,
              resolvedData: dataToSync,
            );
            success = result['success'] as bool;
            documentId = result['documentId'] as String?;
          } else if (operation.collectionPath == 'peso') {
            final result = await _syncWeightRecord(
              operation,
              resolvedData: dataToSync,
            );
            success = result['success'] as bool;
            documentId = result['documentId'] as String?;
          }

          if (success && documentId != null) {
            // Marcar como completado
            await _syncQueueService.updateOperationStatus(
              operation.id,
              SyncStatus.completed,
              documentId: documentId,
            );

            // Actualizar registro local
            if (operation.collectionPath == 'lactancia') {
              await _lactationDatabase.markAsSynced(
                operation.localId,
                documentId,
              );
            } else if (operation.collectionPath == 'sueno_diario') {
              await _sleepOfflineDataSource.markAsSynced(
                operation.localId,
                documentId,
              );
            } else if (operation.collectionPath == 'peso') {
              await _babyWeightOfflineDataSource.markAsSynced(
                operation.localId,
                documentId,
              );
            }

            // Eliminar de la cola después de un delay
            Future.delayed(const Duration(seconds: 1), () {
              _syncQueueService.removeCompletedOperation(operation.id);
            });

            successCount++;
            _logger.success(
              'OfflineSyncService: Operación ${operation.id} sincronizada exitosamente',
            );
          } else {
            throw Exception('Error sincronizando operación');
          }
        } catch (e, stackTrace) {
          failedCount++;
          _logger.e(
            'OfflineSyncService: Error sincronizando operación ${operation.id}',
            e,
            stackTrace,
          );

          // Verificar si se puede reintentar
          if (_syncQueueService.canRetry(operation)) {
            await _syncQueueService.updateOperationStatus(
              operation.id,
              SyncStatus.failed,
              errorMessage: e.toString(),
            );
          } else {
            // Máximo de reintentos alcanzado
            await _syncQueueService.updateOperationStatus(
              operation.id,
              SyncStatus.failed,
              errorMessage: 'Máximo de reintentos alcanzado: $e',
            );
            _logger.w(
              'OfflineSyncService: Operación ${operation.id} alcanzó máximo de reintentos',
            );
          }
        }
      }

      // Notificar resultados
      if (successCount > 0) {
        _onSyncCompleted?.call(successCount);
        _logger.success(
          'OfflineSyncService: $successCount operaciones sincronizadas exitosamente',
        );
      }

      if (failedCount > 0) {
        _onSyncFailed?.call(failedCount);
        _logger.w('OfflineSyncService: $failedCount operaciones fallaron');
      }

      _logger.success('OfflineSyncService: Sincronización completada');
    } catch (e, stackTrace) {
      _logger.e(
        'OfflineSyncService: Error en proceso de sincronización',
        e,
        stackTrace,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincroniza un registro de lactancia
  Future<Map<String, dynamic>> _syncLactationRecord(
    SyncOperation operation, {
    Map<String, dynamic>? resolvedData,
  }) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado');
      }

      final collection = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia');

      String? documentId;
      final dataToUse = resolvedData ?? operation.data;

      if (operation.operationType == SyncOperationType.create) {
        final docRef = await collection.add(dataToUse);
        documentId = docRef.id;
        return {'success': true, 'documentId': documentId};
      } else if (operation.operationType == SyncOperationType.update) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).update(dataToUse);
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para actualización');
        }
      } else if (operation.operationType == SyncOperationType.delete) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).delete();
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para eliminación');
        }
      }

      return {'success': false, 'documentId': null};
    } catch (e, stackTrace) {
      _logger.e(
        'OfflineSyncService: Error sincronizando registro de lactancia',
        e,
        stackTrace,
      );
      return {'success': false, 'documentId': null, 'error': e.toString()};
    }
  }

  /// Sincroniza un registro de sueño
  Future<Map<String, dynamic>> _syncSleepRecord(
    SyncOperation operation, {
    Map<String, dynamic>? resolvedData,
  }) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado');
      }

      final collection = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('sueno_diario');

      String? documentId;
      final dataToUse = resolvedData ?? operation.data;

      // Convertir datos serializados de vuelta a formato Firestore
      final firestoreData = _convertToFirestoreFormat(dataToUse);

      if (operation.operationType == SyncOperationType.create) {
        final docRef = await collection.add(firestoreData);
        documentId = docRef.id;
        return {'success': true, 'documentId': documentId};
      } else if (operation.operationType == SyncOperationType.update) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).update(firestoreData);
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para actualización');
        }
      } else if (operation.operationType == SyncOperationType.delete) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).delete();
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para eliminación');
        }
      }

      return {'success': false, 'documentId': null};
    } catch (e, stackTrace) {
      _logger.e(
        'OfflineSyncService: Error sincronizando registro de sueño',
        e,
        stackTrace,
      );
      return {'success': false, 'documentId': null, 'error': e.toString()};
    }
  }

  /// Sincroniza un registro de peso del bebé
  Future<Map<String, dynamic>> _syncWeightRecord(
    SyncOperation operation, {
    Map<String, dynamic>? resolvedData,
  }) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado');
      }

      final collection = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('peso');

      String? documentId;
      final dataToUse = resolvedData ?? operation.data;

      // Convertir datos serializados de vuelta a formato Firestore
      final firestoreData = _convertToFirestoreFormat(dataToUse);

      if (operation.operationType == SyncOperationType.create) {
        final docRef = await collection.add(firestoreData);
        documentId = docRef.id;
        return {'success': true, 'documentId': documentId};
      } else if (operation.operationType == SyncOperationType.update) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).update(firestoreData);
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para actualización');
        }
      } else if (operation.operationType == SyncOperationType.delete) {
        if (operation.documentId != null) {
          await collection.doc(operation.documentId).delete();
          return {'success': true, 'documentId': operation.documentId};
        } else {
          throw Exception('documentId requerido para eliminación');
        }
      }

      return {'success': false, 'documentId': null};
    } catch (e, stackTrace) {
      _logger.e(
        'OfflineSyncService: Error sincronizando registro de peso',
        e,
        stackTrace,
      );
      return {'success': false, 'documentId': null, 'error': e.toString()};
    }
  }

  /// Convierte datos serializados (String/int) de vuelta a formato Firestore (Timestamp)
  Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Convertir campos de fecha conocidos
      if (key == 'creado_en' || key == 'created_at' || key == 'updated_at') {
        if (value is String) {
          // Si es String ISO8601, convertir a Timestamp
          converted[key] = Timestamp.fromDate(DateTime.parse(value));
        } else if (value is int) {
          // Si es int (millisecondsSinceEpoch), convertir a Timestamp
          converted[key] = Timestamp.fromMillisecondsSinceEpoch(value);
        } else {
          converted[key] = value;
        }
      } else if (key == 'timestamp') {
        // Campo timestamp: convertir int a Timestamp
        if (value is int) {
          converted[key] = Timestamp.fromMillisecondsSinceEpoch(value);
        } else {
          converted[key] = value;
        }
      } else {
        // Otros campos se mantienen igual
        converted[key] = value;
      }
    }

    return converted;
  }

  /// Obtiene el ID del documento del usuario en Firestore
  Future<String?> _getUserDocumentId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // PRIORIDAD 1: Buscar por email
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          return userQuery.docs.first.id;
        }
      }

      // PRIORIDAD 2: Intentar con UID
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return user.uid;
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e(
        'OfflineSyncService: Error obteniendo ID del usuario',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Obtiene el conteo de operaciones pendientes
  Future<int> getPendingOperationsCount() async {
    return await _syncQueueService.getPendingOperationsCount();
  }

  /// Fuerza una sincronización manual
  Future<void> forceSync() async {
    _logger.d('OfflineSyncService: Sincronización forzada');
    await processSyncQueue();
  }
}
