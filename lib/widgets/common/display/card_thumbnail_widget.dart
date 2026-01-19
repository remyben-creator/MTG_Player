// Card thumbnail widget - Compact card display for browsing/grids

import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/card.dart' as mtg;
import 'card_detail_overlay.dart';

class CardThumbnailWidget extends StatelessWidget {
  final mtg.Card card;
  final double width;

  const CardThumbnailWidget({
    super.key,
    required this.card,
    this.width = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;

    return GestureDetector(
      onTap: () => _showCardDetail(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildCardImage(),
        ),
      ),
    );
  }

  void _showCardDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CardDetailOverlay(card: card),
    );
  }

  Widget _buildCardImage() {
    // Normalize path to use forward slashes for Flutter assets
    String imagePath = card.imagePath.replaceAll('\\', '/');

    // Strip 'lib/' prefix if present (Flutter assets don't include lib/ in the path)
    if (imagePath.startsWith('lib/')) {
      imagePath = imagePath.substring(4);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[600],
            size: width * 0.3,
          ),
        );
      },
    );
  }
}
