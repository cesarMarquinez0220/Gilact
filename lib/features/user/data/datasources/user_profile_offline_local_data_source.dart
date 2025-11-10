import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entities.dart';

/// Data source local para cachear perfil de usuario e información del bebé
class UserProfileOfflineLocalDataSource {
  static final UserProfileOfflineLocalDataSource _instance =
      UserProfileOfflineLocalDataSource._internal();
  factory UserProfileOfflineLocalDataSource() => _instance;
  UserProfileOfflineLocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_profile_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile_cache(
            user_id TEXT PRIMARY KEY,
            id TEXT NOT NULL,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            mother_name TEXT,
            birth_date TEXT,
            age INTEGER,
            cedula TEXT,
            location TEXT,
            phone TEXT,
            registration_date INTEGER NOT NULL,
            is_pre_partum INTEGER NOT NULL DEFAULT 0,
            is_post_partum INTEGER NOT NULL DEFAULT 0,
            baby_info TEXT,
            situation_data TEXT,
            cached_at INTEGER NOT NULL,
            last_sync_at INTEGER
          )
        ''');

        // Índices
        await db.execute('CREATE INDEX idx_user_id ON user_profile_cache(user_id)');
        await db.execute('CREATE INDEX idx_email ON user_profile_cache(email)');
      },
    );
  }

  /// Cachea el perfil de usuario
  Future<void> cacheUserProfile(UserProfile profile) async {
    try {
      final db = await database;
      final map = _profileToMap(profile);
      map['cached_at'] = DateTime.now().millisecondsSinceEpoch;
      map['last_sync_at'] = DateTime.now().millisecondsSinceEpoch;

      await db.insert(
        'user_profile_cache',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        print('✅ UserProfileOfflineLocalDataSource: Perfil cacheado para usuario: ${profile.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileOfflineLocalDataSource: Error cacheando perfil: $e');
      }
      rethrow;
    }
  }

  /// Obtiene el perfil cacheado
  Future<UserProfile?> getCachedUserProfile({String? userId, String? email}) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps;

      if (userId != null) {
        maps = await db.query(
          'user_profile_cache',
          where: 'user_id = ? OR id = ?',
          whereArgs: [userId, userId],
          limit: 1,
        );
      } else if (email != null) {
        maps = await db.query(
          'user_profile_cache',
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );
      } else {
        // Obtener el más reciente
        maps = await db.query(
          'user_profile_cache',
          orderBy: 'cached_at DESC',
          limit: 1,
        );
      }

      if (maps.isEmpty) {
        if (kDebugMode) {
          print('⚠️ UserProfileOfflineLocalDataSource: No hay perfil cacheado');
        }
        return null;
      }

      return _mapToProfile(maps.first);
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileOfflineLocalDataSource: Error obteniendo perfil cacheado: $e');
      }
      return null;
    }
  }

  /// Verifica si el cache es válido (menos de 7 días)
  Future<bool> isCacheValid({String? userId, String? email}) async {
    try {
      final cachedProfile = await getCachedUserProfile(userId: userId, email: email);
      if (cachedProfile == null) return false;

      final db = await database;
      List<Map<String, dynamic>> maps;

      if (userId != null) {
        maps = await db.query(
          'user_profile_cache',
          columns: ['cached_at'],
          where: 'user_id = ? OR id = ?',
          whereArgs: [userId, userId],
          limit: 1,
        );
      } else if (email != null) {
        maps = await db.query(
          'user_profile_cache',
          columns: ['cached_at'],
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );
      } else {
        maps = await db.query(
          'user_profile_cache',
          columns: ['cached_at'],
          orderBy: 'cached_at DESC',
          limit: 1,
        );
      }

      if (maps.isEmpty) return false;

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        maps.first['cached_at'] as int,
      );
      final daysSinceCache = DateTime.now().difference(cachedAt).inDays;

      return daysSinceCache < 7; // Cache válido por 7 días
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileOfflineLocalDataSource: Error verificando cache: $e');
      }
      return false;
    }
  }

  /// Limpia el cache
  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete('user_profile_cache');
      if (kDebugMode) {
        print('✅ UserProfileOfflineLocalDataSource: Cache limpiado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileOfflineLocalDataSource: Error limpiando cache: $e');
      }
    }
  }

  /// Convierte UserProfile a Map
  Map<String, dynamic> _profileToMap(UserProfile profile) {
    return {
      'user_id': profile.id,
      'id': profile.id,
      'username': profile.username,
      'email': profile.email,
      'mother_name': profile.motherName,
      'birth_date': profile.birthDate,
      'age': profile.age,
      'cedula': profile.cedula,
      'location': profile.location,
      'phone': profile.phone,
      'registration_date': profile.registrationDate.millisecondsSinceEpoch,
      'is_pre_partum': profile.isPrePartum ? 1 : 0,
      'is_post_partum': profile.isPostPartum ? 1 : 0,
      'baby_info': profile.babyInfo != null ? jsonEncode(_babyInfoToMap(profile.babyInfo!)) : null,
      'situation_data': profile.situationData != null ? jsonEncode(_serializeSituationData(profile.situationData!)) : null,
    };
  }

  /// Convierte Map a UserProfile
  UserProfile _mapToProfile(Map<String, dynamic> map) {
    BabyInfo? babyInfo;
    if (map['baby_info'] != null) {
      try {
        final babyInfoMap = jsonDecode(map['baby_info'] as String) as Map<String, dynamic>;
        babyInfo = _mapToBabyInfo(babyInfoMap);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ UserProfileOfflineLocalDataSource: Error parseando baby_info: $e');
        }
      }
    }

    Map<String, dynamic>? situationData;
    if (map['situation_data'] != null) {
      try {
        situationData = jsonDecode(map['situation_data'] as String) as Map<String, dynamic>;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ UserProfileOfflineLocalDataSource: Error parseando situation_data: $e');
        }
      }
    }

    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      motherName: map['mother_name'] as String? ?? '',
      birthDate: map['birth_date'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      cedula: map['cedula'] as String? ?? '',
      location: map['location'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      registrationDate: DateTime.fromMillisecondsSinceEpoch(
        map['registration_date'] as int,
      ),
      isPrePartum: (map['is_pre_partum'] as int? ?? 0) == 1,
      isPostPartum: (map['is_post_partum'] as int? ?? 0) == 1,
      babyInfo: babyInfo,
      situationData: situationData,
    );
  }

  /// Serializa situationData convirtiendo Timestamp y DateTime a formato serializable
  Map<String, dynamic> _serializeSituationData(Map<String, dynamic> data) {
    final serialized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final value = entry.value;
      
      if (value is Timestamp) {
        // Convertir Timestamp a int (millisecondsSinceEpoch)
        serialized[entry.key] = value.millisecondsSinceEpoch;
      } else if (value is DateTime) {
        // Convertir DateTime a String (ISO8601)
        serialized[entry.key] = value.toIso8601String();
      } else if (value is Map) {
        // Recursivamente serializar mapas anidados
        serialized[entry.key] = _serializeSituationData(value as Map<String, dynamic>);
      } else {
        // Otros tipos se mantienen igual
        serialized[entry.key] = value;
      }
    }
    
    return serialized;
  }

  /// Convierte BabyInfo a Map
  Map<String, dynamic> _babyInfoToMap(BabyInfo babyInfo) {
    return {
      'name': babyInfo.name,
      'gestational_age': babyInfo.gestationalAge,
      'birth_date': babyInfo.birthDate,
      'lactation_start_date': babyInfo.lactationStartDate,
      'lactation_time': babyInfo.lactationTime,
      'birth_time': babyInfo.birthTime,
      'birth_place': babyInfo.birthPlace,
      'weight': babyInfo.weight,
    };
  }

  /// Convierte Map a BabyInfo
  BabyInfo _mapToBabyInfo(Map<String, dynamic> map) {
    return BabyInfo(
      name: map['name'] as String,
      gestationalAge: map['gestational_age'] as int,
      birthDate: map['birth_date'] as String,
      lactationStartDate: map['lactation_start_date'] as String,
      lactationTime: map['lactation_time'] as String,
      birthTime: map['birth_time'] as String,
      birthPlace: map['birth_place'] as String,
      weight: map['weight'] as String,
    );
  }
}

