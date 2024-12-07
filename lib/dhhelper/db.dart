import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookmarks.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE bookmarks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            url TEXT NOT NULL,
            urlToImage TEXT,
            publishedAt TEXT,
            content TEXT,
            author TEXT,
            language TEXT  -- Added language column
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the 'language' column if it's missing
          await db.execute('''
            ALTER TABLE bookmarks ADD COLUMN language TEXT;
          ''');
        }
      },
    );
  }

  Future<void> insertBookmark(Map<String, dynamic> article) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      article,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String title) async {
    final db = await database;
    await db.delete('bookmarks', where: 'title = ?', whereArgs: [title]);
  }

  Future<List<Map<String, dynamic>>> fetchBookmarks() async {
    final db = await database;
    return db.query('bookmarks');
  }

Future<List<Map<String, dynamic>>> fetchArticlesByDateRange(
    DateTime startDate, DateTime endDate) async {
  final db = await database;

  // Query the database for articles within the date range
  final results = await db.query(
    'bookmarks',
    where: "publishedAt BETWEEN ? AND ?",
    whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
  );

  // Debugging log to check the number of articles found
  debugPrint("Query Results: ${results.length} articles found");

  // Return the fetched results
  return results;
}

}
