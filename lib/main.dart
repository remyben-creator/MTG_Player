import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/database_service.dart';
import 'utils/populate_cards.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Populate database if empty
  await _initializeDatabase();

  runApp(const MyApp());
}

Future<void> _initializeDatabase() async {
  try {
    final dbService = DatabaseService.instance;
    final cardCount = await dbService.getCardCount();

    if (cardCount == 0) {
      print('Database is empty. Populating...');
      final currentDir = Directory.current.path;
      final cardArtPath = '$currentDir${Platform.pathSeparator}dev_assets${Platform.pathSeparator}card_art';

      final populator = CardPopulator(
        cardArtPath: cardArtPath,
        dbService: dbService,
      );

      await populator.populateDatabase();
      print('Database populated successfully!');
    } else {
      print('Database already has $cardCount cards');
    }
  } catch (e) {
    print('Error initializing database: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remy\'s MTG Player',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFcf711f), // Bright Orange
          secondary: const Color(0xFF8a4c14), // Brown Orange
          surface: const Color(0xFFb8651b),
          background: const Color(0xFFa15818),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFa15818),
      ),
      // Use named routes
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
