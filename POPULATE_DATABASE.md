# Database Population Script

This script populates the MTG cards database from the card art files in `lib/assets/card_art`.

## Prerequisites

1. Install dependencies:
```bash
flutter pub get
```

## Usage

### Basic population (adds to existing database):
```bash
dart run populate_database.dart
```

### Clear and repopulate (removes all existing cards first):
```bash
dart run populate_database.dart --clear
```

## Expected Directory Structure

The script expects card art files to be organized as follows:

```
lib/assets/card_art/
├── Set_Name_1/
│   ├── 1_Card_Name.jpg
│   ├── 2_Another_Card.jpg
│   └── ...
├── Set_Name_2/
│   ├── 1_Card_Name.jpg
│   └── ...
└── ...
```

### File Naming Convention

Files should be named in the format: `{collector_number}_{card_name}.{ext}`

Examples:
- `1_2_Mace.jpg` → Collector: "1", Name: "2 Mace"
- `290_Iymrith_Desert_Doom.jpg` → Collector: "290", Name: "Iymrith Desert Doom"

### Directory Naming Convention

Directory names should use underscores instead of spaces:
- `Adventures_in_the_Forgotten_Realms` → "Adventures in the Forgotten Realms"

## Output

The script will:
1. Show progress as it processes each set
2. Display the number of cards added from each set
3. Show total cards inserted and any errors encountered
4. Display the final card count in the database

## Database Location

The SQLite database is created at the default location for your platform:
- Windows: `%APPDATA%\mtg_player\databases\mtg_cards.db`
- macOS: `~/Library/Application Support/mtg_player/databases/mtg_cards.db`
- Linux: `~/.local/share/mtg_player/databases/mtg_cards.db`
