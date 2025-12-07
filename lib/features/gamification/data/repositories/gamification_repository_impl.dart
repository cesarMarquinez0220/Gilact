import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/entities/daily_streak.dart';
import '../datasources/gamification_local_data_source.dart';
import '../datasources/gamification_remote_data_source.dart';
import '../../../../core/services/connectivity_service.dart';

/// Implementación del repositorio de gamificación
/// OFFLINE-FIRST: Guarda localmente primero, luego sincroniza
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationLocalDataSource _localDataSource;
  final GamificationRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  GamificationRepositoryImpl({
    required GamificationLocalDataSource localDataSource,
    required GamificationRemoteDataSource remoteDataSource,
    required ConnectivityService connectivityService,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _connectivityService = connectivityService;

  @override
  Future<Either<String, UserGamificationProfile?>> getProfile(
    String userId,
  ) async {
    try {
      // OFFLINE-FIRST: Intentar obtener de local primero
      final localProfile = await _localDataSource.getProfile(userId);

      // Si hay conexión, intentar obtener de Firestore y actualizar local
      if (await _connectivityService.isConnected()) {
        try {
          final remoteProfile = await _remoteDataSource.getProfile(userId);

          if (remoteProfile != null) {
            // Actualizar local con datos remotos
            await _localDataSource.saveProfile(remoteProfile);
            return Right(remoteProfile);
          } else if (localProfile != null) {
            // No hay perfil remoto, usar local
            return Right(localProfile);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error obteniendo perfil remoto, usando local: $e');
          }
          // Si falla remoto, usar local
          if (localProfile != null) {
            return Right(localProfile);
          }
        }
      }

      // Sin conexión o sin perfil remoto, usar local
      return Right(localProfile);
    } catch (e) {
      return Left('Error obteniendo perfil: $e');
    }
  }

  @override
  Future<Either<String, void>> saveProfile(
    UserGamificationProfile profile,
  ) async {
    try {
      // OFFLINE-FIRST: Guardar localmente primero
      await _localDataSource.saveProfile(profile);

      // Si hay conexión, sincronizar con Firestore
      if (await _connectivityService.isConnected()) {
        try {
          await _remoteDataSource.saveProfile(profile);
          // Marcar como sincronizado
          final syncedProfile = profile.copyWith(
            isSynced: true,
            lastSyncAt: DateTime.now(),
          );
          await _localDataSource.saveProfile(syncedProfile);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error sincronizando perfil, se guardó localmente: $e');
          }
          // No es crítico, ya está guardado localmente
        }
      }

      return const Right(null);
    } catch (e) {
      return Left('Error guardando perfil: $e');
    }
  }

  @override
  Future<Either<String, void>> saveXPTransaction(
    XPTransaction transaction,
  ) async {
    try {
      // OFFLINE-FIRST: Guardar localmente primero
      await _localDataSource.saveXPTransaction(transaction);

      // Si hay conexión, sincronizar con Firestore
      if (await _connectivityService.isConnected()) {
        try {
          await _remoteDataSource.saveXPTransaction(transaction);
          // Marcar como sincronizado
          await _localDataSource.markTransactionsAsSynced([transaction.id]);
        } catch (e) {
          if (kDebugMode) {
            print(
              '⚠️ Error sincronizando transacción, se guardó localmente: $e',
            );
          }
          // No es crítico, ya está guardado localmente
        }
      }

      return const Right(null);
    } catch (e) {
      return Left('Error guardando transacción: $e');
    }
  }

  @override
  Future<Either<String, List<XPTransaction>>> getXPTransactions(
    String userId,
  ) async {
    try {
      // OFFLINE-FIRST: Obtener de local primero
      final localTransactions = await _localDataSource.getXPTransactions(
        userId,
      );

      // Si hay conexión, intentar obtener de Firestore
      if (await _connectivityService.isConnected()) {
        try {
          final remoteTransactions = await _remoteDataSource.getXPTransactions(
            userId,
          );

          // Combinar y deduplicar (priorizar remoto)
          final remoteIds = remoteTransactions.map((t) => t.id).toSet();
          final localOnly = localTransactions
              .where((t) => !remoteIds.contains(t.id))
              .toList();

          return Right([...remoteTransactions, ...localOnly]);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error obteniendo transacciones remotas: $e');
          }
        }
      }

      return Right(localTransactions);
    } catch (e) {
      return Left('Error obteniendo transacciones: $e');
    }
  }

  @override
  Future<Either<String, List<XPTransaction>>> getUnsyncedTransactions(
    String userId,
  ) async {
    try {
      return Right(await _localDataSource.getUnsyncedTransactions(userId));
    } catch (e) {
      return Left('Error obteniendo transacciones no sincronizadas: $e');
    }
  }

  @override
  Future<Either<String, void>> markTransactionsAsSynced(
    List<String> transactionIds,
  ) async {
    try {
      await _localDataSource.markTransactionsAsSynced(transactionIds);
      return const Right(null);
    } catch (e) {
      return Left('Error marcando transacciones como sincronizadas: $e');
    }
  }

  @override
  Future<Either<String, void>> saveStreak(DailyStreak streak) async {
    try {
      // OFFLINE-FIRST: Guardar localmente primero
      await _localDataSource.saveStreak(streak);

      // Si hay conexión, sincronizar con Firestore
      if (await _connectivityService.isConnected()) {
        try {
          await _remoteDataSource.saveStreak(streak);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error sincronizando racha, se guardó localmente: $e');
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left('Error guardando racha: $e');
    }
  }

  @override
  Future<Either<String, DailyStreak?>> getStreak(String userId) async {
    try {
      // OFFLINE-FIRST: Obtener de local primero
      final localStreak = await _localDataSource.getStreak(userId);

      // Si hay conexión, intentar obtener de Firestore
      if (await _connectivityService.isConnected()) {
        try {
          final remoteStreak = await _remoteDataSource.getStreak(userId);

          if (remoteStreak != null) {
            // Actualizar local con datos remotos
            await _localDataSource.saveStreak(remoteStreak);
            return Right(remoteStreak);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error obteniendo racha remota: $e');
          }
        }
      }

      return Right(localStreak);
    } catch (e) {
      return Left('Error obteniendo racha: $e');
    }
  }

  @override
  Future<Either<String, void>> syncWithFirestore(String userId) async {
    try {
      if (!await _connectivityService.isConnected()) {
        return const Left('Sin conexión a internet');
      }

      // 1. Sincronizar transacciones no sincronizadas
      final unsyncedTransactions = await _localDataSource
          .getUnsyncedTransactions(userId);

      if (unsyncedTransactions.isNotEmpty) {
        await _remoteDataSource.syncXPTransactions(unsyncedTransactions);
        await _localDataSource.markTransactionsAsSynced(
          unsyncedTransactions.map((t) => t.id).toList(),
        );
      }

      // 2. Sincronizar perfil
      final localProfile = await _localDataSource.getProfile(userId);
      if (localProfile != null && !localProfile.isSynced) {
        await _remoteDataSource.saveProfile(localProfile);
        await _localDataSource.saveProfile(
          localProfile.copyWith(isSynced: true, lastSyncAt: DateTime.now()),
        );
      }

      // 3. Sincronizar racha
      final localStreak = await _localDataSource.getStreak(userId);
      if (localStreak != null) {
        await _remoteDataSource.saveStreak(localStreak);
      }

      return const Right(null);
    } catch (e) {
      return Left('Error sincronizando con Firestore: $e');
    }
  }

  @override
  Future<Either<String, void>> clearUserData(String userId) async {
    try {
      await _localDataSource.clearUserData(userId);
      return const Right(null);
    } catch (e) {
      return Left('Error limpiando datos de gamificación: $e');
    }
  }
  @override
  Future<Either<String, void>> performBatchUpdate({
    required UserGamificationProfile profile,
    required DailyStreak streak,
    List<XPTransaction>? transactions,
  }) async {
    try {
      // OFFLINE-FIRST: Guardar todo localmente
      await _localDataSource.saveProfile(profile);
      await _localDataSource.saveStreak(streak);
      if (transactions != null) {
        for (final transaction in transactions) {
          await _localDataSource.saveXPTransaction(transaction);
        }
      }

      // Si hay conexión, usar batch update remoto
      if (await _connectivityService.isConnected()) {
        try {
          await _remoteDataSource.performBatchUpdate(
            profile: profile,
            streak: streak,
            transactions: transactions,
          );

          // Marcar como sincronizado
          final syncedProfile = profile.copyWith(
            isSynced: true,
            lastSyncAt: DateTime.now(),
          );
          await _localDataSource.saveProfile(syncedProfile);

          if (transactions != null) {
            final txIds = transactions.map((t) => t.id).toList();
            await _localDataSource.markTransactionsAsSynced(txIds);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error en batch update remoto, se guardó localmente: $e');
          }
          // No es crítico, ya está guardado localmente
        }
      }

      return const Right(null);
    } catch (e) {
      return Left('Error en batch update: $e');
    }
  }
}
