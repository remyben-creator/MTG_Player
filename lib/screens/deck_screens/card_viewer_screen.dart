import 'package:flutter/material.dart';
import '../../widgets/common/buttons/back_button.dart';
import '../../widgets/common/display/card_grid_widget.dart';
import '../../models/card.dart' as mtg;

class CardViewerScreen extends StatelessWidget {
  final String title;
  final List<mtg.Card> cards;

  const CardViewerScreen({
    super.key,
    required this.title,
    required this.cards,
  });

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
                        title.toUpperCase(),
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
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
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
                  child: CardGridWidget(cards: cards),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
