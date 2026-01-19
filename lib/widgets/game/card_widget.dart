// Card widget - Displays an MTG card with image

import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/card.dart' as mtg;

class CardWidget extends StatelessWidget {
  final mtg.Card card;
  final double width;
  final bool isTapped;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 150.0,
    this.isTapped = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate height based on standard MTG card ratio (2.5:3.5 or ~0.714)
    final height = width * 1.4;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedRotation(
        turns: isTapped ? 0.25 : 0.0, // 90 degrees when tapped
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildCardImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    // Clean up the path - remove 'lib/' prefix if present and normalize separators
    String imagePath = card.imagePath;
    if (imagePath.startsWith('lib${Platform.pathSeparator}')) {
      imagePath = imagePath.substring(4); // Remove 'lib/'
    }
    if (imagePath.startsWith('lib/')) {
      imagePath = imagePath.substring(4); // Remove 'lib/'
    }

    // Flutter assets always use forward slashes, even on Windows
    imagePath = imagePath.replaceAll('\\', '/');

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: child,
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[600],
            size: width * 0.3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              card.name,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.setName,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

