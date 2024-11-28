import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> addNote(String content, String date) async {
    final db = await database;
    return await db.insert('notes', {'content': content, 'date': date});
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }
}