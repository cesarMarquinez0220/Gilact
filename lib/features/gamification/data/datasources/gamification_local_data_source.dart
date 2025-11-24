import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../domain/entities/user_gamification_profile.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/entities/daily_streak.dart';

/// Data source local para gamificación (SQLite)
/// OFFLINE-FIRST: Todo se guarda localmente primero
class GamificationLocalDataSource {
  static final GamificationLocalDataSource _instance =
      GamificationLocalDataSource._internal();
  factory GamificationLocalDataSource() => _instance;
  GamificationLocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gamification_local.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // Tabla de perfil de gamificación
        await db.execute('''
          CREATE TABLE user_gamification_profile(
            user_id TEXT PRIMARY KEY,
            total_xp INTEGER NOT NULL DEFAULT 0,
            current_level INTEGER NOT NULL DEFAULT 1,
            current_level_xp INTEGER NOT NULL DEFAULT 0,
            next_level_xp INTEGER NOT NULL DEFAULT 100,
            current_streak INTEGER NOT NULL DEFAULT 0,
            last_activity_date INTEGER,
            streak_start_date INTEGER,
            unlocked_achievements TEXT NOT NULL DEFAULT '[]',
            new_achievements TEXT NOT NULL DEFAULT '[]',
            mascot_state TEXT NOT NULL DEFAULT 'happy',
            mascot_level INTEGER NOT NULL DEFAULT 1,
            daily_xp TEXT NOT NULL DEFAULT '{}',
            completed_daily_challenges TEXT NOT NULL DEFAULT '{}',
            rest_days_used INTEGER NOT NULL DEFAULT 0,
            rest_days_available INTEGER NOT NULL DEFAULT 3,
            is_pause_mode_active INTEGER NOT NULL DEFAULT 0,
            pause_mode_start_date INTEGER,
            last_rest_day_used INTEGER,
            is_synced INTEGER NOT NULL DEFAULT 0,
            last_sync_at INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Tabla de transacciones de XP (historial completo)
        await db.execute('''
          CREATE TABLE xp_transactions(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            amount INTEGER NOT NULL,
            source TEXT NOT NULL,
            source_id TEXT,
            bonus_reason TEXT,
            timestamp INTEGER NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');

        // Tabla de racha diaria
        await db.execute('''
          CREATE TABLE daily_streak(
            user_id TEXT PRIMARY KEY,
            current_streak INTEGER NOT NULL DEFAULT 0,
            streak_start_date INTEGER,
            last_activity_date INTEGER,
            activity_dates TEXT NOT NULL DEFAULT '[]',
            rest_days_used_this_week INTEGER NOT NULL DEFAULT 0,
            week_start_date INTEGER,
            is_pause_mode_active INTEGER NOT NULL DEFAULT 0,
            pause_mode_start_date INTEGER,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Índices
        await db.execute(
          'CREATE INDEX idx_xp_user_timestamp ON xp_transactions(user_id, timestamp)',
        );
        await db.execute(
          'CREATE INDEX idx_xp_synced ON xp_transactions(is_synced)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregar columna new_achievements
          try {
            await db.execute(
              'ALTER TABLE user_gamification_profile ADD COLUMN new_achievements TEXT NOT NULL DEFAULT \'[]\'',
            );
          } catch (e) {
            // Si la columna ya existe, ignorar el error
            if (kDebugMode) {
              print('⚠️ Columna new_achievements ya existe o error: $e');
            }
          }
        }
        if (oldVersion < 3) {
          // Agregar columna completed_daily_challenges
          try {
            await db.execute(
              'ALTER TABLE user_gamification_profile ADD COLUMN completed_daily_challenges TEXT NOT NULL DEFAULT \'{}\'',
            );
            if (kDebugMode) {
              print(
                '✅ Migración v3: Columna completed_daily_challenges agregada',
              );
            }
          } catch (e) {
            // Si la columna ya existe, ignorar el error
            if (kDebugMode) {
              print(
                '⚠️ Columna completed_daily_challenges ya existe o error: $e',
              );
            }
          }
        }
      },
    );
  }

  /// Guarda o actualiza el perfil de gamificación
  Future<void> saveProfile(UserGamificationProfile profile) async {
    final db = await database;
    await db.insert(
      'user_gamification_profile',
      _profileToMap(profile),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene el perfil de gamificación
  Future<UserGamificationProfile?> getProfile(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_gamification_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return _profileFromMap(maps.first);
  }

  /// Guarda una transacción de XP
  Future<void> saveXPTransaction(XPTransaction transaction) async {
    final db = await database;
    await db.insert(
      'xp_transactions',
      _transactionToMap(transaction),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todas las transacciones de XP de un usuario
  Future<List<XPTransaction>> getXPTransactions(String userId) async {
    final db = await database;
    final maps = await db.query(
      'xp_transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _transactionFromMap(map)).toList();
  }

  /// Obtiene transacciones no sincronizadas
  Future<List<XPTransaction>> getUnsyncedTransactions(String userId) async {
    final db = await database;
    final maps = await db.query(
      'xp_transactions',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => _transactionFromMap(map)).toList();
  }

  /// Marca transacciones como sincronizadas
  Future<void> markTransactionsAsSynced(List<String> transactionIds) async {
    final db = await database;
    for (final id in transactionIds) {
      await db.update(
        'xp_transactions',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Guarda o actualiza la racha diaria
  Future<void> saveStreak(DailyStreak streak) async {
    final db = await database;
    await db.insert(
      'daily_streak',
      _streakToMap(streak),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene la racha diaria
  Future<DailyStreak?> getStreak(String userId) async {
    final db = await database;
    final maps = await db.query(
      'daily_streak',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return _streakFromMap(maps.first);
  }

  // Métodos de conversión

  Map<String, dynamic> _profileToMap(UserGamificationProfile profile) {
    return {
      'user_id': profile.userId,
      'total_xp': profile.totalXP,
      'current_level': profile.currentLevel,
      'current_level_xp': profile.currentLevelXP,
      'next_level_xp': profile.nextLevelXP,
      'current_streak': profile.currentStreak,
      'last_activity_date': profile.lastActivityDate?.millisecondsSinceEpoch,
      'streak_start_date': profile.streakStartDate?.millisecondsSinceEpoch,
      'unlocked_achievements': jsonEncode(profile.unlockedAchievements),
      'new_achievements': jsonEncode(profile.newAchievements),
      'mascot_state': profile.mascotState,
      'mascot_level': profile.mascotLevel,
      'daily_xp': jsonEncode(
        profile.dailyXP.map((key, value) => MapEntry(key, value)),
      ),
      'completed_daily_challenges': jsonEncode(
        profile.completedDailyChallenges.map(
          (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
        ),
      ),
      'rest_days_used': profile.restDaysUsed,
      'rest_days_available': profile.restDaysAvailable,
      'is_pause_mode_active': profile.isPauseModeActive ? 1 : 0,
      'pause_mode_start_date':
          profile.pauseModeStartDate?.millisecondsSinceEpoch,
      'last_rest_day_used': profile.lastRestDayUsed?.millisecondsSinceEpoch,
      'is_synced': profile.isSynced ? 1 : 0,
      'last_sync_at': profile.lastSyncAt?.millisecondsSinceEpoch,
      'created_at': profile.createdAt.millisecondsSinceEpoch,
      'updated_at': profile.updatedAt.millisecondsSinceEpoch,
    };
  }

  UserGamificationProfile _profileFromMap(Map<String, dynamic> map) {
    return UserGamificationProfile(
      userId: map['user_id'] as String,
      totalXP: map['total_xp'] as int,
      currentLevel: map['current_level'] as int,
      currentLevelXP: map['current_level_xp'] as int,
      nextLevelXP: map['next_level_xp'] as int,
      currentStreak: map['current_streak'] as int,
      lastActivityDate: map['last_activity_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['last_activity_date'] as int,
            )
          : null,
      streakStartDate: map['streak_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['streak_start_date'] as int)
          : null,
      unlockedAchievements:
          (jsonDecode(map['unlocked_achievements'] as String) as List)
              .map((e) => e.toString())
              .toList(),
      newAchievements: map['new_achievements'] != null
          ? (jsonDecode(map['new_achievements'] as String) as List)
                .map((e) => e.toString())
                .toList()
          : [],
      mascotState: map['mascot_state'] as String,
      mascotLevel: map['mascot_level'] as int,
      dailyXP: (jsonDecode(map['daily_xp'] as String) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as int)),
      completedDailyChallenges: map['completed_daily_challenges'] != null
          ? (jsonDecode(map['completed_daily_challenges'] as String)
                    as Map<String, dynamic>)
                .map(
                  (key, value) => MapEntry(
                    key,
                    DateTime.fromMillisecondsSinceEpoch(value as int),
                  ),
                )
          : const {},
      restDaysUsed: map['rest_days_used'] as int,
      restDaysAvailable: map['rest_days_available'] as int,
      isPauseModeActive: (map['is_pause_mode_active'] as int) == 1,
      pauseModeStartDate: map['pause_mode_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['pause_mode_start_date'] as int,
            )
          : null,
      lastRestDayUsed: map['last_rest_day_used'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['last_rest_day_used'] as int,
            )
          : null,
      isSynced: (map['is_synced'] as int) == 1,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_sync_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> _transactionToMap(XPTransaction transaction) {
    return {
      'id': transaction.id,
      'user_id': transaction.userId,
      'amount': transaction.amount,
      'source': transaction.source.name,
      'source_id': transaction.sourceId,
      'bonus_reason': transaction.bonusReason,
      'timestamp': transaction.timestamp.millisecondsSinceEpoch,
      'is_synced': 0, // Por defecto no sincronizado
      'created_at': transaction.timestamp.millisecondsSinceEpoch,
    };
  }

  XPTransaction _transactionFromMap(Map<String, dynamic> map) {
    return XPTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      amount: map['amount'] as int,
      source: XPSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => XPSource.lactationRecordQuick,
      ),
      sourceId: map['source_id'] as String?,
      bonusReason: map['bonus_reason'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> _streakToMap(DailyStreak streak) {
    return {
      'user_id': streak.userId,
      'current_streak': streak.currentStreak,
      'streak_start_date': streak.streakStartDate?.millisecondsSinceEpoch,
      'last_activity_date': streak.lastActivityDate?.millisecondsSinceEpoch,
      'activity_dates': jsonEncode(
        streak.activityDates.map((d) => d.millisecondsSinceEpoch).toList(),
      ),
      'rest_days_used_this_week': streak.restDaysUsedThisWeek,
      'week_start_date': streak.weekStartDate?.millisecondsSinceEpoch,
      'is_pause_mode_active': streak.isPauseModeActive ? 1 : 0,
      'pause_mode_start_date':
          streak.pauseModeStartDate?.millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  DailyStreak _streakFromMap(Map<String, dynamic> map) {
    final activityDatesList =
        jsonDecode(map['activity_dates'] as String) as List<dynamic>;
    return DailyStreak(
      userId: map['user_id'] as String,
      currentStreak: map['current_streak'] as int,
      streakStartDate: map['streak_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['streak_start_date'] as int)
          : null,
      lastActivityDate: map['last_activity_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['last_activity_date'] as int,
            )
          : null,
      activityDates: activityDatesList
          .map((d) => DateTime.fromMillisecondsSinceEpoch(d as int))
          .toList(),
      restDaysUsedThisWeek: map['rest_days_used_this_week'] as int,
      weekStartDate: map['week_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['week_start_date'] as int)
          : null,
      isPauseModeActive: (map['is_pause_mode_active'] as int) == 1,
      pauseModeStartDate: map['pause_mode_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['pause_mode_start_date'] as int,
            )
          : null,
    );
  }
}
