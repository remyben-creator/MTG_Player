import 'package:flutter/material.dart';
import '../../../widgets/common/buttons/back_button.dart';
import '../../../widgets/common/display/scroll_list_widget.dart';
import '../../../widgets/common/display/scroll_item_widget.dart';

class MyDecksScreen extends StatefulWidget {
  const MyDecksScreen({super.key});

  @override
  State<MyDecksScreen> createState() => _MyDecksScreenState();
}

class _MyDecksScreenState extends State<MyDecksScreen> {
  // Sample deck data - replace with actual database service later
  List<String> deckNames = [
    'Control Deck',
    'Aggro Deck',
    'Combo Deck',
  ];

  void _handleDeckTap(int index) {
    // TODO: Navigate to deck detail/edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opened: ${deckNames[index]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleDeckDelete(int index) {
    final deckName = deckNames[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2e1907),
        title: const Text(
          'Delete Deck',
          style: TextStyle(color: Color(0xFFCD853F)),
        ),
        content: Text(
          'Are you sure you want to delete "$deckName"?',
          style: const TextStyle(color: Color(0xFFCD853F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFCD853F)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                deckNames.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted: $deckName'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF5c320e),
                  const Color(0xFF45260a),
                  const Color(0xFF2e1907),
                ],
              ),
            ),
          ),
          // Organic blob patterns
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFcf711f).withOpacity(0.3),
                    const Color(0xFFcf711f).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8a4c14).withOpacity(0.4),
                    const Color(0xFF8a4c14).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            left: -50,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFb8651b).withOpacity(0.35),
                    const Color(0xFFb8651b).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFa15818).withOpacity(0.3),
                    const Color(0xFFa15818).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  leading: const CustomBackButton(),
                  title: Stack(
                    children: [
                      Text(
                        'MY DECKS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 24,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = const Color(0xFF2e1907),
                        ),
                      ),
                      const Text(
                        'MY DECKS',
                        style: TextStyle(
                          color: Color(0xFFCD853F),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: ScrollListWidget(
                    itemNames: deckNames,
                    itemType: ScrollItemType.deck,
                    onItemTap: _handleDeckTap,
                    onItemDelete: _handleDeckDelete,
                    emptyMessage: 'No decks yet',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
