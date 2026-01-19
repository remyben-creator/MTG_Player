#!/usr/bin/env dart

// Script to populate the MTG cards database from card art files
// Usage: dart run populate_database.dart [--clear]

import 'dart:io';
import 'lib/utils/cli_database_service.dart';
import 'lib/utils/populate_cards.dart';

Future<void> main(List<String> arguments) async {
  print('MTG Card Database Populator');
  print('============================\n');

  // Parse arguments
  final shouldClear = arguments.contains('--clear');

  // Get the card art directory path
  final currentDir = Directory.current.path;
  final cardArtPath = '$currentDir${Platform.pathSeparator}dev_assets${Platform.pathSeparator}card_art';

  // Initialize services
  final dbService = CliDatabaseService();
  final populator = CardPopulator(
    cardArtPath: cardArtPath,
    dbService: dbService,
  );

  try {
    // Clear database if requested
    if (shouldClear) {
      print('Clearing existing database...\n');
      await populator.clearDatabase();
    }

    // Get current card count
    final currentCount = await dbService.getCardCount();
    print('Current cards in database: $currentCount\n');

    // Populate database
    final cardsAdded = await populator.populateDatabase();

    // Get final count
    final finalCount = await dbService.getCardCount();
    print('\nFinal cards in database: $finalCount');

    // Close database connection
    await dbService.close();

    print('\nDone!');
    exit(0);
  } catch (e, stackTrace) {
    print('\nError occurred during population:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);

    // Close database connection
    try {
      await dbService.close();
    } catch (_) {}

    exit(1);
  }
}
