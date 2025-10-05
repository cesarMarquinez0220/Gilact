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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lactation_records(
        id TEXT PRIMARY KEY,
        dateTime INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        side TEXT
      )
    ''');
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
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'dateTime ASC',
    );

    return List.generate(maps.length, (i) => LactationRecord.fromMap(maps[i]));
  }

  Future<List<LactationRecord>> getRecordsForWeek(DateTime startOfWeek) async {
    final db = await database;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [
        startOfWeek.millisecondsSinceEpoch,
        endOfWeek.millisecondsSinceEpoch,
      ],
      orderBy: 'dateTime ASC',
    );

    return List.generate(maps.length, (i) => LactationRecord.fromMap(maps[i]));
  }

  Future<List<LactationRecord>> getRecordsForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    final List<Map<String, dynamic>> maps = await db.query(
      'lactation_records',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      ],
      orderBy: 'dateTime ASC',
    );

    return List.generate(maps.length, (i) => LactationRecord.fromMap(maps[i]));
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
      'SELECT SUM(duration) as total FROM lactation_records',
    );
    final totalDurationMinutes = Sqflite.firstIntValue(durationResult) ?? 0;
    final totalDuration = Duration(minutes: totalDurationMinutes);

    // Average duration
    final averageDuration = totalFeeds > 0
        ? Duration(minutes: totalDurationMinutes ~/ totalFeeds)
        : Duration.zero;

    // Today's feeds
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lactation_records WHERE dateTime >= ? AND dateTime < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    final feedsToday = Sqflite.firstIntValue(todayResult) ?? 0;

    // Today's duration
    final todayDurationResult = await db.rawQuery(
      'SELECT SUM(duration) as total FROM lactation_records WHERE dateTime >= ? AND dateTime < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
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
