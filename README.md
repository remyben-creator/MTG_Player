# MTG Player

A Flutter-based Magic: The Gathering digital player application.

## Project Structure

```
mtg_player/
├── lib/                                    # Main Flutter application code
│   ├── main.dart                          # Application entry point
│   ├── models/                            # Data models
│   │   ├── card.dart                     # MTG card model
│   │   ├── deck.dart                     # Deck model
│   │   ├── player.dart                   # Player model
│   │   └── game_state.dart               # Game state model
│   ├── screens/                           # UI screens
│   │   ├── home_screen.dart              # Main home screen
│   │   ├── game_screen.dart              # Game play screen
│   │   ├── profile_screen.dart           # Player profile screen
│   │   ├── deck_screens/                 # Deck management screens
│   │   │   ├── decks_home_screen.dart   # Deck list/home
│   │   │   ├── deck_builder_screen.dart # Build new decks
│   │   │   ├── deck_edit_screen.dart    # Edit existing decks
│   │   │   ├── create_deck_screen.dart  # Create deck wizard
│   │   │   ├── card_database_screen.dart # Browse all cards
│   │   │   └── card_viewer_screen.dart  # View individual cards
│   │   └── server_screens/               # Multiplayer screens
│   │       ├── host_screen.dart         # Host a game
│   │       ├── join_screen.dart         # Join a game
│   │       └── lobby_screen.dart        # Game lobby
│   ├── widgets/                           # Reusable UI components
│   │   ├── common/                       # Common widgets
│   │   │   ├── buttons/                 # Button components
│   │   │   │   ├── standard_button.dart
│   │   │   │   └── back_button.dart
│   │   │   └── display/                 # Display components
│   │   │       ├── card_grid_widget.dart
│   │   │       └── card_thumbnail_widget.dart
│   │   └── game/                         # Game-specific widgets
│   │       ├── card_widget.dart         # Card display widget
│   │       ├── card_back_widget.dart    # Card back display
│   │       └── player_info.dart         # Player info display
│   ├── services/                          # Business logic services
│   │   ├── database_service.dart         # Database operations
│   │   ├── api_service.dart             # API interactions
│   │   └── colyseum_service.dart        # Game server service
│   ├── providers/                         # State management
│   │   ├── game_provider.dart           # Game state provider
│   │   └── deck_provider.dart           # Deck state provider
│   ├── routes/                            # App routing
│   │   └── app_routes.dart              # Route definitions
│   └── utils/                             # Utility functions
│       ├── constants.dart                # App constants
│       ├── helpers.dart                  # Helper functions
│       ├── extensions.dart               # Dart extensions
│       ├── cli_database_service.dart     # CLI database utilities
│       └── populate_cards.dart           # Card population utilities
├── assets/                                 # Application assets (gitignored)
│   └── card_art/                         # Card artwork files
├── dev_assets/                            # Development assets (gitignored)
│   └── card_art/                         # Development card artwork
├── android/                                # Android-specific code
├── ios/                                    # iOS-specific code
├── linux/                                  # Linux-specific code
├── macos/                                  # macOS-specific code
├── windows/                                # Windows-specific code
├── web/                                    # Web-specific code
├── test/                                   # Test files
├── mtg-set-downloader-binder/             # Python tool for downloading card images
│   ├── Binder_Generator.py              # Main script
│   ├── requirements.txt                  # Python dependencies
│   └── cards.txt                         # Card list
├── generate_assets.dart                    # Script to generate asset references
├── populate_database.dart                  # Script to populate card database
├── POPULATE_DATABASE.md                    # Database population documentation
├── pubspec.yaml                            # Flutter dependencies
└── README.md                               # This file
```

## Key Features

- Card database management with SQLite
- Deck builder and editor
- Card browsing and viewing
- Multiplayer game support (host/join)
- Cross-platform support (Windows, macOS, Linux, iOS, Android, Web)

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK (comes with Flutter)
- For card image downloading: Python 3.x (see `mtg-set-downloader-binder/`)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Populate the card database (optional):
```bash
dart run populate_database.dart
```
See [POPULATE_DATABASE.md](POPULATE_DATABASE.md) for detailed instructions.

### Running the App

```bash
flutter run
```

## Database Location

The SQLite database is stored at platform-specific locations:
- **Windows**: `%APPDATA%\mtg_player\databases\mtg_cards.db`
- **macOS**: `~/Library/Application Support/mtg_player/databases/mtg_cards.db`
- **Linux**: `~/.local/share/mtg_player/databases/mtg_cards.db`

## Development Status

Currently normalizing and populating card images.
