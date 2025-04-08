import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shops.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // static Future<Database> _initDb() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'shops.db');

  //   return await openDatabase(path, version: 1, onCreate: (db, version) async {
  //     await db.execute('''
  //       CREATE TABLE shops (
  //         id INTEGER PRIMARY KEY,
  //         name TEXT,
  //         number TEXT
  //       )
  //     ''');
  //   });
  // }
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ava.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Table 1: Shops
      await db.execute('''
      CREATE TABLE shops (
        id INTEGER PRIMARY KEY,
        name TEXT,
        number TEXT
      )
    ''');

      // Table 2: scheduledunits
      await db.execute('''
      CREATE TABLE scheduledunits (
        id INTEGER PRIMARY KEY,
        name TEXT,
      )
    ''');

      // Table 3: Orders (example)
    });
  }

//shops table
  static Future<void> insertShops(List<shops> shopsList) async {
    final db = await database;
    await db.delete('shops'); // clear old data
    for (var shop in shopsList) {
      await db.insert(
        'shops',
        shop.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<shops>> getCachedShops() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shops');

    return List.generate(maps.length, (i) {
      return shops(
        id: maps[i]['id'],
        name: maps[i]['name'],
        number: maps[i]['number'],
      );
    });
  }
}
