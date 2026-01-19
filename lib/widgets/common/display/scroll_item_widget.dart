// Scroll item widget - Generic item display for scrollable lists

import 'package:flutter/material.dart';

enum ScrollItemType {
  deck,
  set,
}

class ScrollItemWidget extends StatelessWidget {
  final String itemName;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final ScrollItemType itemType;

  const ScrollItemWidget({
    super.key,
    required this.itemName,
    required this.onTap,
    required this.itemType,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFCD853F),
        border: Border.all(
          color: const Color(0xFF2e1907),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Item name on the left
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2e1907),
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Delete button on the right (only for deck items)
                if (itemType == ScrollItemType.deck && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFF8B0000),
                    iconSize: 24,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
