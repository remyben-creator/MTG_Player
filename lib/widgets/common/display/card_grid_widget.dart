// Card grid widget - Displays cards in a scrollable grid layout

import 'package:flutter/material.dart';
import '../../../models/card.dart' as mtg;
import 'card_thumbnail_widget.dart';

class CardGridWidget extends StatelessWidget {
  final List<mtg.Card> cards;
  final double cardWidth;

  const CardGridWidget({
    super.key,
    required this.cards,
    this.cardWidth = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    // Limit to 100 cards max
    final displayCards = cards.take(100).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1 / 1.4, // MTG card aspect ratio
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayCards.length,
      itemBuilder: (context, index) {
        return CardThumbnailWidget(
          card: displayCards[index],
          width: cardWidth,
        );
      },
    );
  }
}
