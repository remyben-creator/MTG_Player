/// Route name constants for the application
///
/// All route paths are defined here as constants to prevent typos
/// and make refactoring easier.
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Root
  static const String home = '/';

  // Server/Multiplayer screens
  static const String host = '/host';
  static const String join = '/join';
  static const String lobby = '/lobby';
  static const String game = '/game'; // Future implementation

  // Deck management screens
  static const String decks = '/decks';
  static const String createDeck = '/decks/create';
  static const String myDecks = '/decks/my-decks';
  static const String cardDatabase = '/decks/card-database';
  static const String cardViewer = '/decks/card-viewer';

  // Profile screen
  static const String profile = '/profile';

  // Future routes (placeholder for planning)
  // static const String settings = '/settings';
  // static const String deckEditor = '/decks/edit';
}
