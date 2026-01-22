import '../models/card.dart';

/// Typed argument classes for routes that pass data between screens
///
/// Using classes instead of Map<String, dynamic> provides:
/// - Type safety (catch errors at compile time)
/// - Self-documenting code (clear what each route needs)
/// - IDE support (autocomplete and refactoring)

/// Arguments for the Lobby screen
///
/// Used when navigating from Host or Join screens to the Lobby
class LobbyArguments {
  final String roomId;
  final bool isHost;

  LobbyArguments({
    required this.roomId,
    required this.isHost,
  });
}

/// Arguments for the Card Viewer screen
///
/// Used when navigating from Card Database to view a specific set of cards
class CardViewerArguments {
  final String title;
  final List<Card> cards;

  CardViewerArguments({
    required this.title,
    required this.cards,
  });
}

/// Arguments for the Game screen (Future implementation)
///
/// Used when navigating from Lobby to the actual game
class GameArguments {
  final String roomId;

  GameArguments({
    required this.roomId,
  });
}
