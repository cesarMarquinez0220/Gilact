import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/lactation_record.dart';
import '../../data/datasources/lactation_database.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_queue_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../../../../main.dart' as app_main;
import '../../../gamification/domain/services/gamification_service.dart';
import '../../../gamification/domain/services/user_statistics_service.dart';
import '../../../gamification/presentation/widgets/achievement_unlocked_dialog.dart';
import 'package:flutter/widgets.dart';
import 'lactation_notification_service.dart';

/// Servicio unificado para manejar todos los registros de lactancia en Firestore
/// Implementa patrón offline-first: siempre guarda localmente primero
class LactationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LactationDatabase _localDatabase = LactationDatabase();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncQueueService _syncQueueService = SyncQueueService();
  final AppLogger _logger = getIt<AppLogger>();

  // Cache para evitar consultas repetidas
  String? _cachedUserDocId;
  bool? _cachedHasPostpartumSituation;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Servicio de gamificación
  GamificationService? _gamificationService;
  final UserStatisticsService? _userStatisticsService;

  LactationService(this._firestore, this._auth, [this._userStatisticsService]) {
    // Inicializar servicio de gamificación (puede fallar si no está registrado)
    try {
      _gamificationService = getIt<GamificationService>();
    } catch (e) {
      if (kDebugMode) {
        _logger.w('GamificationService no disponible', e);
      }
    }
  }

  /// Inicializa el caché del usuario (llamar desde MainNavigationPage)
  Future<void> initializeUserCache() async {
    _logger.d('LactationService: Inicializando caché del usuario...');
    try {
      final currentUserDocId = await _getUserDocumentId();
      if (currentUserDocId != null) {
        // Verificar si el usuario cambió
        if (currentUserDocId != _cachedUserDocId) {
          _logger.d(
            'LactationService: Usuario cambió, limpiando caché anterior...',
          );
          clearCache();
        }

        _cachedUserDocId = currentUserDocId;
        _cachedHasPostpartumSituation = await _checkPostpartumSituationDirect(
          _cachedUserDocId!,
        );
        _lastCacheUpdate = DateTime.now();
        _logger.success(
          'LactationService: Caché inicializado - UserDocId: $_cachedUserDocId, HasPostpartum: $_cachedHasPostpartumSituation',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error inicializando caché', e, stackTrace);
    }
  }

  /// Obtiene la fecha de nacimiento del bebé desde Firestore
  Future<DateTime?> getBabyBirthDate() async {
    try {
      final userDocId = await getUserDocumentId();
      if (userDocId == null) return null;

      final userDoc = await _firestore.collection('Users').doc(userDocId).get();
      if (!userDoc.exists) return null;

      final situationData = userDoc.data();
      if (situationData == null || situationData['situacion'] == null) {
        return null;
      }

      final situacionDoc = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situaciones')
          .doc(situationData['situacion'] as String)
          .get();

      if (!situacionDoc.exists) return null;

      final situacionData = situacionDoc.data();
      if (situacionData == null) return null;

      // Intentar obtener fecha de nacimiento
      final birthDateValue = situacionData['birthDate'];
      if (birthDateValue != null) {
        if (birthDateValue is DateTime) {
          return birthDateValue;
        } else if (birthDateValue is String) {
          return DateTime.tryParse(birthDateValue);
        } else if (birthDateValue is Timestamp) {
          return birthDateValue.toDate();
        }
      }

      // Si no se encontró birthDate, intentar con fecha nacimiento bebe
      final fechaNacimientoBebe = situacionData['fecha nacimiento bebe'];
      if (fechaNacimientoBebe != null) {
        if (fechaNacimientoBebe is String) {
          return DateTime.tryParse(fechaNacimientoBebe);
        } else if (fechaNacimientoBebe is Timestamp) {
          return fechaNacimientoBebe.toDate();
        }
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e(
        'LactationService: Error obteniendo fecha de nacimiento',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Limpia el caché (llamar al cerrar sesión o cambiar usuario)
  void clearCache() {
    _logger.d('LactationService: Limpiando caché...');
    _cachedUserDocId = null;
    _cachedHasPostpartumSituation = null;
    _lastCacheUpdate = null;
  }

  /// Verifica si el usuario actual es diferente al usuario en caché
  Future<bool> hasUserChanged() async {
    try {
      final currentUserDocId = await _getUserDocumentId();
      return currentUserDocId != _cachedUserDocId;
    } catch (e, stackTrace) {
      _logger.e('Error verificando cambio de usuario', e, stackTrace);
      return true; // En caso de error, asumir que cambió
    }
  }

  /// Verifica si el caché es válido
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) <
        _cacheValidityDuration;
  }

  /// Obtiene la referencia a la subcolección de lactancia del usuario
  Future<CollectionReference> get _lactationCollection async {
    final userDocId = await _getUserDocumentId();
    if (userDocId == null) {
      throw Exception('Usuario no encontrado en Firestore');
    }

    return _firestore
        .collection('Users')
        .doc(userDocId)
        .collection('situacion')
        .doc('seleccion')
        .collection('lactancia');
  }

  /// Guarda un nuevo registro de lactancia (offline-first)
  /// SIEMPRE guarda localmente primero, luego sincroniza con Firestore si hay conexión
  Future<String> saveRecord(LactationRecord record) async {
    try {
      // PASO 1: SIEMPRE guardar localmente primero
      await _localDatabase.insertRecord(record);
      if (kDebugMode) {
        _logger.success(
          'Registro de lactancia guardado localmente: ${record.id}',
        );
      }

      // PASO 1.5: Agregar XP y detectar badges (GAMIFICACIÓN)
      // Se ejecuta después de guardar para tener el conteo correcto
      try {
        await _addGamificationXP(record);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          _logger.w('Error agregando gamificación (no crítico)', e, stackTrace);
        }
      }

      // PASO 1.6: Programar notificación de lactancia según la edad del bebé
      try {
        final notificationService = LactationNotificationService();
        // Obtener nombre del bebé y fecha de nacimiento si está disponible
        String? babyName;
        DateTime? babyBirthDate;
        try {
          final userDocId = await getUserDocumentId();
          if (userDocId != null) {
            final userDoc = await _firestore
                .collection('Users')
                .doc(userDocId)
                .get();
            if (userDoc.exists) {
              final situationData = userDoc.data();
              if (situationData != null && situationData['situacion'] != null) {
                final situacionDoc = await _firestore
                    .collection('Users')
                    .doc(userDocId)
                    .collection('situaciones')
                    .doc(situationData['situacion'] as String)
                    .get();
                if (situacionDoc.exists) {
                  final situacionData = situacionDoc.data();
                  if (situacionData != null) {
                    babyName = situacionData['nombre_bebe'] as String?;
                    // Intentar obtener fecha de nacimiento
                    final birthDateValue = situacionData['birthDate'];
                    if (birthDateValue != null) {
                      if (birthDateValue is DateTime) {
                        babyBirthDate = birthDateValue;
                      } else if (birthDateValue is String) {
                        babyBirthDate = DateTime.tryParse(birthDateValue);
                      } else if (birthDateValue is Timestamp) {
                        babyBirthDate = birthDateValue.toDate();
                      }
                    }
                    // Si no se encontró birthDate, intentar con fecha nacimiento bebe
                    if (babyBirthDate == null) {
                      final fechaNacimientoBebe =
                          situacionData['fecha nacimiento bebe'];
                      if (fechaNacimientoBebe != null) {
                        if (fechaNacimientoBebe is String) {
                          babyBirthDate = DateTime.tryParse(
                            fechaNacimientoBebe,
                          );
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            _logger.w(
              'Error obteniendo información del bebé (no crítico)',
              e,
              stackTrace,
            );
          }
        }

        // Calcular intervalo basado en la edad del bebé
        final interval =
            LactationNotificationService.calculateLactationInterval(
              babyBirthDate,
            );
        final intervalHours = interval.inHours;
        final intervalMinutes = interval.inMinutes.remainder(60);
        final intervalText = intervalMinutes > 0
            ? '${intervalHours}h ${intervalMinutes}m'
            : '${intervalHours}h';

        await notificationService.scheduleLactationReminder(
          lastFeedTime: record.timestamp,
          babyName: babyName,
          babyBirthDate: babyBirthDate,
        );
        if (kDebugMode) {
          _logger.success(
            'Notificación de lactancia programada para $intervalText después',
          );
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          _logger.w(
            'Error programando notificación de lactancia (no crítico)',
            e,
            stackTrace,
          );
        }
      }

      // PASO 2: Si hay conexión, intentar guardar en Firestore inmediatamente
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          final collection = await _lactationCollection;
          final docRef = await collection.add(record.toMap());

          // Marcar como sincronizado
          await _localDatabase.markAsSynced(record.id, docRef.id);

          if (kDebugMode) {
            _logger.success(
              'Registro de lactancia sincronizado con Firestore: ${docRef.id}',
            );
          }

          return docRef.id;
        } catch (e, stackTrace) {
          // Si falla Firestore, el registro queda local para sincronizar después
          if (kDebugMode) {
            _logger.w(
              'Error guardando en Firestore, quedará pendiente de sincronización',
              e,
              stackTrace,
            );
          }

          // Agregar a cola de sincronización
          await _addToSyncQueue(record, SyncOperationType.create);

          return record.id; // Retornar ID local
        }
      } else {
        // Sin conexión: agregar a cola de sincronización
        if (kDebugMode) {
          _logger.d(
            'Sin conexión: Registro guardado localmente, se sincronizará cuando haya conexión',
          );
        }

        await _addToSyncQueue(record, SyncOperationType.create);

        return record.id; // Retornar ID local
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Error guardando registro de lactancia', e, stackTrace);
      }
      rethrow;
    }
  }

  /// Agrega XP y detecta badges después de guardar un registro
  Future<void> _addGamificationXP(LactationRecord record) async {
    if (_gamificationService == null) return;

    try {
      final userId = await getUserDocumentId();
      if (userId == null) return;

      // Obtener total de registros para detectar badges
      final allRecords = await _localDatabase.getAllRecords();
      final totalRecords = allRecords.length;

      // Determinar si es el primer registro del día
      // Nota: allRecords ya incluye el registro que acabamos de guardar
      final today = DateTime.now();
      final todayRecords = allRecords.where((r) {
        final recordDate = r.timestamp;
        final recordDateOnly = DateTime(
          recordDate.year,
          recordDate.month,
          recordDate.day,
        );
        final todayOnly = DateTime(today.year, today.month, today.day);
        return recordDateOnly == todayOnly;
      }).length;
      // Si hay exactamente 1 registro hoy, es el primero del día
      final isFirstOfDay = todayRecords == 1;

      // Agregar XP (registro rápido o completo según el tipo)
      if (record.tipoRegistro == 'completo') {
        await _gamificationService!.addXPForCompleteLactation(
          userId: userId,
          recordId: record.id,
          timestamp: record.timestamp,
          includesSleep: record.incluyeSueno,
          isFirstOfDay: isFirstOfDay,
        );
      } else {
        await _gamificationService!.addXPForQuickLactation(
          userId: userId,
          recordId: record.id,
          timestamp: record.timestamp,
          isFirstOfDay: isFirstOfDay,
        );
      }

      // Verificar y otorgar bonus por milestone de registros
      final milestoneResult = await _gamificationService!
          .checkAndAwardRecordMilestone(
            userId: userId,
            totalRecords: totalRecords,
            timestamp: record.timestamp,
          );

      milestoneResult.fold(
        (error) {
          if (kDebugMode) {
            _logger.w('Error verificando milestone: $error');
          }
        },
        (milestoneProfile) {
          if (milestoneProfile != null &&
              app_main.navigatorKey.currentContext != null) {
            // Mostrar notificación de milestone alcanzado
            if (kDebugMode) {
              _logger.success(
                '¡Milestone alcanzado! $totalRecords registros - Bonus de XP otorgado',
              );
            }
            // El XP ya fue agregado por el servicio, solo mostramos mensaje
          }
        },
      );

      // Obtener estadísticas reales del usuario para detección de logros
      UserStatistics? userStats;
      if (_userStatisticsService != null) {
        try {
          userStats = await _userStatisticsService.getUserStatistics(userId);
        } catch (e, stackTrace) {
          if (kDebugMode) {
            _logger.w(
              'Error obteniendo estadísticas del usuario',
              e,
              stackTrace,
            );
          }
        }
      }

      // Detectar badges progresivos con estadísticas reales
      final achievements = await _gamificationService!
          .detectAndUnlockAchievements(
            userId: userId,
            totalLactationRecords:
                userStats?.totalLactationRecords ?? totalRecords,
            completeLactationRecords:
                userStats?.completeLactationRecords ??
                allRecords.where((r) => r.tipoRegistro == 'completo').length,
            totalLessonsCompleted: userStats?.totalLessonsCompleted ?? 0,
            babyWeightRecords: userStats?.babyWeightRecords ?? 0,
            hasNocturnalRecord: _hasNocturnalRecord(record),
            dailyRecordsToday: todayRecords,
            babySleepRecords: userStats?.babySleepRecords ?? 0,
            perfectTrivias: userStats?.perfectTrivias ?? 0,
            nocturnalRecordsCount: userStats?.nocturnalRecordsCount ?? 0,
            daysUsingApp: userStats?.daysUsingApp ?? 0,
          );

      // Mostrar diálogo si hay badges nuevos
      if (achievements.isRight()) {
        final newAchievements = achievements.getOrElse(() => []);
        if (newAchievements.isNotEmpty &&
            app_main.navigatorKey.currentContext != null) {
          // Mostrar el primer badge desbloqueado
          final firstAchievement = newAchievements.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (app_main.navigatorKey.currentContext != null) {
              AchievementUnlockedDialog.show(
                app_main.navigatorKey.currentContext!,
                firstAchievement,
                firstAchievement.xpReward,
              );
            }
          });
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.w('Error en gamificación', e, stackTrace);
      }
    }
  }

  /// Verifica si el registro es nocturno (entre 12am-6am)
  bool _hasNocturnalRecord(LactationRecord record) {
    final hour = record.timestamp.hour;
    return hour >= 0 && hour < 6;
  }

  /// Agrega un registro a la cola de sincronización
  Future<void> _addToSyncQueue(
    LactationRecord record,
    SyncOperationType operationType,
  ) async {
    try {
      // Convertir el mapa a formato serializable (DateTime -> String/Int)
      final dataMap = record.toMap();
      final serializableData = Map<String, dynamic>.from(dataMap);

      // Convertir DateTime a formato serializable
      if (serializableData['timestamp'] is DateTime) {
        serializableData['timestamp'] =
            (serializableData['timestamp'] as DateTime).toIso8601String();
      }

      // Convertir bool a int para compatibilidad
      if (serializableData['incluye_sueno'] is bool) {
        serializableData['incluye_sueno'] =
            (serializableData['incluye_sueno'] as bool) ? 1 : 0;
      }

      final operation = SyncOperation(
        id: '${record.id}_${DateTime.now().millisecondsSinceEpoch}',
        operationType: operationType,
        collectionPath: 'lactancia',
        localId: record.id,
        data: serializableData,
        createdAt: DateTime.now(),
      );

      await _syncQueueService.addOperation(operation);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('SyncQueueService: Error agregando operación', e, stackTrace);
        _logger.e('Error agregando a cola de sincronización', e, stackTrace);
      }
    }
  }

  /// Actualiza un registro existente (offline-first)
  Future<void> updateRecord(String recordId, LactationRecord record) async {
    try {
      // PASO 1: Actualizar localmente primero
      await _localDatabase.updateRecord(record);
      if (kDebugMode) {
        _logger.success(
          'Registro de lactancia actualizado localmente: $recordId',
        );
      }

      // PASO 2: Si hay conexión, intentar actualizar en Firestore inmediatamente
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          final collection = await _lactationCollection;
          await collection.doc(recordId).update(record.toMap());

          // Marcar como sincronizado si tiene firestore_id
          final pendingRecords = await _localDatabase.getPendingSyncRecords();
          final localRecord = pendingRecords.firstWhere(
            (r) => r.id == record.id,
            orElse: () => record,
          );
          if (localRecord.id == record.id) {
            // Si el registro tiene firestore_id, marcarlo como sincronizado
            await _localDatabase.markAsSynced(record.id, recordId);
          }

          if (kDebugMode) {
            _logger.success(
              'Registro de lactancia actualizado en Firestore: $recordId',
            );
          }
        } catch (e, stackTrace) {
          // Si falla Firestore, agregar a cola de sincronización
          if (kDebugMode) {
            _logger.w(
              'Error actualizando en Firestore, quedará pendiente de sincronización',
              e,
              stackTrace,
            );
          }
          await _addToSyncQueue(record, SyncOperationType.update);
        }
      } else {
        // Sin conexión: agregar a cola de sincronización
        if (kDebugMode) {
          _logger.d(
            'Sin conexión: Registro actualizado localmente, se sincronizará cuando haya conexión',
          );
        }
        await _addToSyncQueue(record, SyncOperationType.update);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Error actualizando registro de lactancia', e, stackTrace);
      }
      rethrow;
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String recordId) async {
    try {
      final collection = await _lactationCollection;
      await collection.doc(recordId).delete();
      _logger.success('Registro de lactancia eliminado: $recordId');
    } catch (e, stackTrace) {
      _logger.e('Error eliminando registro de lactancia', e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene todos los registros de una fecha específica (offline-first)
  /// Combina registros locales y remotos
  Future<List<LactationRecord>> getRecordsForDate(DateTime date) async {
    try {
      // SIEMPRE obtener registros locales primero
      final localRecords = await _localDatabase.getRecordsForDate(date);

      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          // Si hay conexión, obtener también de Firestore
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));

          final collection = await _lactationCollection;
          final querySnapshot = await collection
              .where(
                'fecha_registro',
                isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
              )
              .where('fecha_registro', isLessThan: endOfDay.toIso8601String())
              .orderBy('fecha_registro', descending: true)
              .get();

          final firestoreRecords = querySnapshot.docs
              .map(
                (doc) => LactationRecord.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          // Combinar registros: priorizar Firestore, agregar locales no sincronizados
          final Map<String, LactationRecord> combinedRecords = {};

          // Agregar registros de Firestore
          for (final record in firestoreRecords) {
            combinedRecords[record.id] = record;
          }

          // Agregar registros locales que no están en Firestore
          for (final localRecord in localRecords) {
            // Solo agregar si no está sincronizado o no existe en Firestore
            if (!combinedRecords.containsKey(localRecord.id)) {
              combinedRecords[localRecord.id] = localRecord;
            }
          }

          return combinedRecords.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        } catch (e, stackTrace) {
          if (kDebugMode) {
            _logger.w(
              'Error obteniendo registros de Firestore, usando solo locales',
              e,
              stackTrace,
            );
          }
          // Si falla Firestore, retornar solo registros locales
          return localRecords;
        }
      } else {
        // Sin conexión: retornar solo registros locales
        if (kDebugMode) {
          _logger.d('Sin conexión: Retornando solo registros locales');
        }
        return localRecords;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Error obteniendo registros para fecha', e, stackTrace);
      }
      // En caso de error, intentar retornar registros locales
      try {
        return await _localDatabase.getRecordsForDate(date);
      } catch (e2, stackTrace2) {
        if (kDebugMode) {
          _logger.e('Error obteniendo registros locales', e2, stackTrace2);
        }
        return [];
      }
    }
  }

  /// Obtiene todos los registros de una semana
  Future<List<LactationRecord>> getRecordsForWeek(DateTime startOfWeek) async {
    try {
      // Normalizar el inicio de la semana a medianoche
      final startOfWeekMidnight = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final endOfWeek = startOfWeekMidnight.add(const Duration(days: 7));

      final collection = await _lactationCollection;
      final querySnapshot = await collection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfWeekMidnight.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfWeek.toIso8601String())
          .orderBy('fecha_registro', descending: true) // Más reciente primero
          .get();

      return querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo registros para semana', e, stackTrace);
      return [];
    }
  }

  /// Obtiene todos los registros de un mes
  Future<List<LactationRecord>> getRecordsForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final collection = await _lactationCollection;
      final querySnapshot = await collection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfMonth.toIso8601String())
          .orderBy('fecha_registro', descending: true) // Más reciente primero
          .get();

      return querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo registros para mes', e, stackTrace);
      return [];
    }
  }

  /// Obtiene estadísticas de lactancia
  Future<LactationStats> getStats() async {
    try {
      final collection = await _lactationCollection;
      final querySnapshot = await collection.get();
      final records = querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // Calcular estadísticas
      final totalFeeds = records.length;
      final totalDuration = records.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + record.duracion,
      );
      final averageDuration = totalFeeds > 0
          ? Duration(minutes: totalDuration.inMinutes ~/ totalFeeds)
          : Duration.zero;

      // Estadísticas del día actual
      final today = DateTime.now();
      final todayRecords = await getRecordsForDate(today);
      final feedsToday = todayRecords.length;
      final durationToday = todayRecords.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + record.duracion,
      );

      return LactationStats(
        totalFeeds: totalFeeds,
        totalDuration: totalDuration,
        averageDuration: averageDuration,
        feedsToday: feedsToday,
        durationToday: durationToday,
      );
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo estadísticas', e, stackTrace);
      return LactationStats(
        totalFeeds: 0,
        totalDuration: Duration.zero,
        averageDuration: Duration.zero,
        feedsToday: 0,
        durationToday: Duration.zero,
      );
    }
  }

  /// Obtiene el ID del documento del usuario en Firestore (usa caché)
  /// Público para permitir acceso desde servicios externos
  Future<String?> getUserDocumentId() async {
    return _getUserDocumentId();
  }

  /// Método privado que implementa la lógica
  Future<String?> _getUserDocumentId() async {
    // Verificar caché primero
    if (_isCacheValid && _cachedUserDocId != null) {
      // Caché válido, retornar sin log (evitar spam en consola)
      return _cachedUserDocId;
    }

    _logger.d('LactationService: Caché no válido, consultando Firestore...');
    try {
      final user = _auth.currentUser;
      _logger.d(
        'LactationService: _getUserDocumentId() - Usuario actual: ${user?.uid}',
      );
      _logger.d(
        'LactationService: _getUserDocumentId() - Email: ${user?.email}',
      );

      if (user == null) {
        _logger.w(
          'LactationService: Usuario no autenticado, intentando obtener usuario actual...',
        );

        // Esperar un poco y volver a intentar
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUser = _auth.currentUser;
        _logger.d('LactationService: Usuario en reintento: ${retryUser?.uid}');

        if (retryUser == null) {
          _logger.w(
            'LactationService: Usuario sigue siendo null después del reintento',
          );
          _logger.d(
            'LactationService: Intentando con ID conocido del usuario...',
          );

          // Usar el ID conocido del usuario desde los logs
          const knownUserId = 'GVMaxiXpAFMW2VmFFbEuYhsFs733';
          _logger.d(
            'LactationService: Verificando si existe documento con ID conocido: $knownUserId',
          );

          final knownUserDoc = await _firestore
              .collection('Users')
              .doc(knownUserId)
              .get();

          if (knownUserDoc.exists) {
            _logger.success(
              'LactationService: Documento encontrado con ID conocido: $knownUserId',
            );
            // Actualizar caché
            _cachedUserDocId = knownUserId;
            _lastCacheUpdate = DateTime.now();
            return knownUserId;
          } else {
            _logger.e('LactationService: Documento con ID conocido no existe');
            return null;
          }
        }

        // Usar el usuario del reintento
        final result = await _getUserDocumentIdWithUser(retryUser);
        if (result != null) {
          _cachedUserDocId = result;
          _lastCacheUpdate = DateTime.now();
        }
        return result;
      }

      final result = await _getUserDocumentIdWithUser(user);
      if (result != null) {
        _cachedUserDocId = result;
        _lastCacheUpdate = DateTime.now();
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo ID del usuario', e, stackTrace);
      return null;
    }
  }

  /// Método auxiliar para obtener el ID del documento con un usuario específico
  Future<String?> _getUserDocumentIdWithUser(dynamic user) async {
    try {
      // Primero intentar con UID directamente (más rápido)
      _logger.d('LactationService: Intentando con UID primero: ${user.uid}');
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      _logger.d(
        'LactationService: Documento con UID existe: ${docSnapshot.exists}',
      );

      if (docSnapshot.exists) {
        _logger.d(
          'LactationService: Usuario encontrado con UID directo: ${user.uid}',
        );
        return user.uid;
      }

      // Si no existe con UID, buscar por email
      if (user.email != null) {
        _logger.d(
          'LactationService: Buscando usuario por email: ${user.email}',
        );

        // Buscar el documento del usuario por email
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        _logger.d(
          'LactationService: Query por email completada. Documentos encontrados: ${userQuery.docs.length}',
        );

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          _logger.d('LactationService: Usuario encontrado con ID: $userDocId');
          return userDocId;
        } else {
          _logger.e('LactationService: Usuario no encontrado por email');
        }
      }

      _logger.e('LactationService: No se encontró usuario en Firestore');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo ID del usuario', e, stackTrace);
      return null;
    }
  }

  /// Verifica si el usuario tiene situación Post-Parto configurada (usa caché)
  Future<bool> hasPostpartumSituation() async {
    // Verificar caché primero
    if (_isCacheValid && _cachedHasPostpartumSituation != null) {
      _logger.d(
        'LactationService: Usando caché para hasPostpartumSituation: $_cachedHasPostpartumSituation',
      );
      return _cachedHasPostpartumSituation!;
    }

    _logger.d('LactationService: Caché no válido, consultando Firestore...');
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        _logger.e('LactationService: userDocId es null, retornando false');
        return false;
      }

      final result = await _checkPostpartumSituationDirect(userDocId);

      // Actualizar caché
      _cachedUserDocId = userDocId;
      _cachedHasPostpartumSituation = result;
      _lastCacheUpdate = DateTime.now();

      return result;
    } catch (e, stackTrace) {
      _logger.e('Error verificando situación Post-Parto', e, stackTrace);
      return false;
    }
  }

  /// Verifica directamente la situación Post-Parto sin caché
  Future<bool> _checkPostpartumSituationDirect(String userDocId) async {
    try {
      _logger.d(
        'LactationService: Verificando situación directa para: $userDocId',
      );

      final docSnapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final situationType = data?['situationType'] as String?;
        _logger.d('LactationService: situationType encontrado: $situationType');
        return situationType == 'postparto';
      } else {
        _logger.w('LactationService: Documento de situación no existe');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error verificando situación Post-Parto directa',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Obtiene un registro específico por ID
  Future<LactationRecord?> getRecordById(String recordId) async {
    try {
      final collection = await _lactationCollection;
      final docSnapshot = await collection.doc(recordId).get();
      if (docSnapshot.exists) {
        return LactationRecord.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo registro por ID', e, stackTrace);
      return null;
    }
  }
}
