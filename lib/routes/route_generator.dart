import 'package:flutter/material.dart';

// Route configuration
import 'app_routes.dart';
import 'route_arguments.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

// Server screens
import '../screens/server_screens/host_screen.dart';
import '../screens/server_screens/join_screen.dart';
import '../screens/server_screens/lobby_screen.dart';

// Deck screens
import '../screens/deck_screens/decks_home_screen.dart';
import '../screens/deck_screens/deck_creator_screen.dart';
import '../screens/deck_screens/list_viewing_screens/my_decks_screen.dart';
import '../screens/deck_screens/list_viewing_screens/card_database_screen.dart';
import '../screens/deck_screens/card_viewing_screens/card_viewer_screen.dart';

// Game screen (future)
// import '../screens/game_screen.dart';

/// Generates routes for the application
///
/// Handles all navigation, argument extraction, and error cases
class RouteGenerator {
  // Prevent instantiation
  RouteGenerator._();

  /// Main route generation method
  ///
  /// Called by MaterialApp's onGenerateRoute parameter
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments (will be null for routes without arguments)
    final args = settings.arguments;

    // Route switching logic
    switch (settings.name) {
      // Root
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Server/Multiplayer screens
      case AppRoutes.host:
        return MaterialPageRoute(builder: (_) => const HostScreen());

      case AppRoutes.join:
        return MaterialPageRoute(builder: (_) => const JoinScreen());

      case AppRoutes.lobby:
        // Validate arguments
        if (args is LobbyArguments) {
          return MaterialPageRoute(
            builder: (_) => LobbyScreen(
              roomId: args.roomId,
              isHost: args.isHost,
            ),
          );
        }
        // Invalid arguments - show error
        return _errorRoute('Lobby requires LobbyArguments');

      case AppRoutes.game:
        // Future implementation
        return _errorRoute('Game screen not yet implemented');

      // Deck management screens
      case AppRoutes.decks:
        return MaterialPageRoute(builder: (_) => const DecksScreen());

      case AppRoutes.createDeck:
        return MaterialPageRoute(builder: (_) => const CreateDeckScreen());

      case AppRoutes.myDecks:
        return MaterialPageRoute(builder: (_) => const MyDecksScreen());

      case AppRoutes.cardDatabase:
        return MaterialPageRoute(builder: (_) => const CardDatabaseScreen());

      case AppRoutes.cardViewer:
        // Validate arguments
        if (args is CardViewerArguments) {
          return MaterialPageRoute(
            builder: (_) => CardViewerScreen(
              title: args.title,
              cards: args.cards,
            ),
          );
        }
        // Invalid arguments - show error
        return _errorRoute('Card Viewer requires CardViewerArguments');

      // Profile screen
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // Unknown route
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Error route for unknown or invalid routes
  ///
  /// Shows a simple error screen with the error message
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFcf711f),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF5c320e),
                const Color(0xFF45260a),
                const Color(0xFF2e1907),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFCD853F),
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Navigation Error',
                  style: const TextStyle(
                    color: Color(0xFFCD853F),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFCD853F),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
