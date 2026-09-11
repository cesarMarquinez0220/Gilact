import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/entities/daily_streak.dart';

/// Data source remoto para gamificación (Firestore)
/// Sincroniza datos locales con la nube
class GamificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GamificationRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? _cachedUserDocId;

  /// Obtiene el ID del documento del usuario en Firestore
  Future<String?> _getUserDocumentId() async {
    if (_cachedUserDocId != null) return _cachedUserDocId;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Optimización: Si el UID existe como documento, es lo ideal.
      // Primero verificamos UID directo para evitar queries costosas
      final docSnapshot =
          await _firestore
              .collection('Users')
              .doc(user.uid)
              .get();

      if (docSnapshot.exists) {
        _cachedUserDocId = user.uid;
        return user.uid;
      }

      // Si no existe por UID, buscar por email (Legacy fallback)
      if (user.email != null) {
        final query = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          _cachedUserDocId = query.docs.first.id;
          return _cachedUserDocId;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ GamificationRemoteDataSource: Error obteniendo userId: $e');
      }
      return null;
    }
  }

  /// Guarda o actualiza el perfil de gamificación en Firestore
  Future<void> saveProfile(UserGamificationProfile profile) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado en Firestore');
      }

      await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('profile')
          .set(_profileToFirestore(profile), SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Perfil de gamificación guardado en Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando perfil en Firestore: $e');
      }
      rethrow;
    }
  }

  /// Obtiene el perfil de gamificación desde Firestore
  Future<UserGamificationProfile?> getProfile(String userId) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) return null;

      final doc = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('profile')
          .get();

      if (!doc.exists) return null;

      return _profileFromFirestore(doc.data()!, userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo perfil desde Firestore: $e');
      }
      return null;
    }
  }

  /// Guarda una transacción de XP en Firestore
  Future<void> saveXPTransaction(XPTransaction transaction) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado en Firestore');
      }

      await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('xp_transactions')
          .collection('transactions')
          .doc(transaction.id)
          .set(_transactionToFirestore(transaction));

      if (kDebugMode) {
        print('✅ Transacción de XP guardada en Firestore: ${transaction.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando transacción en Firestore: $e');
      }
      rethrow;
    }
  }

  /// Sincroniza múltiples transacciones de XP
  Future<void> syncXPTransactions(List<XPTransaction> transactions) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado en Firestore');
      }

      final batch = _firestore.batch();
      final collectionRef = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('xp_transactions')
          .collection('transactions');

      for (final transaction in transactions) {
        final docRef = collectionRef.doc(transaction.id);
        batch.set(docRef, _transactionToFirestore(transaction));
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ ${transactions.length} transacciones sincronizadas en Firestore',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sincronizando transacciones: $e');
      }
      rethrow;
    }
  }

  /// Obtiene todas las transacciones de XP desde Firestore
  Future<List<XPTransaction>> getXPTransactions(String userId) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) return [];

      final snapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('xp_transactions')
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _transactionFromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo transacciones desde Firestore: $e');
      }
      return [];
    }
  }

  /// Guarda o actualiza la racha diaria en Firestore
  Future<void> saveStreak(DailyStreak streak) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado en Firestore');
      }

      await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('streak')
          .set(_streakToFirestore(streak), SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Racha guardada en Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando racha en Firestore: $e');
      }
      rethrow;
    }
  }

  /// Obtiene la racha diaria desde Firestore
  Future<DailyStreak?> getStreak(String userId) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) return null;

      final doc = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('gamification')
          .doc('streak')
          .get();

      if (!doc.exists) return null;

      return _streakFromFirestore(doc.data()!, userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo racha desde Firestore: $e');
      }
      return null;
    }
  }

  // Métodos de conversión para Firestore

  Map<String, dynamic> _profileToFirestore(UserGamificationProfile profile) {
    return {
      'userId': profile.userId,
      'totalXP': profile.totalXP,
      'currentLevel': profile.currentLevel,
      'currentLevelXP': profile.currentLevelXP,
      'nextLevelXP': profile.nextLevelXP,
      'currentStreak': profile.currentStreak,
      'lastActivityDate': profile.lastActivityDate != null
          ? Timestamp.fromDate(profile.lastActivityDate!)
          : null,
      'streakStartDate': profile.streakStartDate != null
          ? Timestamp.fromDate(profile.streakStartDate!)
          : null,
      'unlockedAchievements': profile.unlockedAchievements,
      'newAchievements': profile.newAchievements,
      'mascotState': profile.mascotState,
      'mascotLevel': profile.mascotLevel,
      'babyStage': profile.babyStage,
      'dailyXP': profile.dailyXP.map((key, value) => MapEntry(key, value)),
      'completedDailyChallenges': profile.completedDailyChallenges.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'restDaysUsed': profile.restDaysUsed,
      'restDaysAvailable': profile.restDaysAvailable,
      'isPauseModeActive': profile.isPauseModeActive,
      'pauseModeStartDate': profile.pauseModeStartDate != null
          ? Timestamp.fromDate(profile.pauseModeStartDate!)
          : null,
      'lastRestDayUsed': profile.lastRestDayUsed != null
          ? Timestamp.fromDate(profile.lastRestDayUsed!)
          : null,
      'isSynced': true,
      'lastSyncAt': Timestamp.now(),
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.now(),
    };
  }

  UserGamificationProfile _profileFromFirestore(
    Map<String, dynamic> data,
    String userId,
  ) {
    return UserGamificationProfile(
      userId: userId,
      totalXP: data['totalXP'] as int? ?? 0,
      currentLevel: data['currentLevel'] as int? ?? 1,
      currentLevelXP: data['currentLevelXP'] as int? ?? 0,
      nextLevelXP: data['nextLevelXP'] as int? ?? 100,
      currentStreak: data['currentStreak'] as int? ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
      streakStartDate: (data['streakStartDate'] as Timestamp?)?.toDate(),
      unlockedAchievements:
          (data['unlockedAchievements'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      newAchievements:
          (data['newAchievements'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      mascotState: data['mascotState'] as String? ?? 'happy',
      mascotLevel: data['mascotLevel'] as int? ?? 1,
      babyStage: data['babyStage'] as String? ?? 'baby_born',
      dailyXP: (data['dailyXP'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      completedDailyChallenges: (data['completedDailyChallenges'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(
                    key,
                    (value as Timestamp).toDate(),
                  )) ??
          const {},
      restDaysUsed: data['restDaysUsed'] as int? ?? 0,
      restDaysAvailable: data['restDaysAvailable'] as int? ?? 3,
      isPauseModeActive: data['isPauseModeActive'] as bool? ?? false,
      pauseModeStartDate: (data['pauseModeStartDate'] as Timestamp?)?.toDate(),
      lastRestDayUsed: (data['lastRestDayUsed'] as Timestamp?)?.toDate(),
      isSynced: true,
      lastSyncAt: (data['lastSyncAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _transactionToFirestore(XPTransaction transaction) {
    return {
      'id': transaction.id,
      'userId': transaction.userId,
      'amount': transaction.amount,
      'source': transaction.source.name,
      'sourceId': transaction.sourceId,
      'bonusReason': transaction.bonusReason,
      'timestamp': Timestamp.fromDate(transaction.timestamp),
    };
  }

  XPTransaction _transactionFromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return XPTransaction(
      id: id,
      userId: data['userId'] as String,
      amount: data['amount'] as int,
      source: XPSource.values.firstWhere(
        (e) => e.name == data['source'],
        orElse: () => XPSource.lactationRecordQuick,
      ),
      sourceId: data['sourceId'] as String?,
      bonusReason: data['bonusReason'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _streakToFirestore(DailyStreak streak) {
    return {
      'userId': streak.userId,
      'currentStreak': streak.currentStreak,
      'streakStartDate': streak.streakStartDate != null
          ? Timestamp.fromDate(streak.streakStartDate!)
          : null,
      'lastActivityDate': streak.lastActivityDate != null
          ? Timestamp.fromDate(streak.lastActivityDate!)
          : null,
      'activityDates': streak.activityDates
          .map((d) => Timestamp.fromDate(d))
          .toList(),
      'restDaysUsedThisWeek': streak.restDaysUsedThisWeek,
      'weekStartDate': streak.weekStartDate != null
          ? Timestamp.fromDate(streak.weekStartDate!)
          : null,
      'isPauseModeActive': streak.isPauseModeActive,
      'pauseModeStartDate': streak.pauseModeStartDate != null
          ? Timestamp.fromDate(streak.pauseModeStartDate!)
          : null,
      'updatedAt': Timestamp.now(),
    };
  }

  DailyStreak _streakFromFirestore(Map<String, dynamic> data, String userId) {
    return DailyStreak(
      userId: userId,
      currentStreak: data['currentStreak'] as int? ?? 0,
      streakStartDate: (data['streakStartDate'] as Timestamp?)?.toDate(),
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
      activityDates: (data['activityDates'] as List<dynamic>?)
              ?.map((d) => (d as Timestamp).toDate())
              .toList() ??
          [],
      restDaysUsedThisWeek: data['restDaysUsedThisWeek'] as int? ?? 0,
      weekStartDate: (data['weekStartDate'] as Timestamp?)?.toDate(),
      isPauseModeActive: data['isPauseModeActive'] as bool? ?? false,
      pauseModeStartDate: (data['pauseModeStartDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Ejecuta múltiples actualizaciones en una sola transacción batch (Optimización de Escritura)
  Future<void> performBatchUpdate({
    required UserGamificationProfile profile,
    required DailyStreak streak,
    List<XPTransaction>? transactions,
  }) async {
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        throw Exception('Usuario no encontrado en Firestore');
      }

      final batch = _firestore.batch();
      final userRef =
          _firestore.collection('Users').doc(userDocId).collection('gamification');

      // 1. Actualizar Perfil
      final profileRef = userRef.doc('profile');
      batch.set(profileRef, _profileToFirestore(profile), SetOptions(merge: true));

      // 2. Actualizar Racha
      final streakRef = userRef.doc('streak');
      batch.set(streakRef, _streakToFirestore(streak), SetOptions(merge: true));

      // 3. Guardar Transacciones (si hay)
      if (transactions != null && transactions.isNotEmpty) {
        final transactionsRef = userRef.doc('xp_transactions').collection('transactions');
        for (final transaction in transactions) {
          final docRef = transactionsRef.doc(transaction.id);
          batch.set(docRef, _transactionToFirestore(transaction));
        }
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Batch update completado exitosamente (${transactions?.length ?? 0} Txs)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en batch update: $e');
      }
      rethrow;
    }
  }
}

