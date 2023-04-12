import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/attractions.dart';

class DatabaseProvider {
  static const _dbName = 'attraction_list.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE attraction (
        ${Attraction.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Attraction.DESCRIPTiON} TEXT NOT NULL,
        ${Attraction.REGISTERED} TEXT,
        ${Attraction.DIFERENTIALS} TEXT,
        ${Attraction.TITLE} TEXT,
        ${Attraction.ENDED} INTEGER NOT NULL DEFAULT 0);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch (oldVersion) {
      case 1:
        await db.execute('''
        ALTER TABLE attraction
        ADD ${Attraction.ENDED} INTEGER NOT NULL DEFAULT 0;
        ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
