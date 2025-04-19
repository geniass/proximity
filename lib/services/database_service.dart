import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart' as sqflite;

class DatabaseService {
  Database? _database;
  final DatabaseFactory _databaseFactory;

  // Constructor that accepts a custom database factory for testing
  DatabaseService({DatabaseFactory? databaseFactory})
    : _databaseFactory = databaseFactory ?? sqflite.databaseFactory;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (Platform.isAndroid || Platform.isIOS) {
      // Standard path for actual app usage
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'proximity.db');
    } else {
      // Test environment (using in-memory database)
      path = ':memory:';
    }

    return await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDb,
        onConfigure: _onConfigure,
        singleInstance: true,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Configure for better performance
    await db.rawQuery('PRAGMA journal_mode = WAL');
    await db.rawQuery('PRAGMA synchronous = NORMAL');
  }

  Future<void> _createDb(Database db, int version) async {
    // Create trips table
    await db.execute('''
      CREATE TABLE trips(
        id TEXT PRIMARY KEY,
        destination TEXT NOT NULL,
        start_date INTEGER,
        end_date INTEGER
      )
    ''');

    // Create places of interest table with foreign key reference to trips
    await db.execute('''
      CREATE TABLE places_of_interest(
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        google_place_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_ignored INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');

    // Create indices for faster lookups
    await db.execute(
      'CREATE INDEX idx_poi_trip_id ON places_of_interest(trip_id)',
    );
    await db.execute(
      'CREATE INDEX idx_poi_google_place_id ON places_of_interest(google_place_id)',
    );
  }

  // Wraps database operations in transactions
  Future<T> transaction<T>(Future<T> Function(Transaction) operation) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await operation(txn);
    });
  }

  // Method to close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
