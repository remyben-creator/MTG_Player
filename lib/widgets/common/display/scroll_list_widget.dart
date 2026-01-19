// Scroll list widget - Generic scrollable list layout for items

import 'package:flutter/material.dart';
import 'scroll_item_widget.dart';

class ScrollListWidget extends StatelessWidget {
  final List<String> itemNames;
  final ScrollItemType itemType;
  final Function(int) onItemTap;
  final Function(int)? onItemDelete;
  final String emptyMessage;

  const ScrollListWidget({
    super.key,
    required this.itemNames,
    required this.itemType,
    required this.onItemTap,
    this.onItemDelete,
    this.emptyMessage = 'No items yet',
  });

  @override
  Widget build(BuildContext context) {
    if (itemNames.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemNames.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ScrollItemWidget(
            itemName: itemNames[index],
            itemType: itemType,
            onTap: () => onItemTap(index),
            onDelete: onItemDelete != null ? () => onItemDelete!(index) : null,
          ),
        );
      },
    );
  }
}
