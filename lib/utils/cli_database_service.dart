// CLI-specific database service using sqflite_common_ffi
// This is for standalone scripts only, not for the Flutter app

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/card.dart';

class CliDatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Get database path
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'mtg_cards.db');

    _database = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );

    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        card_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        set_name TEXT NOT NULL,
        collector_number TEXT NOT NULL,
        image_path TEXT NOT NULL,
        UNIQUE(set_name, collector_number)
      )
    ''');
  }

  Future<void> insertCards(List<Card> cards) async {
    final db = await database;
    final batch = db.batch();
    for (final card in cards) {
      batch.insert(
        'cards',
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<int> getCardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cards');
    final count = result.first['count'] as int?;
    return count ?? 0;
  }

  Future<int> deleteAllCards() async {
    final db = await database;
    return await db.delete('cards');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
