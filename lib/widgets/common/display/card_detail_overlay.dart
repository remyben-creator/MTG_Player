// Card detail overlay - Full-screen card view for detailed inspection

import 'package:flutter/material.dart';
import '../../../models/card.dart' as mtg;

class CardDetailOverlay extends StatelessWidget {
  final mtg.Card card;

  const CardDetailOverlay({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: AspectRatio(
              aspectRatio: 5 / 7, // Standard MTG card ratio
              child: _buildCardImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    // Normalize path to use forward slashes for Flutter assets
    String imagePath = card.imagePath.replaceAll('\\', '/');

    // Strip 'lib/' prefix if present
    if (imagePath.startsWith('lib/')) {
      imagePath = imagePath.substring(4);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[600],
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Image not found',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
