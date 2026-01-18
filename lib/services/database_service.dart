// SQLite database service

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/card.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mtg_cards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create cards table
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

    // Add future tables here for new installations
    // Example for version 2:
    // if (version >= 2) {
    //   await db.execute('''
    //     CREATE TABLE decks (
    //       deck_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       name TEXT NOT NULL,
    //       created_at TEXT NOT NULL
    //     )
    //   ''');
    // }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations for existing installations

    // Example migration to version 2:
    // if (oldVersion < 2) {
    //   await db.execute('''
    //     CREATE TABLE decks (
    //       deck_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       name TEXT NOT NULL,
    //       created_at TEXT NOT NULL
    //     )
    //   ''');
    // }

    // Example migration to version 3:
    // if (oldVersion < 3) {
    //   await db.execute('ALTER TABLE cards ADD COLUMN rarity TEXT');
    // }
  }

  // Insert a card
  Future<Card> insertCard(Card card) async {
    final db = await database;
    final id = await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return card.copyWith(cardId: id);
  }

  // Insert multiple cards
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

  // Get all cards
  Future<List<Card>> getAllCards() async {
    final db = await database;
    final result = await db.query('cards');
    return result.map((map) => Card.fromMap(map)).toList();
  }

  // Get card by ID
  Future<Card?> getCardById(int id) async {
    final db = await database;
    final result = await db.query(
      'cards',
      where: 'card_id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Card.fromMap(result.first);
  }

  // Get cards by set
  Future<List<Card>> getCardsBySet(String setName) async {
    final db = await database;
    final result = await db.query(
      'cards',
      where: 'set_name = ?',
      whereArgs: [setName],
    );
    return result.map((map) => Card.fromMap(map)).toList();
  }

  // Search cards by name
  Future<List<Card>> searchCardsByName(String name) async {
    final db = await database;
    final result = await db.query(
      'cards',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return result.map((map) => Card.fromMap(map)).toList();
  }

  // Update a card
  Future<int> updateCard(Card card) async {
    final db = await database;
    return db.update(
      'cards',
      card.toMap(),
      where: 'card_id = ?',
      whereArgs: [card.cardId],
    );
  }

  // Delete a card
  Future<int> deleteCard(int id) async {
    final db = await database;
    return await db.delete(
      'cards',
      where: 'card_id = ?',
      whereArgs: [id],
    );
  }

  // Delete all cards
  Future<int> deleteAllCards() async {
    final db = await database;
    return await db.delete('cards');
  }

  // Get card count
  Future<int> getCardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cards');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
