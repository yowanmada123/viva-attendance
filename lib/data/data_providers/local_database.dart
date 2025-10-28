import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/attendance_log.dart';

class LocalDatabase {
  static Database? _database;
  static const String _tableName = 'attendance_logs';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        attendanceType TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        deviceId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        success INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<int> insertAttendanceLog(AttendanceLog log) async {
    final db = await database;
    return await db.insert(_tableName, log.toMap());
  }

  static Future<List<AttendanceLog>> getPendingLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'success = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => AttendanceLog.fromMap(maps[i]));
  }

  static Future<void> markLogAsSuccess(int id) async {
    final db = await database;
    await db.update(
      _tableName,
      {'success': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteLog(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}