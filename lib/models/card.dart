// Card model

class Card {
  final int? cardId;
  final String name;
  final String setName;
  final String collectorNumber;
  final String imagePath;

  Card({
    this.cardId,
    required this.name,
    required this.setName,
    required this.collectorNumber,
    required this.imagePath,
  });

  // Convert a Card into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'card_id': cardId,
      'name': name,
      'set_name': setName,
      'collector_number': collectorNumber,
      'image_path': imagePath,
    };
  }

  // Create a Card from a Map (from SQLite query)
  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      cardId: map['card_id'] as int?,
      name: map['name'] as String,
      setName: map['set_name'] as String,
      collectorNumber: map['collector_number'] as String,
      imagePath: map['image_path'] as String,
    );
  }

  // For debugging
  @override
  String toString() {
    return 'Card{cardId: $cardId, name: $name, setName: $setName, collectorNumber: $collectorNumber, imagePath: $imagePath}';
  }

  // Create a copy with modified fields
  Card copyWith({
    int? cardId,
    String? name,
    String? setName,
    String? collectorNumber,
    String? imagePath,
  }) {
    return Card(
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      setName: setName ?? this.setName,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
