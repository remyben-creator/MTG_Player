// Utility to populate the database from card art files

import 'dart:io';
import '../models/card.dart';

class CardPopulator {
  final String cardArtPath;
  final dynamic dbService; // Accepts any database service with insertCards/deleteAllCards methods

  CardPopulator({
    required this.cardArtPath,
    required this.dbService,
  });

  /// Convert underscore-separated string to human-readable format
  /// Example: "Adventures_in_the_Forgotten_Realms" -> "Adventures in the Forgotten Realms"
  String _formatName(String underscoreName) {
    return underscoreName.replaceAll('_', ' ');
  }

  /// Parse a card filename and extract collector number and card name
  /// Format: collectornumber_card_name.extension
  /// Example: "290_Iymrith_Desert_Doom.jpg" -> ("290", "Iymrith Desert Doom")
  (String collectorNumber, String cardName)? _parseFilename(String filename) {
    try {
      // Remove extension
      final nameWithoutExt = filename.substring(0, filename.lastIndexOf('.'));

      // Split by underscore
      final parts = nameWithoutExt.split('_');

      if (parts.isEmpty) return null;

      // First part is collector number
      final collectorNumber = parts[0];

      // Rest is card name
      final cardName = parts.skip(1).join(' ');

      if (cardName.isEmpty) return null;

      return (collectorNumber, cardName);
    } catch (e) {
      print('Error parsing filename "$filename": $e');
      return null;
    }
  }

  /// Scan card art directory and populate database
  Future<int> populateDatabase() async {
    print('Starting card population from: $cardArtPath');

    final cardArtDir = Directory(cardArtPath);

    if (!await cardArtDir.exists()) {
      print('Error: Card art directory does not exist: $cardArtPath');
      return 0;
    }

    int totalCards = 0;
    int errorCount = 0;
    final List<Card> cardsToInsert = [];

    // Get all subdirectories (set names)
    final setDirs = await cardArtDir
        .list()
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();

    print('Found ${setDirs.length} set directories');

    for (final setDir in setDirs) {
      final setNameRaw = setDir.path.split(Platform.pathSeparator).last;
      final setName = _formatName(setNameRaw);

      print('\nProcessing set: $setName');
      int setCardCount = 0;

      // Get all image files in the set directory
      final files = await setDir
          .list()
          .where((entity) =>
              entity is File &&
              (entity.path.toLowerCase().endsWith('.jpg') ||
                  entity.path.toLowerCase().endsWith('.png') ||
                  entity.path.toLowerCase().endsWith('.jpeg')))
          .cast<File>()
          .toList();

      for (final file in files) {
        final filename = file.path.split(Platform.pathSeparator).last;
        final parsed = _parseFilename(filename);

        if (parsed == null) {
          print('  Warning: Could not parse filename: $filename');
          errorCount++;
          continue;
        }

        final (collectorNumber, cardName) = parsed;

        // Create relative path for storage
        final relativePath = 'lib${Platform.pathSeparator}assets${Platform.pathSeparator}card_art${Platform.pathSeparator}$setNameRaw${Platform.pathSeparator}$filename';

        final card = Card(
          name: cardName,
          setName: setName,
          collectorNumber: collectorNumber,
          imagePath: relativePath,
        );

        cardsToInsert.add(card);
        setCardCount++;
      }

      print('  Added $setCardCount cards from $setName');
      totalCards += setCardCount;

      // Insert cards in batches of 100 for better performance
      if (cardsToInsert.length >= 100) {
        await dbService.insertCards(cardsToInsert);
        cardsToInsert.clear();
      }
    }

    // Insert remaining cards
    if (cardsToInsert.isNotEmpty) {
      await dbService.insertCards(cardsToInsert);
    }

    print('\n=================================');
    print('Population complete!');
    print('Total cards inserted: $totalCards');
    print('Errors encountered: $errorCount');
    print('=================================');

    return totalCards;
  }

  /// Clear all cards from database
  Future<void> clearDatabase() async {
    print('Clearing all cards from database...');
    await dbService.deleteAllCards();
    print('Database cleared.');
  }
}
