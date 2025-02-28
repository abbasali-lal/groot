import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'recordings.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recordings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT,
            duration TEXT,
            timestamp TEXT,
            waveformData TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertRecording(Map<String, dynamic> recording) async {
    final db = await database;
    return await db.insert('recordings', recording);
  }

  Future<List<Map<String, dynamic>>> getRecordings() async {
    final db = await database;
    return await db.query('recordings');
  }

  Future<int> deleteRecording(int id) async {
    final db = await database;
    return await db.delete('recordings', where: 'id = ?', whereArgs: [id]);
  }
}