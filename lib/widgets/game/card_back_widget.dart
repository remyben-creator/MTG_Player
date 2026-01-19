// Card back widget - Displays the back of an MTG card

import 'package:flutter/material.dart';

class CardBackWidget extends StatelessWidget {
  final double width;

  const CardBackWidget({
    super.key,
    this.width = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.brown[800]!,
            Colors.brown[600]!,
            Colors.brown[800]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.amber[700],
          size: width * 0.5,
        ),
      ),
    );
  }
}
