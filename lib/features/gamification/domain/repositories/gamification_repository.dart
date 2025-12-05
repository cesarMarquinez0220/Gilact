import 'package:dartz/dartz.dart';
import '../entities/user_gamification_profile.dart';
import '../entities/xp_transaction.dart';
import '../entities/daily_streak.dart';

/// Repositorio de gamificación
/// Abstracción para data sources (local y remote)
abstract class GamificationRepository {
  /// Obtiene el perfil de gamificación (offline-first)
  Future<Either<String, UserGamificationProfile?>> getProfile(String userId);

  /// Guarda el perfil de gamificación (local primero, luego sync)
  Future<Either<String, void>> saveProfile(UserGamificationProfile profile);

  /// Guarda una transacción de XP (offline-first)
  Future<Either<String, void>> saveXPTransaction(XPTransaction transaction);

  /// Obtiene todas las transacciones de XP
  Future<Either<String, List<XPTransaction>>> getXPTransactions(String userId);

  /// Obtiene transacciones no sincronizadas
  Future<Either<String, List<XPTransaction>>> getUnsyncedTransactions(
    String userId,
  );

  /// Marca transacciones como sincronizadas
  Future<Either<String, void>> markTransactionsAsSynced(
    List<String> transactionIds,
  );

  /// Guarda la racha diaria (offline-first)
  Future<Either<String, void>> saveStreak(DailyStreak streak);

  /// Obtiene la racha diaria
  Future<Either<String, DailyStreak?>> getStreak(String userId);

  /// Sincroniza datos locales con Firestore
  Future<Either<String, void>> syncWithFirestore(String userId);

  /// Limpia todos los datos de gamificación de un usuario (útil al cerrar sesión)
  Future<Either<String, void>> clearUserData(String userId);
}
