import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      developer.log('DatabaseService: Returning existing database instance');
      return _database!;
    }

    developer.log('DatabaseService: Initializing new database');
    _database = await _initDatabase();
    developer.log('DatabaseService: Database initialized successfully');
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'slova.db');
    developer.log('DatabaseService: Database path: $path');

    return await openDatabase(
      path,
      version: 2, // Увеличиваем версию для миграции
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    developer.log('DatabaseService: Upgrading database from $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Миграция: добавляем колонку description в таблицу categories
      await db.execute('ALTER TABLE categories ADD COLUMN description TEXT');
      developer.log('DatabaseService: Added description column to categories table');
    }
  }

  static Future<void> _createDatabase(Database db, int version) async {
    developer.log('DatabaseService: Creating database tables');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');
    developer.log('DatabaseService: Created categories table');

    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
    developer.log('DatabaseService: Created words table');
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}