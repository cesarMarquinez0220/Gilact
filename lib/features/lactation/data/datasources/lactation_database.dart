import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/lactation_record.dart';

class LactationDatabase {
  static final LactationDatabase _instance = LactationDatabase._internal();
  factory LactationDatabase() => _instance;
  LactationDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'lactation.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lactation_records(
        id TEXT PRIMARY KEY,
        fecha_registro TEXT NOT NULL,
        duracion INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        notas TEXT,
        lado TEXT,
        volumen_extraccion INTEGER DEFAULT 0,
        unidad_volumen TEXT DEFAULT 'No',
        veces_biberon INTEGER DEFAULT 0,
        veces_pecho INTEGER DEFAULT 0,
        pecho_dado TEXT DEFAULT 'Ninguna',
        horas_sueno_bebe INTEGER DEFAULT 0,
        unidad_sueno TEXT DEFAULT 'No',
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrar de la versión 1 a la 2
      await db.execute('DROP TABLE IF EXISTS lactation_records');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> insertRecord(LactationRecord record) async {
    final db = await database;
    await db.insert(
      'lactation_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LactationRecord>> getRecordsForDate(DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'timestamp ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<List<LactationRecord>> getRecordsForWeek(DateTime startOfWeek) async {
    final db = await database;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startString = startOfWeek.toIso8601String();
    final endString = endOfWeek.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro >= ? AND fecha_registro < ?',
      whereArgs: [startString, endString],
      orderBy: 'timestamp ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<List<LactationRecord>> getRecordsForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);
    final startString = startOfMonth.toIso8601String();
    final endString = endOfMonth.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'fecha_registro >= ? AND fecha_registro < ?',
      whereArgs: [startString, endString],
      orderBy: 'timestamp ASC',
    );

    return List.generate(
      maps.length,
      (i) => LactationRecord.fromMap(maps[i], maps[i]['id']),
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('lactation_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRecord(LactationRecord record) async {
    final db = await database;
    await db.update(
      'lactation_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<LactationStats> getStats() async {
    final db = await database;

    // Total feeds
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lactation_records',
    );
    final totalFeeds = Sqflite.firstIntValue(totalResult) ?? 0;

    // Total duration
    final durationResult = await db.rawQuery(
      'SELECT SUM(duracion) as total FROM lactation_records',
    );
    final totalDurationMinutes = Sqflite.firstIntValue(durationResult) ?? 0;
    final totalDuration = Duration(minutes: totalDurationMinutes);

    // Average duration
    final averageDuration = totalFeeds > 0
        ? Duration(minutes: totalDurationMinutes ~/ totalFeeds)
        : Duration.zero;

    // Today's feeds
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lactation_records WHERE fecha_registro LIKE ?',
      ['$todayString%'],
    );
    final feedsToday = Sqflite.firstIntValue(todayResult) ?? 0;

    // Today's duration
    final todayDurationResult = await db.rawQuery(
      'SELECT SUM(duracion) as total FROM lactation_records WHERE fecha_registro LIKE ?',
      ['$todayString%'],
    );
    final todayDurationMinutes =
        Sqflite.firstIntValue(todayDurationResult) ?? 0;
    final durationToday = Duration(minutes: todayDurationMinutes);

    return LactationStats(
      totalFeeds: totalFeeds,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      feedsToday: feedsToday,
      durationToday: durationToday,
    );
  }
}
