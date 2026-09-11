import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/app_logger.dart';

/// Data source local para almacenar información de usuarios offline
class OfflineUserLocalDataSource {
  static Database? _database;
  static AppLogger get _logger => GetIt.instance<AppLogger>();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            name TEXT,
            password_hash TEXT NOT NULL,
            created_at INTEGER,
            last_sync INTEGER,
            profile_data TEXT
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_email ON offline_users(email)
        ''');
      },
    );
  }

  /// Guardar usuario para acceso offline
  Future<void> saveOfflineUser({
    required String id,
    required String email,
    required String name,
    required String passwordHash,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      final db = await database;
      await db.insert('offline_users', {
        'id': id,
        'email': email,
        'name': name,
        'password_hash': passwordHash,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'last_sync': DateTime.now().millisecondsSinceEpoch,
        'profile_data': profileData != null ? jsonEncode(profileData) : null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      _logger.success('Usuario guardado en base de datos local: $email');
    } catch (e, stackTrace) {
      _logger.e('Error guardando usuario offline', e, stackTrace);
      rethrow;
    }
  }

  /// Obtener usuario por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'offline_users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo usuario por email', e, stackTrace);
      return null;
    }
  }

  /// Obtener usuario por ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final db = await database;
      final results = await db.query(
        'offline_users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo usuario por ID', e, stackTrace);
      return null;
    }
  }

  /// Validar credenciales localmente
  Future<bool> validateCredentials(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return false;

      final storedHash = user['password_hash'] as String;
      final inputHash = _hashPassword(password);

      return storedHash == inputHash;
    } catch (e, stackTrace) {
      _logger.e('Error validando credenciales', e, stackTrace);
      return false;
    }
  }

  /// Actualizar última sincronización
  Future<void> updateLastSync(String email) async {
    try {
      final db = await database;
      await db.update(
        'offline_users',
        {'last_sync': DateTime.now().millisecondsSinceEpoch},
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e, stackTrace) {
      _logger.e('Error actualizando última sincronización', e, stackTrace);
    }
  }

  /// Eliminar usuario offline
  Future<void> deleteOfflineUser(String email) async {
    try {
      final db = await database;
      await db.delete('offline_users', where: 'email = ?', whereArgs: [email]);
      _logger.success('Usuario eliminado de base de datos local: $email');
    } catch (e, stackTrace) {
      _logger.e('Error eliminando usuario offline', e, stackTrace);
    }
  }

  /// Hash de contraseña (SHA-256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
